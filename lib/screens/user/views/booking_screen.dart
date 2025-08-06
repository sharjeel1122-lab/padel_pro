// ignore_for_file: deprecated_member_use

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:padel_pro/custom_widgets/home_header.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../controllers/auth controllers/auth_rolebase_controller.dart';
import '../../../controllers/user_controller.dart';
import '../../bookings/controllers/bookingcontroller.dart';
import '../../bookings/views/confirmation_screen.dart';

class BookingScreen extends StatelessWidget {
  final controller = Get.put(BookingController());
  final userController = Get.put(UserController());
  final authController = Get.find<AuthController>();
  final courts = ['Court 1', 'Court 2', 'Court 3', 'Court 4'];
  final durations = [30, 60, 90, 120, 150, 180];
  final timeSlots = [
    '1:30 PM', '2:00 PM', '2:30 PM', '3:00 PM', '3:30 PM', '4:00 PM',
    '4:30 PM', '5:00 PM', '5:30 PM', '6:00 PM', '6:30 PM', '7:00 PM',
    '7:30 PM', '8:00 PM', '8:30 PM', '9:00 PM', '9:30 PM', '10:00 PM', '10:30 PM'
  ];

   BookingScreen({super.key});

  Future<void> launchMap() async {
    const url = 'https://www.google.com/maps/search/?api=1&query=Club+Padel';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      Get.snackbar('Error', 'Could not launch maps',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    }
  }

  Future<void> launchPhone() async {
    const telUrl = 'tel:+923001234567';
    if (await canLaunch(telUrl)) {
      await launch(telUrl);
    } else {
      Get.snackbar('Error', 'Could not launch phone dialer',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    }
  }

  double calculatePrice(String selectedTime, int durationMinutes) {
    try {
      final hourPart = int.parse(selectedTime.split(":")[0]) % 12;
      final minutePart = int.parse(selectedTime.split(":")[1].split(" ")[0]);
      final isPM = selectedTime.contains("PM");

      final time = TimeOfDay(
        hour: hourPart + (isPM ? 12 : 0),
        minute: minutePart,
      );

      final isPeak = time.hour >= 15 || time.hour < 4;
      final hourlyRate = isPeak ? 2000.0 : 1500.0;

      return (hourlyRate / 60) * durationMinutes;
    } catch (e) {
      print("Error parsing time: $e");
      return 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar:
      AppBar(
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title:  HomeHeader(),
        toolbarHeight: 70.h,
      ),
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child:
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Column(
              //   children: [
              //     Padding(
              //       padding: const EdgeInsets.only(top: 15, left: 3, right: 10),
              //       child: Row(
              //         children: [
              //           CircleAvatar(
              //               radius: 20.r, backgroundImage: AssetImage('assets/man.jpg')),
              //           SizedBox(width: 12.w),
              //           Expanded(
              //             child: Obx(() => Column(
              //               crossAxisAlignment: CrossAxisAlignment.start,
              //               children: [
              //                 Obx(() {
              //                   if (_controllerProfile.isLoading.value) {
              //                     return const SizedBox(
              //                       height: 5,
              //                       child: LinearProgressIndicator(
              //                           color: Colors.white),
              //                     );
              //                   }
              //
              //                   final name = _controllerProfile.fullName.isNotEmpty
              //                       ? _controllerProfile.fullName
              //                       : 'Name...';
              //
              //                   return Text(
              //                     "$name",
              //                     style: const TextStyle(
              //                       fontSize: 22,
              //                       fontWeight: FontWeight.bold,
              //                       color: Color(0xFF0C1E2C),
              //                     ),
              //                   );
              //                 }),
              //
              //                 // Text(userController.username.value,
              //                 //     style: TextStyle(
              //                 //         fontSize: 16.sp, fontWeight: FontWeight.bold)),
              //
              //
              //                 SizedBox(height: 2.h),
              //                 Row(
              //                   children: [
              //                     Icon(Icons.location_on,
              //                         size: 14.sp, color: Colors.grey),
              //                     SizedBox(width: 4.w),
              //                     Expanded(
              //                       child: Text(userController.location.value,
              //                           overflow: TextOverflow.ellipsis,
              //                           style: TextStyle(
              //                               fontSize: 12.sp, color: Colors.grey)),
              //                     ),
              //                   ],
              //                 ),
              //               ],
              //             )),
              //           ),
              //
              //           SizedBox(width: 8.w),
              //           _iconButton(
              //             icon: Icons.notifications_none,
              //             onTap: () {
              //               Navigator.push(
              //                 context,
              //                 MaterialPageRoute(
              //                     builder: (context) => NotificationsScreen()),
              //               );
              //             },
              //           ),
              //
              //           SizedBox(width: 8.w),
              //           _iconButton(
              //             icon: Icons.logout_outlined,
              //             onTap: () {
              //               authController.logout();
              //             },
              //           ),
              //         ],
              //       ),
              //     ),
              //
              //     // Show search field if toggled
              //     Obx(() => userController.isSearching.value
              //         ? Padding(
              //       padding: const EdgeInsets.only(top: 12.0, left: 12, right: 12),
              //       child: TextField(
              //         onChanged: userController.updateSearchText,
              //         decoration: InputDecoration(
              //           hintText: "Search venue...",
              //           prefixIcon: Icon(Icons.search),
              //           filled: true,
              //           fillColor: Colors.grey.shade100,
              //           border: OutlineInputBorder(
              //             borderRadius: BorderRadius.circular(12),
              //             borderSide: BorderSide.none,
              //           ),
              //         ),
              //       ),
              //     )
              //         : SizedBox.shrink()),
              //   ],
              // ),
              // Court Images
              FadeIn(
                duration: Duration(milliseconds: 500),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    height: 220,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          spreadRadius: 2,
                        )
                      ],
                    ),
                    child: PageView(
                      children: [
                        Image.asset('assets/court1.jpg', fit: BoxFit.cover),
                        Image.asset('assets/court2.jpg', fit: BoxFit.cover),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Club Info and Actions
              FadeIn(
                duration: Duration(milliseconds: 600),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Club Padel",
                            style: GoogleFonts.poppins(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF072A40)
                            )),
                        SizedBox(height: 4),
                        Obx(() {
                          final selectedDate = controller.selectedDateIndex.value < controller.dates.length
                              ? controller.dates[controller.selectedDateIndex.value]
                              : DateTime.now();
                          final formatted = "${selectedDate.day.toString().padLeft(2, '0')}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.year}";
                          return Text("Selected: $formatted",
                              style: GoogleFonts.poppins(
                                  color: Colors.grey[600],
                                  fontSize: 12
                              ));
                        }),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.location_on_rounded, color: Colors.deepPurple[400]),
                          onPressed: launchMap,
                          tooltip: "Get Directions",
                        ),
                        SizedBox(width: 4),
                        IconButton(
                          icon: Icon(Icons.call_rounded, color: Colors.teal[400]),
                          onPressed: launchPhone,
                          tooltip: "Call Club",
                        ),
                      ],
                    )
                  ],
                ),
              ),
              SizedBox(height: 24),

              // Date Selection
              FadeIn(
                duration: Duration(milliseconds: 700),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Select Date",
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Color(0xFF072A40)
                        )),
                    SizedBox(height: 12),
                    Obx(() {
                      final selectedDate = controller.dates[controller.selectedDateIndex.value];
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: Icon(Icons.arrow_back_ios, size: 20),
                            onPressed: () {
                              controller.currentMonth.value--;
                              controller.dates.value = List.generate(31, (index) {
                                return DateTime(DateTime.now().year, controller.currentMonth.value, index + 1);
                              });
                            },
                          ),
                          Text(
                            "${selectedDate.day.toString().padLeft(2, '0')} ${_getMonthName(selectedDate.month)} ${selectedDate.year}",
                            style: GoogleFonts.poppins(
                                color: Color(0xFF072A40),
                                fontWeight: FontWeight.w600,
                                fontSize: 14
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.arrow_forward_ios, size: 20),
                            onPressed: () {
                              controller.currentMonth.value++;
                              controller.dates.value = List.generate(31, (index) {
                                return DateTime(DateTime.now().year, controller.currentMonth.value, index + 1);
                              });
                            },
                          ),
                        ],
                      );
                    }),
                    SizedBox(height: 12),
                    Obx(() => SizedBox(
                      height: 70,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: controller.dates.length,
                        itemBuilder: (context, index) {
                          final date = controller.dates[index];
                          final day = date.day;
                          final weekDay = _getWeekday(date.weekday);
                          final isDisabled = date.isBefore(DateTime.now().subtract(Duration(days: 1)));
                          return GestureDetector(
                            onTap: isDisabled ? null : () => controller.selectedDateIndex.value = index,
                            child: Obx(() => Container(
                              width: 60,
                              margin: EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                color: controller.selectedDateIndex.value == index
                                    ? Color(0xFF072A40)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Color(0xFF072A40),
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("$day",
                                      style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.bold,
                                          color: isDisabled
                                              ? Colors.grey
                                              : controller.selectedDateIndex.value == index
                                              ? Colors.white
                                              : Colors.black
                                      )),
                                  Text(weekDay,
                                      style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: isDisabled
                                              ? Colors.grey
                                              : controller.selectedDateIndex.value == index
                                              ? Colors.white
                                              : Colors.black
                                      )),
                                ],
                              ),
                            )),
                          );
                        },
                      ),
                    )),
                  ],
                ),
              ),
              SizedBox(height: 24),

              // Court Selection
              FadeIn(
                duration: Duration(milliseconds: 800),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Select Court",
                        style: GoogleFonts.poppins(
                            color: Color(0xFF072A40),
                            fontWeight: FontWeight.w600,
                            fontSize: 16
                        )),
                    SizedBox(height: 12),
                    Obx(() => Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(courts.length, (index) => ChoiceChip(
                        label: Text(courts[index],
                            style: GoogleFonts.poppins(
                                color: controller.selectedCourtIndex.value == index
                                    ? Colors.white
                                    : Color(0xFF072A40)
                            )),
                        selected: controller.selectedCourtIndex.value == index,
                        onSelected: (_) => controller.selectedCourtIndex.value = index,
                        selectedColor: Color(0xFF072A40),
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: Color(0xFF072A40)),
                        ),
                        labelPadding: EdgeInsets.symmetric(horizontal: 12),
                        selectedShadowColor: Colors.transparent,
                        checkmarkColor: Colors.white,
                      )),
                    )),
                  ],
                ),
              ),
              SizedBox(height: 24),

              // Duration Selection with Price
              FadeIn(
                duration: Duration(milliseconds: 900),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Select Duration",
                        style: GoogleFonts.poppins(
                            color: Color(0xFF072A40),
                            fontWeight: FontWeight.w600,
                            fontSize: 16
                        )),
                    SizedBox(height: 12),
                    Obx(() {
                      // Get first available time to calculate price
                      final sampleTime = controller.availableTimesPerCourt[controller.selectedCourtIndex.value]?.first ??
                          timeSlots.firstWhere((time) =>
                          controller.availableTimesPerCourt[controller.selectedCourtIndex.value]?.contains(time) ?? false,
                              orElse: () => timeSlots.first);

                      return Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: durations.map((minutes) {
                          final price = calculatePrice(sampleTime, minutes);

                          return ChoiceChip(
                            label: Container(
                              padding: EdgeInsets.symmetric(vertical: 4),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text("$minutes min",
                                      style: GoogleFonts.poppins(
                                          color: controller.selectedDuration.value == minutes
                                              ? Colors.white
                                              : Color(0xFF072A40)
                                      )),
                                  SizedBox(height: 4),
                                  Text(
                                    "PKR ${price.toInt()}",
                                    style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: controller.selectedDuration.value == minutes
                                            ? Colors.white
                                            : Colors.green[700],
                                        fontWeight: FontWeight.bold
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            selected: controller.selectedDuration.value == minutes,
                            onSelected: (_) => controller.selectedDuration.value = minutes,
                            selectedColor: Color(0xFF072A40),
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(color: Color(0xFF072A40)),
                            ),
                            labelPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            selectedShadowColor: Colors.transparent,
                            checkmarkColor: Colors.white,
                          );
                        }).toList(),
                      );
                    }),
                  ],
                ),
              ),
              SizedBox(height: 24),

              // Time Slot Selection
              FadeIn(
                duration: Duration(milliseconds: 1000),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Select Time Slot",
                        style: GoogleFonts.poppins(
                            color: Color(0xFF072A40),
                            fontWeight: FontWeight.w600,
                            fontSize: 16
                        )),
                    SizedBox(height: 12),
                    Obx(() => Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: timeSlots.map((time) {
                        final isAvailable = controller.availableTimesPerCourt[controller.selectedCourtIndex.value]?.contains(time) ?? false;

                        return ChoiceChip(
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.circle,
                                  color: isAvailable ? Colors.green : Colors.red,
                                  size: 10),
                              SizedBox(width: 6),
                              Text(time,
                                  style: GoogleFonts.poppins(
                                      color: controller.selectedTime.value == time
                                          ? Colors.white
                                          : Color(0xFF072A40)
                                  )),
                            ],
                          ),
                          selected: controller.selectedTime.value == time,
                          onSelected: isAvailable ? (_) => controller.selectedTime.value = time : null,
                          selectedColor: Color(0xFF072A40),
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(color: Color(0xFF072A40)),
                          ),
                          labelPadding: EdgeInsets.symmetric(horizontal: 8),
                          selectedShadowColor: Colors.transparent,
                          checkmarkColor: Colors.white,
                        );
                      }).toList(),
                    )),
                  ],
                ),
              ),
              SizedBox(height: 30),

              // Price and Book Button
              FadeInUp(
                duration: Duration(milliseconds: 1100),
                child: Obx(() {
                  final time = controller.selectedTime.value;
                  final duration = controller.selectedDuration.value;
                  final price = (time != null && duration > 0) ? calculatePrice(time, duration) : 0;

                  return Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          spreadRadius: 2,
                        )
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Total Price",
                                style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[600]
                                )),
                            Text("PKR ${price.toInt()}",
                                style: GoogleFonts.poppins(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF072A40)
                                )),
                          ],
                        ),
                        ElevatedButton(
                          onPressed: time != null
                              ? () => Get.to(() => ConfirmationScreen(price: price.toDouble()))
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF072A40),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          ),
                          child: Text("Book Now",
                              style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600
                              )),
                        ),
                      ],
                    ),
                  );
                }),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  String _getWeekday(int weekday) {
    switch (weekday % 7) {
      case 0: return 'Sun';
      case 1: return 'Mon';
      case 2: return 'Tue';
      case 3: return 'Wed';
      case 4: return 'Thu';
      case 5: return 'Fri';
      case 6: return 'Sat';
      default: return '';
    }
  }

  String _getMonthName(int month) {
    switch (month) {
      case 1: return 'Jan';
      case 2: return 'Feb';
      case 3: return 'Mar';
      case 4: return 'Apr';
      case 5: return 'May';
      case 6: return 'Jun';
      case 7: return 'Jul';
      case 8: return 'Aug';
      case 9: return 'Sep';
      case 10: return 'Oct';
      case 11: return 'Nov';
      case 12: return 'Dec';
      default: return '';
    }
  }
  // Widget _iconButton({required IconData icon, required VoidCallback onTap}) {
  //   return Container(
  //     width: 37.w,
  //     height: 37.w,
  //     decoration: BoxDecoration(
  //       shape: BoxShape.circle,
  //       border: Border.all(color: Colors.grey.shade400, width: 0.5),
  //     ),
  //     child: IconButton(
  //       onPressed: onTap,
  //       icon: Icon(icon, size: 20.sp, color: Colors.black),
  //     ),
  //   );
  // }
}