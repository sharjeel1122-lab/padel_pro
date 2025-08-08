import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:padel_pro/screens/vendor/views/create_playground_view.dart';
import 'package:padel_pro/services/vendors%20api/fetch_club_courts_api.dart';

class VendorDashboardController extends GetxController {
  final FetchVendorApi _fetchVendorApi = FetchVendorApi();
  final RxList<Map<String, dynamic>> playgrounds = <Map<String, dynamic>>[].obs;
  final RxString selectedPlaygroundId = ''.obs;
  final RxBool isLoading = false.obs;
  final RxList<Map<String, dynamic>> filteredClubs =
      <Map<String, dynamic>>[].obs;
  final TextEditingController searchController = TextEditingController();
  final RxList<Map<String, dynamic>> clubs = <Map<String, dynamic>>[].obs;

  Timer? _refreshTimer;

  @override
  void onInit() {
    super.onInit();
    fetchPlaygrounds(showLoader: true); // Show loader on first load
    searchController.addListener(onSearchChanged);

    // Silent refresh every 10 seconds
    _refreshTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      fetchPlaygrounds(showLoader: false); // No loader in periodic refresh
    });
  }

  @override
  void onClose() {
    _refreshTimer?.cancel(); // Clean up timer
    searchController.dispose();
    super.onClose();
  }

  void fetchPlaygrounds({bool showLoader = true}) async {
    try {
      if (showLoader) isLoading.value = true;

      final data = await _fetchVendorApi.getVendorPlaygrounds();
      playgrounds.value = List<Map<String, dynamic>>.from(data);
      clubs.value = playgrounds;
      filteredClubs.assignAll(clubs);
    } catch (e) {
      print('Error: $e');
    } finally {
      if (showLoader) isLoading.value = false;
    }
  }

  void onSearchChanged() {
    final query = searchController.text.toLowerCase();
    if (query.isEmpty) {
      filteredClubs.assignAll(clubs);
    } else {
      filteredClubs.assignAll(
        clubs.where((club) {
          final name = (club['name'] ?? '').toString().toLowerCase();
          final location = (club['location'] ?? '').toString().toLowerCase();
          return name.contains(query) || location.contains(query);
        }).toList(),
      );
    }
  }

  void addClub() {
    Get.to(CreatePlaygroundView());
  }

  //Edit Club


  // --- EDIT CLUB DIALOG ---
  void editClub(int index) {
    final club = filteredClubs[index];

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

    final facilitiesOptions = ['wifi', 'lockers', 'showers', 'cafe', 'parking'];
    final RxList<String> selectedFacilities =
        ((club['facilities'] as List?)?.cast<String>() ?? <String>[]).obs;

    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          constraints: BoxConstraints(maxHeight: Get.height * 0.85),
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
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                      _buildTextField(
                        "Club Name",
                        nameController,
                        Icons.sports_bar,
                      ),
                      _buildTextField(
                        "Size (sqm)",
                        sizeController,
                        Icons.aspect_ratio,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTimePickerField(
                              "Opening Time",
                              openingTimeController,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildTimePickerField(
                              "Closing Time",
                              closingTimeController,
                            ),
                          ),
                        ],
                      ),
                      _buildTextField(
                        "Description",
                        descriptionController,
                        Icons.description,
                        maxLines: 3,
                      ),
                      _buildTextField(
                        "Website URL",
                        websiteController,
                        Icons.link,
                      ),
                      _buildTextField(
                        "Phone Number",
                        phoneController,
                        Icons.phone,
                      ),
                      _buildTextField(
                        "Location",
                        locationController,
                        Icons.location_on,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              "Town",
                              townController,
                              Icons.location_city,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildTextField(
                              "City",
                              cityController,
                              Icons.location_city,
                            ),
                          ),
                        ],
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
                            final isSelected = selectedFacilities.contains(
                              facility,
                            );
                            return ChoiceChip(
                              label: Text(facility),
                              selected: isSelected,
                              onSelected: (selected) {
                                if (selected) {
                                  if (!isSelected)
                                    selectedFacilities.add(facility);
                                } else {
                                  selectedFacilities.remove(facility);
                                }
                              },
                              selectedColor: const Color(0xFF0C1E2C),
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
                    backgroundColor: const Color(0xFF0C1E2C),
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
                      "facilities": selectedFacilities.toList(),
                    }..removeWhere((k, v) => (v is String && v.trim().isEmpty));

                    try {
                      Get.back(); // close dialog
                      Get.dialog(
                        const Center(child: CircularProgressIndicator()),
                        barrierDismissible: false,
                      );

                      print('Fetch Selected ID ${club['_id']}');

                      await _fetchVendorApi.updatePlaygroundById(
                        club['_id'] as String,
                        updatedData,
                      );

                      Get.back(); // loader
                      Get.snackbar(
                        "Success",
                        "Club updated successfully",
                        backgroundColor: Colors.green,
                        colorText: Colors.white,
                      );

                      // 🔧 DO NOT await if fetchPlaygrounds returns void
                      fetchPlaygrounds(showLoader: false);
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
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon, {
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: const Color(0xFF0C1E2C).withOpacity(0.7),
          ),
          prefixIcon: Icon(
            icon,
            color: const Color(0xFF0C1E2C).withOpacity(0.7),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF0C1E2C), width: 1.5),
          ),
          filled: true,
          fillColor: Colors.grey[50],
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 20, color: Colors.grey),
                  onPressed: () {
                    controller.clear();
                    Get.forceAppUpdate();
                  },
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 16,
          ),
        ),
        onChanged: (_) => Get.forceAppUpdate(),
      ),
    );
  }

  Widget _buildTimePickerField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        readOnly: true,
        onTap: () async {
          final pickedTime = await showTimePicker(
            context: Get.context!,
            initialTime: TimeOfDay.now(),
          );
          if (pickedTime != null) {
            controller.text = pickedTime.format(Get.context!);
            Get.forceAppUpdate();
          }
        },
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.access_time),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    controller.clear();
                    Get.forceAppUpdate();
                  },
                )
              : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.grey[50],
        ),
      ),
    );
  }




 // EDIT Court Dialog

  void editCourt({
    required String playgroundId,
    required Map<String, dynamic> court,
    required Future<void> Function(String playgroundId, Map<String, dynamic> payload) updateCourtsApi,
    VoidCallback? onAfterSave, // e.g. fetchPlaygrounds
  }) {
    const brand = Color(0xFF0C1E2C);
    const allowedDurations = <int>[30, 60, 90, 120, 150, 180];

    // Prefill controllers/state
    final courtNumberCtrl = TextEditingController(
      text: (court['courtNumber'] ?? '').toString(),
    );

    // Court types as chips
    final typeOptions = ['Wall', 'Crystal', 'Panoramic', 'Indoor', 'Outdoor'];
    final RxList<String> selectedTypes =
        ((court['courtType'] as List?)?.map((e) => e.toString()).toList() ?? <String>[])
            .obs;

    final isActive = RxBool((court['isActive'] ?? false) as bool);


    final RxList<Map<String, dynamic>> pricing = RxList<Map<String, dynamic>>(
      (court['pricing'] as List? ?? [])
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList(),
    );
    if (pricing.isEmpty) {
      pricing.add({"duration": 60, "price": 0});
    }

    void addPricingRow() {
      pricing.add({"duration": 60, "price": 0});
    }

    void removePricingRow(int i) {
      if (pricing.length > 1) pricing.removeAt(i);
    }

    bool validate() {
      if (courtNumberCtrl.text.trim().isEmpty) {
        Get.snackbar("Validation", "Court number / name is required",
            backgroundColor: Colors.orange, colorText: Colors.white);
        return false;
      }
      if (pricing.isEmpty) {
        Get.snackbar("Validation", "At least one pricing option is required",
            backgroundColor: Colors.orange, colorText: Colors.white);
        return false;
      }
      for (final p in pricing) {
        final d = p['duration'];
        final pr = p['price'];
        if (d == null || pr == null) {
          Get.snackbar("Validation", "Invalid pricing details",
              backgroundColor: Colors.orange, colorText: Colors.white);
          return false;
        }
        if (!allowedDurations.contains(d)) {
          Get.snackbar("Validation", "Invalid duration value",
              backgroundColor: Colors.orange, colorText: Colors.white);
          return false;
        }
      }
      return true;
    }

    Future<void> onSave() async {
      if (!validate()) return;

      final payloadCourt = {
        "courtNumber": courtNumberCtrl.text.trim(),
        "courtType": selectedTypes.toList(),
        "pricing": pricing
            .map((p) => {
          "duration": p['duration'],
          "price": (p['price'] is String)
              ? num.tryParse(p['price']) ?? 0
              : p['price'],
        })
            .toList(),
        "peakHours": court['peakHours'] ?? [],
        "isActive": isActive.value,
      };

      // Close form and show loader
      Get.back();
      Get.dialog(const Center(child: CircularProgressIndicator()),
          barrierDismissible: false);

      try {
        // Calls your backend wrapper. It should PUT:
        // PUT /playgrounds/:id/courts  with body: {"courts":[payloadCourt]}
        await updateCourtsApi(playgroundId, {"courts": [payloadCourt]});

        Get.back(); // loader
        Get.snackbar("Success", "Court updated successfully",
            backgroundColor: Colors.green, colorText: Colors.white);

        onAfterSave?.call(); // e.g. fetchPlaygrounds()
      } catch (e) {
        Get.back(); // loader
        Get.snackbar("Error", e.toString(),
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    }

    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          constraints: BoxConstraints(maxHeight: Get.height * 0.85, maxWidth: 720),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title & Close
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Edit Court",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: brand)),
                  IconButton(icon: const Icon(Icons.close), onPressed: Get.back),
                ],
              ),
              const SizedBox(height: 12),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Court Number / Name
                      _field(
                        label: "Court Number / Name",
                        controller: courtNumberCtrl,
                        icon: Icons.confirmation_number,
                      ),

                      // Court Types (chips)
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text("Court Types",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(height: 8),
                      Obx(
                            () => Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: typeOptions.map((t) {
                            final sel = selectedTypes.contains(t);
                            return ChoiceChip(
                              label: Text(t),
                              selected: sel,
                              onSelected: (v) {
                                if (v) {
                                  if (!sel) selectedTypes.add(t);
                                } else {
                                  selectedTypes.remove(t);
                                }
                              },
                              selectedColor: brand,
                              backgroundColor: Colors.grey[200],
                              labelStyle: TextStyle(color: sel ? Colors.white : Colors.black),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Active switch
                      Obx(
                            () => SwitchListTile(
                          value: isActive.value,
                          onChanged: (v) => isActive.value = v,
                          title: const Text('Active'),
                          activeColor: brand,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Pricing (Rs.) editor
                      Row(
                        children: const [
                          Text("Pricing (Rs.)",
                              style: TextStyle(color: brand, fontWeight: FontWeight.w700, fontSize: 16)),
                          SizedBox(width: 8),
                          Text("(choose Duration and set Price)", style: TextStyle(color: Colors.black54)),
                        ],
                      ),
                      const SizedBox(height: 8),

                      Obx(
                            () => Column(
                          children: [
                            ...List.generate(pricing.length, (i) {
                              final p = pricing[i];
                              final priceCtrl = TextEditingController(
                                  text: p['price']?.toString() ?? '');
                              return Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    // Duration dropdown
                                    DropdownButton<int>(
                                      value: (p['duration'] is int) ? p['duration'] : allowedDurations.first,
                                      items: allowedDurations
                                          .map((d) => DropdownMenuItem<int>(value: d, child: Text('$d min')))
                                          .toList(),
                                      onChanged: (v) {
                                        if (v == null) return;
                                        pricing[i] = {...p, "duration": v};
                                      },
                                    ),
                                    const SizedBox(width: 12),
                                    // Price (Rs.)
                                    Expanded(
                                      child: TextField(
                                        controller: priceCtrl,
                                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                        decoration: const InputDecoration(
                                          labelText: 'Price (Rs.)',
                                          border: OutlineInputBorder(),
                                        ),
                                        onChanged: (val) => pricing[i] = {...p, "price": val},
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      tooltip: 'Remove',
                                      onPressed: () => removePricingRow(i),
                                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                    ),
                                  ],
                                ),
                              );
                            }),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: TextButton.icon(
                                onPressed: addPricingRow,
                                icon: const Icon(Icons.add),
                                label: const Text('Add pricing'),
                                style: TextButton.styleFrom(foregroundColor: brand),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brand,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: onSave,
                  child: const Text("SAVE CHANGES", style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _field({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    int maxLines = 1,
  }) {
    const brand = Color(0xFF0C1E2C);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: brand.withOpacity(0.7)),
          prefixIcon: Icon(icon, color: brand.withOpacity(0.7)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.black26),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.black26),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: brand, width: 1.5),
          ),
          filled: true,
          fillColor: Colors.grey[50],
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.clear, size: 20, color: Colors.grey),
            onPressed: () {
              controller.clear();
              Get.forceAppUpdate();
            },
          )
              : null,
          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        ),
        onChanged: (_) => Get.forceAppUpdate(),
      ),
    );
  }











  void deleteClub(int index) async {
    final club = filteredClubs[index];
    Get.defaultDialog(
      title: "Delete Club",
      middleText: "Are you sure you want to delete '${club['name']}'?",
      textCancel: "Cancel",
      textConfirm: "Delete",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () async {
        Get.back();
        try {
          await _fetchVendorApi.deletePlaygroundById(club['_id']);
          clubs.removeWhere((c) => c['_id'] == club['_id']);
          filteredClubs.removeAt(index);
          Get.snackbar(
            "Deleted",
            "Club deleted successfully.",
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        } catch (e) {
          Get.snackbar(
            "Error",
            "Failed to delete club.",
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      },
      onCancel: () => Get.back(),
    );
  }

  //ViewCourts
  void viewCourts(int index, List<dynamic> courts) {
    Get.dialog(
      Dialog(
        backgroundColor: const Color(0xFF0C1E2C),
        insetPadding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 1200,
            maxHeight: MediaQuery.of(Get.context!).size.height * 0.9,
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  children: [
                    const Icon(Icons.sports_tennis, color: Colors.white, size: 28),
                    const SizedBox(width: 12),
                    const Text(
                      'Available Courts',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    // NEW: Add (+) button
                    IconButton(
                      tooltip: 'Add Court',
                      onPressed: () {
                        // TODO: handle add court
                      },
                      icon: const Icon(Icons.add, color: Colors.white, size: 26),
                    ),
                    IconButton(
                      tooltip: 'Close',
                      onPressed: Get.back,
                      icon: const Icon(Icons.close, color: Colors.white70, size: 24),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Cards Grid
                Expanded(
                  child: LayoutBuilder(
                    builder: (_, constraints) {
                      final cols = constraints.maxWidth >= 1000
                          ? 3
                          : constraints.maxWidth >= 700
                          ? 2
                          : 1;
                      return GridView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.only(bottom: 8),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: cols,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: cols == 1 ? 1.6 : 1.3,
                        ),
                        itemCount: courts.length,
                        itemBuilder: (_, i) {
                          final c = Map<String, dynamic>.from(courts[i]);
                          final name = c['courtNumber']?.toString() ?? 'Court ${i + 1}';
                          final types = (c['courtType'] as List?)?.cast<String>() ?? [];
                          final pricing = (c['pricing'] as List?)
                              ?.map((e) => Map<String, dynamic>.from(e))
                              .toList() ??
                              [];
                          // final isActive = c['isActive'] ?? false;
                          final description = c['description']?.toString() ?? '';

                          return Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () {},
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Title + status
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              name,
                                              style: const TextStyle(
                                                color: Color(0xFF0C1E2C),
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          // Container(
                                          //   padding: const EdgeInsets.symmetric(
                                          //       horizontal: 10, vertical: 4),
                                          //   decoration: BoxDecoration(
                                          //     color: (isActive
                                          //         ? Colors.green
                                          //         : Colors.red)
                                          //         .withOpacity(0.1),
                                          //     borderRadius:
                                          //     BorderRadius.circular(12),
                                          //   ),
                                          //   child: Text(
                                          //     isActive ? 'Active' : 'Inactive',
                                          //     style: TextStyle(
                                          //       color: isActive
                                          //           ? Colors.green
                                          //           : Colors.red,
                                          //       fontWeight: FontWeight.bold,
                                          //       fontSize: 12,
                                          //     ),
                                          //   ),
                                          // ),
                                        ],
                                      ),

                                      if (description.isNotEmpty) ...[
                                        const SizedBox(height: 6),
                                        Text(
                                          description,
                                          style: TextStyle(
                                            color: Colors.grey[700],
                                            fontSize: 13,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],

                                      const SizedBox(height: 12),

                                      // Court types
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 6,
                                        children: types
                                            .map((t) => Container(
                                          padding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 5),
                                          decoration: BoxDecoration(
                                            color:
                                            const Color(0xFF0C1E2C),
                                            borderRadius:
                                            BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            t,
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12),
                                          ),
                                        ))
                                            .toList(),
                                      ),

                                      const SizedBox(height: 12),

                                      // Pricing section
                                      const Text(
                                        'Pricing Options (Rs.)',
                                        style: TextStyle(
                                          color: Color(0xFF0C1E2C),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 6),

                                      if (pricing.isEmpty)
                                        Padding(
                                          padding:
                                          const EdgeInsets.only(top: 4),
                                          child: Text(
                                            'No pricing available',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        )
                                      else
                                        Column(
                                          children: pricing.map((p) {
                                            final duration = p['duration']?.toString() ?? '0';
                                            final price = p['price']?.toString() ?? '0';
                                            return Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 4),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    width: 6,
                                                    height: 6,
                                                    decoration: BoxDecoration(
                                                      color: const Color(0xFF0C1E2C),
                                                      borderRadius: BorderRadius.circular(3),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  // Labelled Duration
                                                  Text(
                                                    'Duration: $duration minutes',
                                                    style: TextStyle(
                                                      color: Colors.grey[800],
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                  const Spacer(),
                                                  // Labelled Price with Rs.
                                                  Text(
                                                    'Price: Rs. $price',
                                                    style: const TextStyle(
                                                      color: Color(0xFF0C1E2C),
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }).toList(),
                                        ),

                                      const Spacer(),


                                      Align(
                                        alignment: Alignment.bottomRight,
                                        child: ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                            const Color(0xFF0C1E2C),
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                              BorderRadius.circular(12),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 10),
                                          ),
                                          onPressed: () {
                                            final club = filteredClubs[index];
                                            editCourt(
                                              playgroundId: club['_id'] as String,
                                              court: c,
                                              updateCourtsApi: (id, body) => _fetchVendorApi.updateCourtById(id, body),
                                              onAfterSave: () => fetchPlaygrounds(showLoader: false),
                                            );
                                          },

                                          icon: const Icon(Icons.edit, size: 18),
                                          label: const Text(
                                            'Edit',
                                            style: TextStyle(fontSize: 14),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierColor: Colors.black.withOpacity(0.7),
      barrierDismissible: true,
    );

    print(courts);
  }





// void viewCourts(int index, List<dynamic> courts) {
  //   print(courts);
  //
  //
  // }
}
