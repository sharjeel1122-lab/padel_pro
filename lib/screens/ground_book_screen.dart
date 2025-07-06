import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../model/ground_model.dart';
import '../controllers/booknow_controller.dart';


class GroundBookingScreen extends StatefulWidget {
  final Ground ground;
  const GroundBookingScreen({super.key, required this.ground});

  @override
  State<GroundBookingScreen> createState() => _GroundBookingScreenState();
}

class _GroundBookingScreenState extends State<GroundBookingScreen> {
  DateTime selectedDate = DateTime.now();
  String? selectedSlot;

  final List<String> timeSlots = [
    '08:00 AM - 10:00 AM',
    '10:30 AM - 12:30 PM',
    '01:00 PM - 03:00 PM',
    '04:00 PM - 06:00 PM',
    '07:00 PM - 09:00 PM',
  ];

  final bookingCtrl = Get.put(BookingController());

  @override
  Widget build(BuildContext context) {
    final dateKey = DateFormat('yyyy-MM-dd').format(selectedDate);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Book ${widget.ground.title}', style: GoogleFonts.poppins()),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Select Date", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 30)),
                  builder: (context, child) {
                    return Theme(
                      data: ThemeData.light().copyWith(
                        colorScheme: const ColorScheme.light(
                          primary: Colors.green,
                          onPrimary: Colors.black,
                          onSurface: Colors.black,
                        ),
                        dialogBackgroundColor: Colors.white,
                        textButtonTheme: TextButtonThemeData(
                          style: TextButton.styleFrom(foregroundColor: Colors.black),
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (picked != null) {
                  setState(() => selectedDate = picked);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(DateFormat.yMMMMd().format(selectedDate), style: GoogleFonts.poppins(fontSize: 14)),
                    const Icon(Icons.calendar_today, size: 18),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
            Text("Select Time Slot", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),

            Obx(() {
              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: timeSlots.map((slot) {
                  final isSelected = selectedSlot == slot;
                  final isBooked = bookingCtrl.isSlotBooked(dateKey, slot);

                  return Stack(
                    children: [
                      GestureDetector(
                        onTap: isBooked
                            ? null
                            : () {
                          setState(() => selectedSlot = slot);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF91E208) : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(10),
                            border: isSelected
                                ? Border.all(color: Colors.black, width: 1)
                                : Border.all(color: Colors.transparent),
                          ),
                          child: Text(
                            slot,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: isBooked ? Colors.red : Colors.black,
                            ),
                          ),
                        ),
                      ),

                      if (isBooked)
                        Positioned(
                          top: 4,
                          right: 4,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  );
                }).toList(),
              );
            }),

            const Spacer(),

            ElevatedButton(
              onPressed: () {
                if (selectedSlot == null) {
                  Get.snackbar("Missing", "Please select a time slot.");
                  return;
                }

                bookingCtrl.book(dateKey, selectedSlot!);

                // 🎉 Show thank you dialog
                Get.dialog(
                  Dialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_circle_outline, color: Colors.green, size: 60),
                          const SizedBox(height: 10),
                          Text(
                            "Thank You!",
                            style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Your booking for ${widget.ground.title} on ${DateFormat.yMMMd().format(selectedDate)} at $selectedSlot has been confirmed.",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700]),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              selectedSlot = null;
                              Get.back(); // Close dialog
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF91E208),
                              minimumSize: const Size(double.infinity, 45),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: Text("Another Booking", style: GoogleFonts.poppins(color: Colors.black)),
                          ),
                          const SizedBox(height: 10),
                          OutlinedButton(
                            onPressed: () {
                              Get.back(); // close dialog
                              Get.back(); // go back to home
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.black),
                              minimumSize: const Size(double.infinity, 45),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: Text("Go to Home", style: GoogleFonts.poppins(color: Colors.black)),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF91E208),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('Confirm Booking', style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.w500)),
            )
          ],
        ),
      ),
    );
  }
}
