// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:google_fonts/google_fonts.dart';
// import '../controllers/booking controller/booking_controller.dart';
//
// class BookingNotificationScreen extends StatelessWidget {
//   final BookingController bookingController = Get.put(BookingController());
//
//   BookingNotificationScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Booking Notifications", style: GoogleFonts.poppins()),
//         backgroundColor: const Color(0xFF28844B),
//       ),
//       body: Obx(() {
//         if (bookingController.isLoading.value) {
//           return const Center(child: CircularProgressIndicator());
//         }
//
//         if (bookingController.bookings.isEmpty) {
//           return const Center(child: Text("No bookings found"));
//         }
//
//         return ListView.builder(
//           itemCount: bookingController.bookings.length,
//           itemBuilder: (context, index) {
//             final booking = bookingController.bookings[index];
//             return Card(
//               margin: const EdgeInsets.all(10),
//               elevation: 4,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(15),
//               ),
//               child: ListTile(
//                 title: Text(
//                   "User: ${booking.userName}",
//                   style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
//                 ),
//                 subtitle: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text("Email: ${booking.userEmail}",
//                         style: GoogleFonts.poppins()),
//                     Text("Club: ${booking.clubName}",
//                         style: GoogleFonts.poppins()),
//                     Text("Court: ${booking.courtName}",
//                         style: GoogleFonts.poppins()),
//                     Text("Date: ${booking.bookingDate.toLocal().toString().split(' ')[0]}",
//                         style: GoogleFonts.poppins()),
//                   ],
//                 ),
//               ),
//             );
//           },
//         );
//       }),
//     );
//   }
// }
