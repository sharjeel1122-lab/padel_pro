import 'dart:convert';
import 'package:padel_pro/screens/vendor/vendor%20data%20controller/vendor_data_controller.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../admin/controllers/dashboard_controller.dart';

class Pricing {
  final TextEditingController priceController = TextEditingController();
  int duration = 60; // Default duration in minutes

  Map<String, dynamic> toJson() => {
    'duration': duration,
    'price': int.tryParse(priceController.text) ?? 0,
  };

  void dispose() {
    priceController.dispose();
  }
}

class PeakHours {
  final TextEditingController startTimeController = TextEditingController();
  final TextEditingController endTimeController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  Map<String, dynamic> toJson() => {
    'startTime': startTimeController.text,
    'endTime': endTimeController.text,
    'price': int.tryParse(priceController.text) ?? 0,
  };

  void dispose() {
    startTimeController.dispose();
    endTimeController.dispose();
    priceController.dispose();
  }
}

class Court {
  final TextEditingController courtNumberController = TextEditingController();
  final TextEditingController courtTypeController = TextEditingController();
  final RxList<Pricing> pricingList = <Pricing>[Pricing()].obs;
  final RxList<PeakHours> peakHoursList = <PeakHours>[].obs;


  Map<String, dynamic> toJson() => {
    'courtName': courtNumberController.text,
    'courtType': [courtTypeController.text],
    'pricing': pricingList.map((p) => p.toJson()).toList(),
    'peakHours': peakHoursList.map((p) => p.toJson()).toList(),
  };

  void dispose() {
    courtNumberController.dispose();
    courtTypeController.dispose();
    for (var pricing in pricingList) {
      pricing.dispose();
    }
    for (var peakHours in peakHoursList) {
      peakHours.dispose();
    }
  }
}

// class Court {
//   final TextEditingController courtNumberController = TextEditingController();
//   final TextEditingController courtTypeController = TextEditingController();
//   final RxList<Pricing> pricingList = <Pricing>[Pricing()].obs;
//   final RxList<PeakHours> peakHoursList = <PeakHours>[].obs;
//
//   Map<String, dynamic> toJson() => {
//     'courtNumber': courtNumberController.text,
//     'courtType': courtTypeController.text,
//     'pricing': pricingList.map((p) => p.toJson()).toList(),
//     'peakHours': peakHoursList.map((p) => p.toJson()).toList(),
//   };
//
//   void dispose() {
//     courtNumberController.dispose();
//     courtTypeController.dispose();
//     for (var pricing in pricingList) {
//       pricing.dispose();
//     }
//     for (var peakHours in peakHoursList) {
//       peakHours.dispose();
//     }
//   }
// }

class CreatePlaygroundController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  var isSubmitting = false.obs;
  final maxImages = 10;

  // Field controllers
  final nameC = TextEditingController();
  final sizeC = TextEditingController();
  final numberOfCourtsC = TextEditingController();
  final priceC = TextEditingController();
  final openingTimeC = TextEditingController();
  final closingTimeC = TextEditingController();
  final descriptionC = TextEditingController();
  final websiteC = TextEditingController();
  final phoneC = TextEditingController();
  final locationC = TextEditingController();
  final cityC = TextEditingController();
  final newFacilityC = TextEditingController();

  // Reactive state
  final RxList<XFile> selectedImages = <XFile>[].obs;
  final RxList<String> facilities = <String>[].obs;
  final RxList<Court> courts = <Court>[Court()].obs;

  // Image picking with validation
  Future<void> pickImages() async {
    try {
      final List<XFile>? pickedFiles = await _picker.pickMultiImage(
        maxWidth: 2000,
        maxHeight: 2000,
        imageQuality: 85,
      );

      if (pickedFiles != null) {
        final allowedExtensions = ['jpg', 'jpeg', 'png'];
        final validImages = pickedFiles.where((file) {
          final ext = file.path.split('.').last.toLowerCase();
          return allowedExtensions.contains(ext);
        }).toList();

        if (validImages.length != pickedFiles.length) {
          Get.snackbar(
            'Unsupported Format',
            'Only JPG, JPEG, and PNG images are allowed.',
            backgroundColor: Colors.orange,
            colorText: Colors.white,
          );
        }

        if (selectedImages.length + validImages.length > maxImages) {
          Get.snackbar(
            'Maximum Limit Reached',
            'You can only upload up to $maxImages images.',
            backgroundColor: Colors.orange,
            colorText: Colors.white,
          );
          return;
        }

        selectedImages.addAll(validImages);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick images: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Facility management
  void addFacility() {
    final facility = newFacilityC.text.trim();
    if (facility.isNotEmpty) {
      if (!facilities.contains(facility)) {
        facilities.add(facility);
        newFacilityC.clear();
      } else {
        Get.snackbar(
          'Duplicate Facility',
          '$facility is already added',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
    }
  }

  void removeFacility(String facility) => facilities.remove(facility);

  // Court management
  void addCourt() => courts.add(Court());

  void removeCourt(int index) {
    if (courts.length > 1) {
      courts[index].dispose();
      courts.removeAt(index);
    } else {
      Get.snackbar(
        'Minimum Courts',
        'At least one court is required',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    }
  }

  // Pricing management
  void addPricingToCourt(int courtIndex) => courts[courtIndex].pricingList.add(Pricing());

  void removePricingFromCourt(int courtIndex, int pricingIndex) {
    if (courts[courtIndex].pricingList.length > 1) {
      courts[courtIndex].pricingList.removeAt(pricingIndex);
    } else {
      Get.snackbar(
        'Minimum Pricing',
        'At least one pricing option is required',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    }
  }

  // Peak hours management
  void addPeakHoursToCourt(int courtIndex) => courts[courtIndex].peakHoursList.add(PeakHours());

  void removePeakHoursFromCourt(int courtIndex, int peakHoursIndex) {
    courts[courtIndex].peakHoursList.removeAt(peakHoursIndex);
  }

  // Image management
  void removeImage(int index) => selectedImages.removeAt(index);

  // Form submission

  // ... (controller ke baaqi functions)

// Form submission

  Future<void> submitForm() async {
    try {
      if (!formKey.currentState!.validate()) {
        throw 'Please fill all required fields correctly';
      }

      if (selectedImages.isEmpty) {
        throw 'Please select at least one photo';
      }

      for (var court in courts) {
        if (court.courtNumberController.text.isEmpty) {
          throw 'Court name is required for all courts';
        }
      }

      isSubmitting.value = true;

      final playgroundData = {
        'name': nameC.text.trim(),
        'size': sizeC.text.trim(),
        'price': int.tryParse(priceC.text.trim()) ?? 0,
        'openingTime': openingTimeC.text.trim(),
        'closingTime': closingTimeC.text.trim(),
        'description': descriptionC.text.trim(),
        'website': websiteC.text.trim(),
        'phoneNumber': phoneC.text.trim(),
        'location': locationC.text.trim(),
        'city': cityC.text.trim(),
        'numberofCourts': courts.length, // backend expects lowercase 'n'
        'facilities': jsonEncode(facilities.toList()), // stringified for multipart
        'courts': jsonEncode(courts.map((c) => c.toJson()).toList()), // stringified for multipart
      };

      final photoPaths = selectedImages.map((file) => file.path).toList();



      clearForm();
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isSubmitting.value = false;
    }
  }


//   Future<void> submitForm() async {
//     try {
//       if (!formKey.currentState!.validate()) {
//         throw 'Please fill all required fields correctly';
//       }
//
//       if (selectedImages.isEmpty) {
//         throw 'Please select at least one photo';
//       }
//
//
//       for (var court in courts) {
//         if (court.courtNumberController.text.isEmpty) {
//           throw 'Court name is required for all courts';
//         }
//         //
//       }
//
//       isSubmitting.value = true;
//
//
//       final playgroundData = {
//         'name': nameC.text.trim(),
//         'size': sizeC.text.trim(),
//         'price': int.tryParse(priceC.text.trim()) ?? 0,
//         'openingTime': openingTimeC.text.trim(),
//         'closingTime': closingTimeC.text.trim(),
//         'description': descriptionC.text.trim(),
//         'website': websiteC.text.trim(),
//         'phoneNumber': phoneC.text.trim(),
//         'location': locationC.text.trim(),
//         'city': cityC.text.trim(),
//         'facilities': facilities.toList(),
//         // 'facilities': jsonEncode(facilities.toList()),
//         'courts': courts.map((c) => c.toJson()).toList(),
//         // 'courts': jsonEncode(courts.map((c) => c.toJson()).toList()),
//       };
//
//       final photoPaths = selectedImages.map((file) => file.path).toList();
//
//       final dashboardController = Get.find<DashboardController>();
//       await dashboardController.createNewPlayground(playgroundData, photoPaths);
//
//
//       clearForm();
//
//     } catch (e) {
//       Get.snackbar(
//         'Error',
//         e.toString(),
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//     } finally {
//       isSubmitting.value = false;
//     }
//   }


  // Future<void> submitForm() async {
  //   try {
  //     if (!formKey.currentState!.validate()) {
  //       throw 'Please fill all required fields correctly';
  //     }
  //
  //     if (selectedImages.isEmpty) {
  //       throw 'Please select at least one photo';
  //     }
  //
  //     // Validate courts and pricing
  //     for (var court in courts) {
  //       if (court.courtNumberController.text.isEmpty) {
  //         throw 'Court number is required for all courts';
  //       }
  //       if (court.courtTypeController.text.isEmpty) {
  //         throw 'Court type is required for all courts';
  //       }
  //       for (var pricing in court.pricingList) {
  //         if (pricing.priceController.text.isEmpty) {
  //           throw 'Price is required for all pricing options';
  //         }
  //       }
  //       for (var peakHours in court.peakHoursList) {
  //         if (peakHours.startTimeController.text.isEmpty ||
  //             peakHours.endTimeController.text.isEmpty ||
  //             peakHours.priceController.text.isEmpty) {
  //           throw 'All fields are required for peak hours';
  //         }
  //       }
  //     }
  //
  //     isSubmitting.value = true;
  //
  //     final playgroundData = {
  //       'name': nameC.text.trim(),
  //       'size': sizeC.text.trim(),
  //       // 'numberOfCourts': int.tryParse(numberOfCourtsC.text.trim()) ?? 1,
  //       'price': int.tryParse(priceC.text.trim()) ?? 0,
  //       'openingTime': openingTimeC.text.trim(),
  //       'closingTime': closingTimeC.text.trim(),
  //       'description': descriptionC.text.trim(),
  //       'website': websiteC.text.trim(),
  //       'phoneNumber': phoneC.text.trim(),
  //       'location': locationC.text.trim(),
  //       'city': cityC.text.trim(),
  //       'facilities': jsonEncode(facilities.toList()),
  //       'courts': jsonEncode(courts.map((c) => c.toJson()).toList()),
  //     };
  //
  //     final photoPaths = selectedImages.map((file) => file.path).toList();
  //
  //     final dashboardController = Get.find<DashboardController>();
  //     await dashboardController.createNewPlayground(playgroundData, photoPaths);
  //
  //     // Clear form after successful submission
  //     clearForm();
  //
  //   } catch (e) {
  //     Get.snackbar(
  //       'Error',
  //       e.toString(),
  //       backgroundColor: Colors.red,
  //       colorText: Colors.white,
  //     );
  //   } finally {
  //     isSubmitting.value = false;
  //   }
  // }

  // Form clearing
  void clearForm() {
    nameC.clear();
    sizeC.clear();
    numberOfCourtsC.clear();
    priceC.clear();
    descriptionC.clear();
    openingTimeC.clear();
    closingTimeC.clear();
    locationC.clear();
    cityC.clear();
    phoneC.clear();
    websiteC.clear();
    newFacilityC.clear();
    facilities.clear();
    selectedImages.clear();

    // Dispose all courts and create a new one
    for (var court in courts) {
      court.dispose();
    }
    courts.clear();
    courts.add(Court());
  }

  @override
  void onClose() {
    // Dispose all controllers
    nameC.dispose();
    sizeC.dispose();
    numberOfCourtsC.dispose();
    priceC.dispose();
    openingTimeC.dispose();
    closingTimeC.dispose();
    descriptionC.dispose();
    websiteC.dispose();
    phoneC.dispose();
    locationC.dispose();
    cityC.dispose();
    newFacilityC.dispose();

    // Dispose all courts and their pricing/peak hours
    for (var court in courts) {
      court.dispose();
    }

    super.onClose();
  }
}