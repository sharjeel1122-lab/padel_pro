// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
//
// import '../data models/vendor_data_model.dart';
// import '../vendor data controller/vendor_data_controller.dart';
//
// void showAddEditClubDialog(BuildContext context, {Club? club}) {
//   final _formKey = GlobalKey<FormState>();
//   final nameController = TextEditingController(text: club?.name);
//   final locationController = TextEditingController(text: club?.location);
//   final DataController dataController = Get.find();
//
//   Get.dialog(
//     AlertDialog(
//       title: Text(club == null ? 'Naya Club Add Karein' : 'Club Edit Karein'),
//       content: Form(
//         key: _formKey,
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             TextFormField(
//               controller: nameController,
//               decoration: const InputDecoration(labelText: 'Club ka Naam'),
//               validator: (value) => (value?.isEmpty ?? true) ? 'Naam zaroori hai' : null,
//             ),
//             const SizedBox(height: 16),
//             TextFormField(
//               controller: locationController,
//               decoration: const InputDecoration(labelText: 'Location'),
//               validator: (value) => (value?.isEmpty ?? true) ? 'Location zaroori hai' : null,
//             ),
//           ],
//         ),
//       ),
//       actions: [
//         TextButton(onPressed: Get.back, child: const Text('Cancel')),
//         ElevatedButton(
//           onPressed: () {
//             if (_formKey.currentState!.validate()) {
//               dataController.addOrUpdateClub(
//                 existingClub: club,
//                 name: nameController.text,
//                 location: locationController.text,
//               );
//               Get.back();
//             }
//           },
//           child: Text(club == null ? 'Save' : 'Update'),
//         ),
//       ],
//     ),
//   );
// }