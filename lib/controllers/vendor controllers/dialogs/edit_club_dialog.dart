import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:padel_pro/services/vendors%20api/fetch_club_courts_api.dart';
import 'package:padel_pro/controllers/vendor controllers/widgets/images_editor.dart';
import 'package:padel_pro/controllers/vendor controllers/widgets/custom_text_field.dart';

class EditClubDialog {
  static void show(
      Map<String, dynamic> club,
      FetchVendorApi fetchVendorApi,
      VoidCallback onSuccess,
      ) {
    const brand = Color(0xFF0C1E2C);

    final nameController = TextEditingController(text: club['name'] ?? '');
    final sizeController = TextEditingController(text: club['size'] ?? '');
    final openingTimeController = TextEditingController(
      text: club['openingTime'] ?? '',
    );
    final closingTimeController = TextEditingController(
      text: club['closingTime'] ?? '',
    );
    final descriptionController = TextEditingController(
      text: club['description'] ?? '',
    );
    final websiteController = TextEditingController(
      text: club['website'] ?? '',
    );
    final phoneController = TextEditingController(
      text: club['phoneNumber'] ?? '',
    );
    final locationController = TextEditingController(
      text: club['location'] ?? '',
    );
    final cityController = TextEditingController(text: club['city'] ?? '');
    final townController = TextEditingController(text: club['town'] ?? '');

    const facilitiesOptions = ['wifi', 'lockers', 'showers', 'cafe', 'parking'];

    // ensure lowercase init
    final RxList<String> selectedFacilities =
        ((club['facilities'] as List?)?.map((e) => e.toString().toLowerCase()).toList() ?? <String>[])
            .obs;

    // Image management state
    final List<String> imageAddPaths = <String>[];
    final List<String> imageRemoveUrls = <String>[];

    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: SafeArea(
          child: Container(
            constraints: BoxConstraints(
              maxHeight: Get.height * 0.9,
              maxWidth: (Get.width.clamp(360.0, 900.0) as double),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title & Close
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Edit Club Details",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: brand,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Images section
                        ImagesEditor(
                          initial: _resolveGalleryUrls(club),
                          onImagesChanged: (addPaths, removeUrls) {
                            imageAddPaths
                              ..clear()
                              ..addAll(addPaths);
                            imageRemoveUrls
                              ..clear()
                              ..addAll(removeUrls);
                          },
                        ),
                        const SizedBox(height: 12),

                        CustomTextField.build(
                          "Club Name",
                          nameController,
                          Icons.sports_bar,
                        ),
                        CustomTextField.build(
                          "Size (sqm)",
                          sizeController,
                          Icons.aspect_ratio,
                        ),
                        const SizedBox(height: 8),

                        // Times
                        LayoutBuilder(
                          builder: (_, cts) {
                            final twoCols = cts.maxWidth > 700;
                            return Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: [
                                SizedBox(
                                  width: twoCols
                                      ? (cts.maxWidth - 10) / 2
                                      : cts.maxWidth,
                                  child: CustomTextField.buildTimePicker(
                                    "Opening Time",
                                    openingTimeController,
                                  ),
                                ),
                                SizedBox(
                                  width: twoCols
                                      ? (cts.maxWidth - 10) / 2
                                      : cts.maxWidth,
                                  child: CustomTextField.buildTimePicker(
                                    "Closing Time",
                                    closingTimeController,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),

                        CustomTextField.build(
                          "Description",
                          descriptionController,
                          Icons.description,
                          maxLines: 3,
                        ),
                        CustomTextField.build(
                          "Website URL",
                          websiteController,
                          Icons.link,
                        ),
                        CustomTextField.build(
                          "Phone Number",
                          phoneController,
                          Icons.phone,
                        ),
                        CustomTextField.build(
                          "Location",
                          locationController,
                          Icons.location_on,
                        ),

                        // Town/City
                        LayoutBuilder(
                          builder: (_, cts) {
                            final twoCols = cts.maxWidth > 700;
                            return Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: [
                                SizedBox(
                                  width: twoCols
                                      ? (cts.maxWidth - 10) / 2
                                      : cts.maxWidth,
                                  child: CustomTextField.build(
                                    "Town",
                                    townController,
                                    Icons.location_city,
                                  ),
                                ),
                                SizedBox(
                                  width: twoCols
                                      ? (cts.maxWidth - 10) / 2
                                      : cts.maxWidth,
                                  child: CustomTextField.build(
                                    "City",
                                    cityController,
                                    Icons.location_city,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 16),

                        // Facilities
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Facilities",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Obx(
                              () => Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: facilitiesOptions.map((facility) {
                              final isSelected = selectedFacilities.contains(facility);
                              return ChoiceChip(
                                label: Text(facility),
                                selected: isSelected,
                                onSelected: (selected) {
                                  if (selected) {
                                    if (!isSelected) selectedFacilities.add(facility);
                                  } else {
                                    selectedFacilities.remove(facility);
                                  }
                                },
                                selectedColor: brand,
                                backgroundColor: Colors.grey[200],
                                labelStyle: TextStyle(
                                  color: isSelected ? Colors.white : Colors.black,
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: brand,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      if (nameController.text.trim().isEmpty) {
                        Get.snackbar(
                          "Validation",
                          "Club name is required",
                          backgroundColor: Colors.orange,
                          colorText: Colors.white,
                        );
                        return;
                      }

                      // Sanitize facilities (force lower-case & whitelist)
                      const List<String> allowedFacilities = [
                        'wifi',
                        'lockers',
                        'showers',
                        'cafe',
                        'parking'
                      ];
                      final List<String> sanitizedFacilities =
                      selectedFacilities.map((f) => f.toLowerCase()).where(
                            (f) => allowedFacilities.contains(f),
                      ).toList();

                      final Map<String, dynamic> updatedData = {
                        "name": nameController.text.trim(),
                        "size": sizeController.text.trim(),
                        "openingTime": openingTimeController.text.trim(),
                        "closingTime": closingTimeController.text.trim(),
                        "description": descriptionController.text.trim(),
                        "website": websiteController.text.trim(),
                        "phoneNumber": phoneController.text.trim(),
                        "location": locationController.text.trim(),
                        "city": cityController.text.trim(),
                        "town": townController.text.trim(),
                        "facilities": sanitizedFacilities,
                      }..removeWhere(
                            (k, v) => (v is String && v.trim().isEmpty),
                      );

                      print(sanitizedFacilities);

                      // Apply photo removals
                      final initialPhotos = _resolveGalleryUrls(club);
                      if (imageRemoveUrls.isNotEmpty) {
                        final remaining = initialPhotos
                            .where((u) => !imageRemoveUrls.contains(u))
                            .toList();
                        updatedData['photos'] = remaining;
                      }

                      try {
                        Get.back(); // close dialog
                        Get.dialog(
                          const Center(
                            child: CircularProgressIndicator(color: Colors.grey),
                          ),
                          barrierDismissible: false,
                        );

                        await fetchVendorApi.updatePlaygroundById(
                          club['_id'],
                          updatedData,
                          photoFiles: imageAddPaths.map((p) => File(p)).toList(),
                          removePhotoUrls: imageRemoveUrls,
                        );

                        Get.back(); // loader
                        Get.snackbar(
                          "Success",
                          "Club updated successfully",
                          backgroundColor: Colors.green,
                          colorText: Colors.white,
                        );
                        onSuccess();
                      } catch (e) {
                        Get.back(); // loader
                        Get.snackbar(
                          "Error",
                          e.toString(),
                          backgroundColor: Colors.red,
                          colorText: Colors.white,
                        );
                      }
                    },

                    child: const Text(
                      "SAVE CHANGES",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static List<String> _resolveGalleryUrls(Map<String, dynamic> club) {
    for (final key in ['photos', 'images', 'gallery']) {
      final list = club[key];
      if (list is List && list.isNotEmpty) {
        return list.map((e) => e.toString()).toList();
      }
    }
    return <String>[];
  }
}
