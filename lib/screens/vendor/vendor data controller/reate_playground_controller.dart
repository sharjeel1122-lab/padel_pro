// import 'dart:convert';
// import 'package:get/get.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:padel_pro/screens/vendor/vendor%20data%20controller/vendor_data_controller.dart';
// import 'package:padel_pro/services/vendors%20api/create_club_courts_api.dart';
//
//
// class Pricing {
//   final TextEditingController priceController = TextEditingController();
//   int duration = 60; // Default duration in minutes
//
//   Map<String, dynamic> toJson() => {
//     'duration': duration,
//     'price': int.tryParse(priceController.text) ?? 0,
//   };
//
//   void dispose() {
//     priceController.dispose();
//   }
// }
//
// class PeakHours {
//   final TextEditingController startTimeController = TextEditingController();
//   final TextEditingController endTimeController = TextEditingController();
//   final TextEditingController priceController = TextEditingController();
//
//   Map<String, dynamic> toJson() => {
//     'startTime': startTimeController.text,
//     'endTime': endTimeController.text,
//     'price': int.tryParse(priceController.text) ?? 0,
//   };
//
//   void dispose() {
//     startTimeController.dispose();
//     endTimeController.dispose();
//     priceController.dispose();
//   }
// }
//
// class Court {
//   final TextEditingController courtNumberController = TextEditingController();
//   final TextEditingController courtTypeController = TextEditingController();
//   final RxList<Pricing> pricingList = <Pricing>[Pricing()].obs;
//   final RxList<PeakHours> peakHoursList = <PeakHours>[].obs;
//
//
//   Map<String, dynamic> toJson() => {
//     'courtName': courtNumberController.text,
//     'courtType': [courtTypeController.text],
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
//
// // class Court {
// //   final TextEditingController courtNumberController = TextEditingController();
// //   final TextEditingController courtTypeController = TextEditingController();
// //   final RxList<Pricing> pricingList = <Pricing>[Pricing()].obs;
// //   final RxList<PeakHours> peakHoursList = <PeakHours>[].obs;
// //
// //   Map<String, dynamic> toJson() => {
// //     'courtNumber': courtNumberController.text,
// //     'courtType': courtTypeController.text,
// //     'pricing': pricingList.map((p) => p.toJson()).toList(),
// //     'peakHours': peakHoursList.map((p) => p.toJson()).toList(),
// //   };
// //
// //   void dispose() {
// //     courtNumberController.dispose();
// //     courtTypeController.dispose();
// //     for (var pricing in pricingList) {
// //       pricing.dispose();
// //     }
// //     for (var peakHours in peakHoursList) {
// //       peakHours.dispose();
// //     }
// //   }
// // }
//
//
//
// class CreatePlaygroundController extends GetxController {
//   final GlobalKey<FormState> formKey = GlobalKey<FormState>();
//   final ImagePicker _picker = ImagePicker();
//   final isSubmitting = false.obs;
//   final maxImages = 10;
//
//   // Field controllers
//   final nameC = TextEditingController();
//   final sizeC = TextEditingController();
//   final openingTimeC = TextEditingController();
//   final closingTimeC = TextEditingController();
//   final descriptionC = TextEditingController();
//   final websiteC = TextEditingController();
//   final phoneC = TextEditingController();
//   final locationC = TextEditingController();
//   final cityC = TextEditingController();
//   final townC = TextEditingController(); // ✅ NEW
//   final newFacilityC = TextEditingController();
//
//   // Reactive state
//   final RxList<XFile> selectedImages = <XFile>[].obs;
//   final RxList<String> facilities = <String>[].obs;
//   final RxList<Court> courts = <Court>[Court()].obs;
//
//   // Pick images
//   Future<void> pickImages() async {
//     try {
//       final List<XFile>? pickedFiles = await _picker.pickMultiImage(
//         maxWidth: 2000,
//         maxHeight: 2000,
//         imageQuality: 85,
//       );
//
//       if (pickedFiles != null) {
//         final allowedExtensions = ['jpg', 'jpeg', 'png'];
//         final validImages = pickedFiles.where((file) {
//           final ext = file.path.split('.').last.toLowerCase();
//           return allowedExtensions.contains(ext);
//         }).toList();
//
//         if (validImages.length != pickedFiles.length) {
//           Get.snackbar(
//             'Unsupported Format',
//             'Only JPG, JPEG, and PNG images are allowed.',
//             backgroundColor: Colors.orange,
//             colorText: Colors.white,
//           );
//         }
//
//         if (selectedImages.length + validImages.length > maxImages) {
//           Get.snackbar(
//             'Maximum Limit Reached',
//             'You can only upload up to $maxImages images.',
//             backgroundColor: Colors.orange,
//             colorText: Colors.white,
//           );
//           return;
//         }
//
//         selectedImages.addAll(validImages);
//       }
//     } catch (e) {
//       Get.snackbar(
//         'Error',
//         'Failed to pick images: ${e.toString()}',
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//     }
//   }
//
//   // Facility management
//   void addFacility() {
//     final facility = newFacilityC.text.trim();
//     if (facility.isNotEmpty) {
//       if (!facilities.contains(facility)) {
//         facilities.add(facility);
//         newFacilityC.clear();
//       } else {
//         Get.snackbar(
//           'Duplicate Facility',
//           '$facility is already added',
//           backgroundColor: Colors.orange,
//           colorText: Colors.white,
//         );
//       }
//     }
//   }
//
//   void removeFacility(String facility) => facilities.remove(facility);
//
//   // Court management
//   void addCourt() => courts.add(Court());
//
//   void removeCourt(int index) {
//     if (courts.length > 1) {
//       courts[index].dispose();
//       courts.removeAt(index);
//     } else {
//       Get.snackbar(
//         'Minimum Courts',
//         'At least one court is required',
//         backgroundColor: Colors.orange,
//         colorText: Colors.white,
//       );
//     }
//   }
//
//   // Pricing management
//   void addPricingToCourt(int courtIndex) =>
//       courts[courtIndex].pricingList.add(Pricing());
//
//   void removePricingFromCourt(int courtIndex, int pricingIndex) {
//     if (courts[courtIndex].pricingList.length > 1) {
//       courts[courtIndex].pricingList.removeAt(pricingIndex);
//     } else {
//       Get.snackbar(
//         'Minimum Pricing',
//         'At least one pricing option is required',
//         backgroundColor: Colors.orange,
//         colorText: Colors.white,
//       );
//     }
//   }
//
//   // Peak hours
//   void addPeakHoursToCourt(int courtIndex) =>
//       courts[courtIndex].peakHoursList.add(PeakHours());
//
//   void removePeakHoursFromCourt(int courtIndex, int peakHoursIndex) {
//     courts[courtIndex].peakHoursList.removeAt(peakHoursIndex);
//   }
//
//   // Image removal
//   void removeImage(int index) => selectedImages.removeAt(index);
//
//   // Submit
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
//       for (var court in courts) {
//         if (court.courtNumberController.text.isEmpty) {
//           throw 'Court number is required for all courts';
//         }
//       }
//
//       isSubmitting.value = true;
//
//       final photoPaths = selectedImages.map((x) => x.path).toList();
//
//       final playgroundData = {
//         'name': nameC.text.trim(),
//         'size': sizeC.text.trim(),
//         'openingTime': openingTimeC.text.trim(),
//         'closingTime': closingTimeC.text.trim(),
//         'description': descriptionC.text.trim(),
//         'website': websiteC.text.trim(),
//         'phoneNumber': phoneC.text.trim(),
//         'location': locationC.text.trim(),
//         'city': cityC.text.trim(),
//         'town': townC.text.trim(),
//         'facilities': jsonEncode(facilities.toList()),
//          'courts': jsonEncode(courts.map((c) => c.toJson()).toList()),
//         // +'facilities': facilities.toList(),
//         // + 'courts': courts.map((c) => c.toJson()).toList(),
//       };
//
//
//       await CreateVendorApi().createPlayground(playgroundData, photoPaths);
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
//
//   // Clear form
//   void clearForm() {
//     nameC.clear();
//     sizeC.clear();
//     openingTimeC.clear();
//     closingTimeC.clear();
//     descriptionC.clear();
//     websiteC.clear();
//     phoneC.clear();
//     locationC.clear();
//     cityC.clear();
//     townC.clear();
//     newFacilityC.clear();
//     facilities.clear();
//     selectedImages.clear();
//
//     for (var court in courts) {
//       court.dispose();
//     }
//
//     courts.clear();
//     courts.add(Court());
//   }
//
//   @override
//   void onClose() {
//     nameC.dispose();
//     sizeC.dispose();
//     openingTimeC.dispose();
//     closingTimeC.dispose();
//     descriptionC.dispose();
//     websiteC.dispose();
//     phoneC.dispose();
//     locationC.dispose();
//     cityC.dispose();
//     townC.dispose();
//     newFacilityC.dispose();
//
//     for (var court in courts) {
//       court.dispose();
//     }
//
//     super.onClose();
//   }
// }
//

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:padel_pro/services/vendors%20api/create_club_courts_api.dart';
import 'package:padel_pro/model/vendors model/playground_model.dart' as model;
import '../../../model/vendors model/playground_model.dart';

class Pricing {
  final TextEditingController priceController = TextEditingController();
  int duration = 60;

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

class CourtUIModel {
  final TextEditingController courtNumberController = TextEditingController();
  final TextEditingController courtTypeController = TextEditingController();
  final RxList<Pricing> pricingList = <Pricing>[Pricing()].obs;
  final RxList<PeakHours> peakHoursList = <PeakHours>[].obs;

  model.Court toModel() => model.Court(
    courtNumber: courtNumberController.text.trim(),
    courtType: [courtTypeController.text.trim()],
    pricing: pricingList
        .map(
          (p) => model.Pricing(
            duration: p.duration,
            price: double.tryParse(p.priceController.text) ?? 0,
          ),
        )
        .toList(),
    peakHours: peakHoursList
        .map(
          (ph) => model.PeakHour(
            startTime: ph.startTimeController.text,
            endTime: ph.endTimeController.text,
            price: double.tryParse(ph.priceController.text) ?? 0,
          ),
        )
        .toList(),
  );

  void dispose() {
    courtNumberController.dispose();
    courtTypeController.dispose();
    for (var p in pricingList) {
      p.dispose();
    }
    for (var ph in peakHoursList) {
      ph.dispose();
    }
  }
}

class CreatePlaygroundController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final isSubmitting = false.obs;

  final ImagePicker _picker = ImagePicker();
  final RxList<XFile> selectedImages = <XFile>[].obs;

  final nameC = TextEditingController();
  final sizeC = TextEditingController();
  final descriptionC = TextEditingController();
  final openingTimeC = TextEditingController();
  final closingTimeC = TextEditingController();
  final phoneC = TextEditingController();
  final locationC = TextEditingController();
  final cityC = TextEditingController();
  final websiteC = TextEditingController();
  final townC = TextEditingController();
  final newFacilityC = TextEditingController();

  final RxList<String> facilities = <String>[].obs;
  final RxList<CourtUIModel> courts = <CourtUIModel>[CourtUIModel()].obs;

  Future<void> pickImages() async {
    try {
      final files = await _picker.pickMultiImage(imageQuality: 85);
      final allowed = files.where((x) {
        final ext = x.path.split('.').last.toLowerCase();
        return ['jpg', 'jpeg', 'png'].contains(ext);
      }).toList();

      if (selectedImages.length + allowed.length > 5) {
        Get.snackbar(
          "Limit",
          "Maximum 5 images allowed",
          backgroundColor: Color(0xFF162A3A),
          colorText: Colors.white,
        );
        return;
      }

      selectedImages.addAll(allowed);
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void addFacility() {
    final f = newFacilityC.text.trim();
    if (f.isNotEmpty && !facilities.contains(f)) {
      facilities.add(f);
      newFacilityC.clear();
    }
  }

  void removeFacility(String f) => facilities.remove(f);
  void removeImage(int i) => selectedImages.removeAt(i);
  void addCourt() => courts.add(CourtUIModel());
  void removeCourt(int i) {
    if (courts.length > 1) {
      courts[i].dispose();
      courts.removeAt(i);
    }
  }

  void addPricing(int index) => courts[index].pricingList.add(Pricing());
  void removePricing(int c, int p) {
    if (courts[c].pricingList.length > 1) courts[c].pricingList.removeAt(p);
  }

  void addPeak(int i) => courts[i].peakHoursList.add(PeakHours());
  void removePeak(int c, int p) => courts[c].peakHoursList.removeAt(p);

  Future<void> submitForm() async {
    try {
      if (!formKey.currentState!.validate())
        throw 'Please fill required fields';
      if (selectedImages.isEmpty) throw 'Upload at least 1 image';

      final descriptionText = descriptionC.text.trim();
      final wordCount = descriptionText.split(RegExp(r'\s+')).length;
      if (wordCount < 10)
        Get.snackbar(
          "Validation",
          "Description must contains at least 10 words",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      ;

      final convertedCourts = courts.map((c) => c.toModel()).toList();

      final model = Playground(
        town: townC.text.capitalizeFirst!.trim(),
        name: nameC.text.trim().capitalizeFirst!,
        size: sizeC.text.trim().capitalizeFirst!,
        description: descriptionC.text.trim().capitalizeFirst!,
        openingTime: openingTimeC.text.trim().capitalizeFirst!,
        closingTime: closingTimeC.text.trim().capitalizeFirst!,
        phoneNumber: phoneC.text.trim().capitalizeFirst!,
        location: locationC.text.trim().capitalizeFirst!,
        city: cityC.text.trim().capitalizeFirst!,
        website: websiteC.text.trim().capitalizeFirst!,
        facilities: facilities.map((f) => f.toLowerCase()).toList(),
        courts: convertedCourts,
      );

      // final model = Playground(
      //   name: nameC.text.trim(),
      //   size: sizeC.text.trim(),
      //
      //   description: descriptionC.text.trim(),
      //   openingTime: openingTimeC.text.trim(),
      //   closingTime: closingTimeC.text.trim(),
      //   phoneNumber: phoneC.text.trim(),
      //   location: locationC.text.trim(),
      //   city: cityC.text.trim(),
      //   website: websiteC.text.trim(),
      //   facilities: facilities.toList(),
      //   courts: convertedCourts,
      // );

      final paths = selectedImages.map((x) => x.path).toList();
      isSubmitting.value = true;
      await CreateVendorApi().createPlayground(model.toJson(), paths);

      clearForm();
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  void clearForm() {
    nameC.clear();
    sizeC.clear();
    openingTimeC.clear();
    closingTimeC.clear();
    descriptionC.clear();
    websiteC.clear();
    phoneC.clear();
    locationC.clear();
    cityC.clear();
    townC.clear();
    newFacilityC.clear();
    facilities.clear();
    selectedImages.clear();

    for (var court in courts) {
      court.dispose();
    }
    courts.clear();
    courts.add(CourtUIModel());
  }

  @override
  void onClose() {
    nameC.dispose();
    sizeC.dispose();
    openingTimeC.dispose();
    closingTimeC.dispose();
    descriptionC.dispose();
    websiteC.dispose();
    phoneC.dispose();
    locationC.dispose();
    cityC.dispose();
    townC.dispose();
    newFacilityC.dispose();
    for (var court in courts) {
      court.dispose();
    }
    super.onClose();
  }
}
