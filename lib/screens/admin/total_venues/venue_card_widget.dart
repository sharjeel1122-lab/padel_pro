// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:padel_pro/screens/admin/total_venues/edit_venue_screen.dart';
// import '../../../model/court_model.dart';
//
//
// class VenueCardWidget extends StatelessWidget {
//   final VenueModel venue;
//   final VoidCallback onEdit;
//   final VoidCallback onDeleteConfirmed;
//
//
//   const VenueCardWidget({
//     super.key,
//     required this.venue,
//     required this.onEdit,
//     required this.onDeleteConfirmed,
//   });
//
//   void _confirmDelete(BuildContext context) {
//     Get.defaultDialog(
//       backgroundColor: const Color(0xFF0A3B5C),
//       title: "Confirm Delete",
//       titleStyle: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
//       content: Text("Are you sure you want to delete this venue?",
//           style: GoogleFonts.poppins(color: Colors.white70)),
//       confirm: TextButton(
//         onPressed: () {
//           Get.back();
//           onDeleteConfirmed();
//         },
//         child: const Text("Delete", style: TextStyle(color: Colors.redAccent)),
//       ),
//       cancel: TextButton(
//         onPressed: () => Get.back(),
//         child: const Text("Cancel", style: TextStyle(color: Colors.white)),
//       ),
//     );
//   }
//
//   void _navigateToEdit() {
//     Get.to(() => EditVenueScreen(venue: venue));
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       color: const Color(0xFF0A3B5C),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(venue.name,
//                 style: GoogleFonts.poppins(
//                     fontWeight: FontWeight.w600, color: Colors.white)),
//             const SizedBox(height: 4),
//             Text("Location: ${venue.location}", style: const TextStyle(color: Colors.white70)),
//             Text("Price: Rs. ${venue.price}", style: const TextStyle(color: Colors.white70)),
//             Text("Time: ${venue.startTime} - ${venue.endTime}", style: const TextStyle(color: Colors.white70)),
//             const SizedBox(height: 10),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 IconButton(
//                   onPressed: _navigateToEdit,
//                   icon: const Icon(Icons.edit, color: Colors.orangeAccent, size: 20),
//                 ),
//                 IconButton(
//                   onPressed: () => _confirmDelete(context),
//                   icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20),
//                 ),
//               ],
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
