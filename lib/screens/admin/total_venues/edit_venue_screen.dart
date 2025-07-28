// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:google_fonts/google_fonts.dart';
// import '../../../model/court_model.dart';
//
// class EditVenueScreen extends StatefulWidget {
//   final VenueModel venue;
//
//   const EditVenueScreen({super.key, required this.venue});
//
//   @override
//   State<EditVenueScreen> createState() => _EditVenueScreenState();
// }
//
// class _EditVenueScreenState extends State<EditVenueScreen> {
//   final _formKey = GlobalKey<FormState>();
//   late TextEditingController titleController;
//   late TextEditingController locationController;
//   late TextEditingController priceController;
//   late TextEditingController startTimeController;
//   late TextEditingController endTimeController;
//
//   @override
//   void initState() {
//     super.initState();
//     titleController = TextEditingController(text: widget.venue.name);
//     locationController = TextEditingController(text: widget.venue.location);
//     priceController = TextEditingController(text: widget.venue.price.toString());
//     startTimeController = TextEditingController(text: widget.venue.startTime);
//     endTimeController = TextEditingController(text: widget.venue.endTime);
//   }
//
//   @override
//   void dispose() {
//     titleController.dispose();
//     locationController.dispose();
//     priceController.dispose();
//     startTimeController.dispose();
//     endTimeController.dispose();
//     super.dispose();
//   }
//
//   void _submit() {
//     if (_formKey.currentState!.validate()) {
//       // You can update the venue to backend/database here
//       Get.back();
//       Get.snackbar("Updated", "Venue updated successfully!",
//           backgroundColor: Colors.green, colorText: Colors.white);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF072A40),
//       appBar: AppBar(
//         backgroundColor: const Color(0xFF0A3B5C),
//         title: const Text("Edit Venue", style: TextStyle(color: Colors.white)),
//         leading: const BackButton(color: Colors.white),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Form(
//           key: _formKey,
//           child: ListView(
//             children: [
//               _buildField("Title", titleController),
//               _buildField("Location", locationController),
//               _buildField("Price", priceController, isNumber: true),
//               _buildField("Start Time", startTimeController),
//               _buildField("End Time", endTimeController),
//               const SizedBox(height: 30),
//               ElevatedButton(
//                 onPressed: _submit,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFF0A3B5C),
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                 ),
//                 child: Text("Update",
//                     style: GoogleFonts.poppins(color: Colors.white, fontSize: 16)),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildField(String label, TextEditingController controller, {bool isNumber = false}) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 16),
//       child: TextFormField(
//         controller: controller,
//         keyboardType: isNumber ? TextInputType.number : TextInputType.text,
//         style: const TextStyle(color: Colors.white),
//         decoration: InputDecoration(
//           labelText: label,
//           labelStyle: const TextStyle(color: Colors.white70),
//           enabledBorder: const UnderlineInputBorder(
//               borderSide: BorderSide(color: Colors.white30)),
//           focusedBorder: const UnderlineInputBorder(
//               borderSide: BorderSide(color: Colors.white)),
//         ),
//         validator: (value) => value == null || value.isEmpty ? 'Required' : null,
//       ),
//     );
//   }
// }
