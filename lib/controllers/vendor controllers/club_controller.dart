// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:padel_pro/model/club_model.dart';
//
//
// class ClubController extends GetxController {
//
//
//   // Reactive variables
//   var isLoading = false.obs;
//   var clubs = <Club>[].obs;
//   var selectedImages = <XFile>[].obs;
//   var selectedFacilities = <String>[].obs;
//
//   // Form controllers
//   var nameCtrl = TextEditingController();
//   var descriptionCtrl = TextEditingController();
//   var addressCtrl = TextEditingController();
//   var cityCtrl = TextEditingController();
//   var phoneCtrl = TextEditingController();
//   var emailCtrl = TextEditingController();
//   var websiteCtrl = TextEditingController();
//
//   @override
//   void onInit() {
//     fetchVendorClubs();
//     super.onInit();
//   }
//
//   Future<void> fetchVendorClubs() async {
//     try {
//       isLoading(true);
//       final result = await _clubApi.getVendorClubs();
//       clubs.assignAll(result);
//     } finally {
//       isLoading(false);
//     }
//   }
//
//   Future<void> pickMultipleImages() async {
//     try {
//       final images = await ImagePicker().pickMultiImage(
//         maxWidth: 1000,
//         maxHeight: 1000,
//         imageQuality: 90,
//       );
//       if (images != null) {
//         selectedImages.addAll(images);
//       }
//     } catch (e) {
//       Get.snackbar('Error', 'Failed to pick images: ${e.toString()}');
//     }
//   }
//
//   void removeImage(XFile file) {
//     selectedImages.remove(file);
//   }
//
//   Future<void> createClub() async {
//     try {
//       isLoading(true);
//       final newClub = Club(
//         name: nameCtrl.text,
//         description: descriptionCtrl.text,
//         location: Location(
//           address: addressCtrl.text,
//           city: cityCtrl.text,
//         ),
//         contact: Contact(
//           phone: phoneCtrl.text,
//           email: emailCtrl.text,
//           website: websiteCtrl.text,
//         ),
//         facilities: selectedFacilities.toList(),
//         photos: selectedImages.map((e) => e.path).toList(),
//         courts: [],
//         vendorId: 'current_vendor_id', id: '', address: '', startingPrice: null, // Replace with actual vendor ID
//       );
//
//       await _clubApi.createClub(newClub);
//       Get.back();
//       Get.snackbar('Success', 'Club created successfully!',
//         backgroundColor: Colors.green,
//         colorText: Colors.white,
//       );
//       fetchVendorClubs();
//     } catch (e) {
//       Get.snackbar('Error', 'Failed to create club: ${e.toString()}');
//     } finally {
//       isLoading(false);
//     }
//   }
//
//   void toggleFacility(String facility) {
//     if (selectedFacilities.contains(facility)) {
//       selectedFacilities.remove(facility);
//     } else {
//       selectedFacilities.add(facility);
//     }
//   }
//
//   @override
//   void onClose() {
//     nameCtrl.dispose();
//     descriptionCtrl.dispose();
//     addressCtrl.dispose();
//     cityCtrl.dispose();
//     phoneCtrl.dispose();
//     emailCtrl.dispose();
//     websiteCtrl.dispose();
//     super.onClose();
//   }
// }