// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
//
// import '../data models/vendor_data_model.dart';
// import '../vendor data controller/vendor_data_controller.dart';
//
// void showAddEditCourtDialog(BuildContext context, {required String clubId, Court? court}) {
//   final _formKey = GlobalKey<FormState>();
//   final nameController = TextEditingController(text: court?.name);
//   final DataController dataController = Get.find();
//
//   Get.dialog(
//     AlertDialog(
//       title: Text(court == null ? 'Naya Court Add Karein' : 'Court Edit Karein'),
//       content: Form(
//         key: _formKey,
//         child: TextFormField(
//           controller: nameController,
//           decoration: const InputDecoration(
//             labelText: 'Court ka Naam',
//             hintText: 'e.g., Tennis Court 1 (Clay)',
//           ),
//           validator: (value) => (value?.isEmpty ?? true) ? 'Naam zaroori hai' : null,
//         ),
//       ),
//       actions: [
//         TextButton(onPressed: Get.back, child: const Text('Cancel')),
//         ElevatedButton(
//           onPressed: () {
//             if (_formKey.currentState!.validate()) {
//               dataController.addOrUpdateCourt(
//                 existingCourt: court,
//                 name: nameController.text,
//                 clubId: clubId,
//               );
//               Get.back();
//             }
//           },
//           child: Text(court == null ? 'Save' : 'Update'),
//         ),
//       ],
//     ),
//   );
// }