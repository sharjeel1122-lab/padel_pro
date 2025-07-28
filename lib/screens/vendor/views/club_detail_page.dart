// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:padel_pro/screens/vendor/vendor%20data%20controller/vendor_data_controller.dart';
// import 'package:padel_pro/screens/vendor/views/courts_view.dart';
// import 'package:padel_pro/screens/vendor/widgets/show_addedit_courtdialog.dart';
// import 'package:padel_pro/screens/vendor/widgets/show_delete_confirmation.dart';
//
// import '../data models/vendor_data_model.dart';
//
// class ClubDetailsScreen extends StatelessWidget {
//   final Club club;
//   ClubDetailsScreen({Key? key, required this.club}) : super(key: key);
//
//   final DataController controller = Get.find();
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(club.name, style: Get.textTheme.titleLarge?.copyWith(fontSize: 24)),
//             Text(club.location, style: Get.textTheme.bodyMedium),
//           ],
//         ),
//         toolbarHeight: 80,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text('Club ke Courts', style: Get.textTheme.titleLarge?.copyWith(fontSize: 22)),
//                 ElevatedButton.icon(
//                   icon: const Icon(Icons.add_circle_outline),
//                   label: const Text('Naya Court'),
//                   onPressed: () {
//                     showAddEditCourtDialog(context, clubId: club.id);
//                   },
//                 ),
//               ],
//             ),
//             const SizedBox(height: 20),
//             Expanded(
//               // Obx rebuilds when the list of courts changes
//               child: Obx(() {
//                 final courtsForClub = controller.getCourtsForClub(club.id);
//                 if (courtsForClub.isEmpty) {
//                   return const Center(
//                     child: Text('Is club mein koi court add nahi kiya gaya.'),
//                   );
//                 }
//                 return Card(
//                   elevation: 4,
//                   child: ListView.separated(
//                     itemCount: courtsForClub.length,
//                     separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey[700]),
//                     itemBuilder: (context, index) {
//                       final court = courtsForClub[index];
//                       return CourtListTile(
//                         court: court,
//                         onEdit: () => showAddEditCourtDialog(context, clubId: club.id, court: court),
//                         onDelete: () => showDeleteConfirmation(
//                             context: context,
//                             title: 'Court Delete Karein',
//                             content: 'Kya aap waqai is court ko delete karna chahte hain?',
//                             onConfirm: () => controller.deleteCourt(court.id)
//                         ),
//                       );
//                     },
//                   ),
//                 );
//               }),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }