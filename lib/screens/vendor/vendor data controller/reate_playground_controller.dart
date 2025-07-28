import 'dart:convert';
import 'package:padel_pro/screens/vendor/vendor%20data%20controller/vendor_data_controller.dart';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// Helper models to make the court structure easier to manage
class Pricing {
  final TextEditingController priceController = TextEditingController();
  int duration = 60; // Default duration

  Map<String, dynamic> toJson() => {
    'duration': duration,
    'price': int.tryParse(priceController.text) ?? 0,
  };
}

class Court {
  final TextEditingController courtNumberController = TextEditingController();
  final TextEditingController courtTypeController = TextEditingController();
  final RxList<Pricing> pricingList = <Pricing>[Pricing()].obs; // Start with one pricing option

  Map<String, dynamic> toJson() => {
    'courtNumber': courtNumberController.text,
    'courtType': courtTypeController.text,
    'pricing': pricingList.map((p) => p.toJson()).toList(),
  };
}

class CreatePlaygroundController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  // Controllers for simple fields
  final nameC = TextEditingController();
  final sizeC = TextEditingController();
  final openingTimeC = TextEditingController();
  final closingTimeC = TextEditingController();
  final descriptionC = TextEditingController();
  final websiteC = TextEditingController();
  final phoneC = TextEditingController();
  final locationC = TextEditingController();
  final cityC = TextEditingController();

  // State for dynamic lists
  final RxList<XFile> selectedImages = <XFile>[].obs;
  final RxList<String> facilities = <String>[].obs;
  final RxList<Court> courts = <Court>[Court()].obs; // Start with one court

  // Method to pick images from the gallery
  // Method to pick images from the gallery
  Future<void> pickImages() async {
    final ImagePicker picker = ImagePicker();

    final List<XFile>? pickedFiles = await picker.pickMultiImage(); // only picks image/*

    if (pickedFiles != null) {
      final allowedExtensions = ['jpg', 'jpeg', 'png', 'gif'];
      final validImages = pickedFiles.where((file) {
        final ext = file.path.split('.').last.toLowerCase();
        return allowedExtensions.contains(ext);
      }).toList();

      if (validImages.length != pickedFiles.length) {
        Get.snackbar(
          'Unsupported Format',
          'Only JPG, JPEG, PNG, and GIF images are allowed.',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }

      selectedImages.clear();
      selectedImages.addAll(validImages);
      update(); // refresh UI
    }
  }



  // Methods to manage facilities
  void addFacility(String facility) {
    if (facility.isNotEmpty && !facilities.contains(facility)) {
      facilities.add(facility);
    }
  }
  void removeFacility(String facility) => facilities.remove(facility);

  // Methods to manage courts
  void addCourt() => courts.add(Court());
  void removeCourt(int index) => courts.removeAt(index);

  // Methods to manage pricing within a court
  void addPricingToCourt(int courtIndex) => courts[courtIndex].pricingList.add(Pricing());
  void removePricingFromCourt(int courtIndex, int pricingIndex) => courts[courtIndex].pricingList.removeAt(pricingIndex);


  // Final submission method
  void submitForm() {
    // 1. Validate the form
    if (!formKey.currentState!.validate()) {
      Get.snackbar('Validation Error', 'Please fill all required fields correctly.');
      return;
    }
    if (selectedImages.isEmpty) {
      Get.snackbar('Validation Error', 'Please select at least one photo.');
      return;
    }

    // 2. Prepare data payload
    final Map<String, dynamic> playgroundData = {
      'name': nameC.text,
      'size': sizeC.text,
      'openingTime': openingTimeC.text,
      'closingTime': closingTimeC.text,
      'description': descriptionC.text,
      'website': websiteC.text,
      'phoneNumber': phoneC.text,
      'location': locationC.text,
      'city': cityC.text,
      // The backend expects these as JSON strings
      'facilities': jsonEncode(facilities.toList()),
      'courts': jsonEncode(courts.map((c) => c.toJson()).toList()),
    };

    final List<String> photoPaths = selectedImages.map((file) => file.path).toList();

    // 3. Call the DashboardController to handle the API call
    final dashboardController = Get.find<DashboardController>();
    dashboardController.createNewPlayground(playgroundData, photoPaths);
  }

  @override
  void onClose() {
    // Dispose all controllers
    nameC.dispose();
    sizeC.dispose();
    openingTimeC.dispose();
    closingTimeC.dispose();
    descriptionC.dispose();
    websiteC.dispose();
    phoneC.dispose();
    locationC.dispose();
    cityC.dispose();
    for (var court in courts) {
      court.courtNumberController.dispose();
      court.courtTypeController.dispose();
      for (var pricing in court.pricingList) {
        pricing.priceController.dispose();
      }
    }
    super.onClose();
  }

  void removeImage(int index) {
    selectedImages.removeAt(index);
  }

}