import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../vendor_models/court_model.dart';

class VendorCourtController extends GetxController {
  final courts = <VendorCourtModel>[].obs;

  final nameCtrl = TextEditingController();
  final locationCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  final startTimeCtrl = TextEditingController();
  final endTimeCtrl = TextEditingController();

  RxList<File> selectedImages = <File>[].obs;

  void pickMultipleImages() async {
    final picker = ImagePicker();
    final picked = await picker.pickMultiImage();
    if (picked.isNotEmpty) {
      selectedImages.addAll(picked.map((xfile) => File(xfile.path)));
    }
  }

  void removeImage(File image) {
    selectedImages.remove(image);
  }

  bool validateFields() {
    if (nameCtrl.text.trim().isEmpty ||
        locationCtrl.text.trim().isEmpty ||
        priceCtrl.text.trim().isEmpty ||
        startTimeCtrl.text.trim().isEmpty ||
        endTimeCtrl.text.trim().isEmpty ||
        selectedImages.isEmpty) {
      Get.snackbar(
        "Validation Error",
        "Please fill all fields and select at least one image.",
      );
      return false;
    }
    return true;
  }

  void addOrUpdateCourt({String? id}) {
    final name = nameCtrl.text.trim();
    final location = locationCtrl.text.trim();
    final price = double.tryParse(priceCtrl.text.trim()) ?? 0.0;
    final start = startTimeCtrl.text.trim();
    final end = endTimeCtrl.text.trim();
    final imagePaths = selectedImages.map((file) => file.path).toList();

    if (id != null) {
      final index = courts.indexWhere((e) => e.id == id);
      if (index != -1) {
        courts[index] = VendorCourtModel(
          id: id,
          name: name,
          location: location,
          price: price,
          isApproved: courts[index].isApproved,
          imageUrls: imagePaths,
          startTime: start,
          endTime: end,
        );
      }
    } else {
      final newCourt = VendorCourtModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        location: location,
        price: price,
        imageUrls: imagePaths,
        startTime: start,
        endTime: end,
      );
      courts.add(newCourt);
    }

    clearForm();
    update();
  }

  void populateForEdit(VendorCourtModel court) {
    nameCtrl.text = court.name;
    locationCtrl.text = court.location;
    priceCtrl.text = court.price.toString();
    startTimeCtrl.text = court.startTime;
    endTimeCtrl.text = court.endTime;
    selectedImages.value = court.imageUrls.map((path) => File(path)).toList();
  }

  void clearForm() {
    nameCtrl.clear();
    locationCtrl.clear();
    priceCtrl.clear();
    startTimeCtrl.clear();
    endTimeCtrl.clear();
    selectedImages.clear();
  }
}
