import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:padel_pro/services/vendors api/create_club_courts_api.dart';
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
          backgroundColor: const Color(0xFF162A3A),
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
      if (!formKey.currentState!.validate()) {
        throw 'Please fill required fields';
      }
      if (selectedImages.isEmpty) {
        throw 'Upload at least 1 image';
      }

      // Description must be at least 10 words (and stop submission if not)
      final descriptionText = descriptionC.text.trim();
      final wordCount = descriptionText.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
      if (wordCount < 10) {
        Get.snackbar(
          "Validation",
          "Description must contain at least 10 words",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return; // <- stop submission here
      }

      final convertedCourts = courts.map((c) => c.toModel()).toList();

      final modelData = Playground(
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

      final paths = selectedImages.map((x) => x.path).toList();
      isSubmitting.value = true;

      await CreateVendorApi().createPlayground(modelData.toJson(), paths);

      // ✅ SUCCESS SNACKBAR
      Get.snackbar(
        "Success",
        "Club created successfully",
        backgroundColor: const Color(0xFF162A3A),
        colorText: Colors.white,
      );

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
