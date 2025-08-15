import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:padel_pro/screens/vendor/views/create_playground_view.dart';
import 'package:padel_pro/services/vendors%20api/fetch_club_courts_api.dart';
import 'package:padel_pro/services/vendors%20api/create_club_courts_api.dart'; // ✅ for addCourts()

class VendorDashboardController extends GetxController {
  final FetchVendorApi _fetchVendorApi = FetchVendorApi();
  final CreateVendorApi _vendorApi = CreateVendorApi(); // ✅

  final RxList<Map<String, dynamic>> playgrounds = <Map<String, dynamic>>[].obs;
  final RxString selectedPlaygroundId = ''.obs;
  final RxBool isLoading = false.obs;
  final RxList<Map<String, dynamic>> filteredClubs =
      <Map<String, dynamic>>[].obs;
  final TextEditingController searchController = TextEditingController();

  final RxList<Map<String, dynamic>> clubs = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> currentCourts =
      <Map<String, dynamic>>[].obs;

  Timer? _refreshTimer;
  Timer? _viewCourtsTimer;

  @override
  void onInit() {
    super.onInit();
    fetchPlaygrounds(showLoader: true);
    searchController.addListener(onSearchChanged);

    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      fetchPlaygrounds(showLoader: false);
    });
  }

  @override
  void onClose() {
    _refreshTimer?.cancel();
    _viewCourtsTimer?.cancel();
    searchController.dispose();
    super.onClose();
  }

  // =================== DATA ===================

  Future<void> fetchPlaygrounds({bool showLoader = true}) async {
    try {
      if (showLoader) isLoading.value = true;
      final data = await _fetchVendorApi.getVendorPlaygrounds();
      playgrounds.value = List<Map<String, dynamic>>.from(data);
      clubs.value = playgrounds;
      filteredClubs.assignAll(clubs);
    } catch (e) {
      debugPrint('Error: $e');
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
    Get.to(const CreatePlaygroundView());
  }

  // =================== EDIT CLUB ===================

  void editClub(int index) {
    const brand = Color(0xFF0C1E2C);
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

                        // Times (2-col responsive)
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
                                  child: _buildTimePickerField(
                                    "Opening Time",
                                    openingTimeController,
                                  ),
                                ),
                                SizedBox(
                                  width: twoCols
                                      ? (cts.maxWidth - 10) / 2
                                      : cts.maxWidth,
                                  child: _buildTimePickerField(
                                    "Closing Time",
                                    closingTimeController,
                                  ),
                                ),
                              ],
                            );
                          },
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

                        // Town/City (2-col responsive)
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
                                  child: _buildTextField(
                                    "Town",
                                    townController,
                                    Icons.location_city,
                                  ),
                                ),
                                SizedBox(
                                  width: twoCols
                                      ? (cts.maxWidth - 10) / 2
                                      : cts.maxWidth,
                                  child: _buildTextField(
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
                                selectedColor: brand,
                                backgroundColor: Colors.grey[200],
                                labelStyle: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.black,
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

                      final Map<String, dynamic> updatedData =
                          {
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
                          }..removeWhere(
                            (k, v) => (v is String && v.trim().isEmpty),
                          );

                      try {
                        Get.back(); // close dialog
                        Get.dialog(
                          const Center(child: CircularProgressIndicator()),
                          barrierDismissible: false,
                        );

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
      ),
    );
  }

  // =================== DELETE CLUB ===================

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

  // =================== VIEW COURTS ===================

  void viewCourts(int index, List<dynamic> courts) {
    currentCourts.assignAll(
      courts.map((e) => Map<String, dynamic>.from(e as Map)).toList(),
    );

    final pageCtrl = ScrollController();
    final clubId = (filteredClubs[index]['_id'] ?? '').toString();

    _viewCourtsTimer?.cancel();

    _viewCourtsTimer = Timer.periodic(const Duration(seconds: 10), (_) async {
      try {
        final data = await _fetchVendorApi.getVendorPlaygrounds();
        final list = List<Map<String, dynamic>>.from(data);
        final updatedClub = list.firstWhere(
          (p) => (p['_id'] ?? '').toString() == clubId,
          orElse: () => const {},
        );

        final updatedCourts = (updatedClub['courts'] as List? ?? [])
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();

        if (updatedCourts.length != currentCourts.length ||
            !_listDeepEquals(updatedCourts, currentCourts)) {
          currentCourts.assignAll(updatedCourts);
        }
      } catch (e) {
        debugPrint('viewCourts refresh error: $e');
      }
    });

    Get.dialog(
      Dialog(
        backgroundColor: const Color(0xFF0C1E2C),
        insetPadding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Obx(() {
          final itemCount = currentCourts.length;

          final size = MediaQuery.of(Get.context!).size;
          final isPhone = size.width < 600;
          final dialogW = isPhone
              ? size.width - 24
              : ((size.width).clamp(640.0, 1200.0) as double) - 24;
          final dialogH = isPhone ? size.height * 0.96 : size.height * 0.9;

          return SafeArea(
            child: SizedBox(
              width: dialogW,
              height: dialogH,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.sports_tennis,
                          color: Colors.white,
                          size: 26,
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Available Courts',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // ✅ Add Court
                        IconButton(
                          tooltip: 'Add Court',
                          onPressed: () {
                            final club = filteredClubs[index];
                            _openAddCourtDialog(
                              playgroundId: clubId,
                              onAdded: () async {
                                await fetchPlaygrounds(showLoader: false);
                                // refresh the local list inside the dialog
                                final updated = clubs.firstWhere(
                                  (c) => (c['_id'] ?? '') == club['_id'],
                                  orElse: () => {},
                                );
                                final updatedCourts =
                                    (updated['courts'] as List? ?? [])
                                        .map(
                                          (e) => Map<String, dynamic>.from(
                                            e as Map,
                                          ),
                                        )
                                        .toList();
                                currentCourts.assignAll(updatedCourts);
                              },
                            );
                          },
                          icon: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        IconButton(
                          tooltip: 'Close',
                          onPressed: Get.back,
                          icon: const Icon(
                            Icons.close,
                            color: Colors.white70,
                            size: 22,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    Expanded(
                      child: Scrollbar(
                        controller: pageCtrl,
                        thumbVisibility: true,
                        trackVisibility: true,
                        interactive: true,
                        child: SingleChildScrollView(
                          controller: pageCtrl,
                          physics: const BouncingScrollPhysics(),
                          child: LayoutBuilder(
                            builder: (_, constraints) {
                              final maxW = constraints.maxWidth;
                              final cols = maxW >= 1000
                                  ? 3
                                  : (maxW >= 700 ? 2 : 1);
                              const spacing = 16.0;
                              final totalSpacing = spacing * (cols - 1);
                              final cardW = (maxW - totalSpacing) / cols;

                              return Wrap(
                                spacing: spacing,
                                runSpacing: spacing,
                                children: List.generate(itemCount, (i) {
                                  final c = currentCourts[i];
                                  final name =
                                      c['courtNumber']?.toString() ??
                                      'Court ${i + 1}';
                                  final types =
                                      (c['courtType'] as List?)
                                          ?.cast<String>() ??
                                      [];
                                  final pricing =
                                      (c['pricing'] as List?)
                                          ?.map(
                                            (e) => Map<String, dynamic>.from(
                                              e as Map,
                                            ),
                                          )
                                          .toList() ??
                                      [];
                                  final peakHours =
                                      (c['peakHours'] as List?)
                                          ?.map(
                                            (e) => Map<String, dynamic>.from(
                                              e as Map,
                                            ),
                                          )
                                          .toList() ??
                                      [];
                                  final description =
                                      c['description']?.toString() ?? '';

                                  return SizedBox(
                                    width: cardW,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.2,
                                            ),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Material(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          onTap: () {},
                                          child: Padding(
                                            padding: const EdgeInsets.all(14),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  name,
                                                  style: const TextStyle(
                                                    color: Color(0xFF0C1E2C),
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w800,
                                                  ),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),

                                                if (description.isNotEmpty) ...[
                                                  const SizedBox(height: 6),
                                                  Text(
                                                    description,
                                                    style: TextStyle(
                                                      color: Colors.grey[700],
                                                      fontSize: 13,
                                                      height: 1.25,
                                                    ),
                                                  ),
                                                ],

                                                if (types.isNotEmpty) ...[
                                                  const SizedBox(height: 10),
                                                  Wrap(
                                                    spacing: 8,
                                                    runSpacing: 6,
                                                    children: types
                                                        .map(
                                                          (t) => Container(
                                                            padding:
                                                                const EdgeInsets.symmetric(
                                                                  horizontal:
                                                                      10,
                                                                  vertical: 5,
                                                                ),
                                                            decoration: BoxDecoration(
                                                              color:
                                                                  const Color(
                                                                    0xFF0C1E2C,
                                                                  ),
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    8,
                                                                  ),
                                                            ),
                                                            child: Text(
                                                              t,
                                                              style:
                                                                  const TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        12,
                                                                  ),
                                                            ),
                                                          ),
                                                        )
                                                        .toList(),
                                                  ),
                                                ],

                                                const SizedBox(height: 10),
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
                                                        const EdgeInsets.only(
                                                          top: 2,
                                                        ),
                                                    child: Text(
                                                      'No pricing available',
                                                      style: TextStyle(
                                                        color: Colors.grey[600],
                                                        fontStyle:
                                                            FontStyle.italic,
                                                      ),
                                                    ),
                                                  )
                                                else
                                                  Column(
                                                    children: pricing.map((p) {
                                                      final duration =
                                                          p['duration']
                                                              ?.toString() ??
                                                          '0';
                                                      final price =
                                                          p['price']
                                                              ?.toString() ??
                                                          '0';
                                                      return Padding(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              vertical: 3,
                                                            ),
                                                        child: Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets.only(
                                                                    top: 7.0,
                                                                  ),
                                                              child: Container(
                                                                width: 6,
                                                                height: 6,
                                                                decoration: BoxDecoration(
                                                                  color: const Color(
                                                                    0xFF0C1E2C,
                                                                  ),
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                        3,
                                                                      ),
                                                                ),
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              width: 10,
                                                            ),
                                                            Expanded(
                                                              child: Text(
                                                                'Duration: $duration minutes',
                                                                style: TextStyle(
                                                                  color: Colors
                                                                      .grey[800],
                                                                  fontSize: 14,
                                                                ),
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              width: 10,
                                                            ),
                                                            Text(
                                                              'Price: Rs. $price',
                                                              style: const TextStyle(
                                                                color: Color(
                                                                  0xFF0C1E2C,
                                                                ),
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 14,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    }).toList(),
                                                  ),

                                                // ✅ Peak Hours section
                                                const SizedBox(height: 12),
                                                const Text(
                                                  'Peak Hours',
                                                  style: TextStyle(
                                                    color: Color(0xFF0C1E2C),
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 6),
                                                if (peakHours.isEmpty)
                                                  Text(
                                                    'No peak hours',
                                                    style: TextStyle(
                                                      color: Colors.grey[600],
                                                      fontStyle:
                                                          FontStyle.italic,
                                                    ),
                                                  )
                                                else
                                                  Column(
                                                    children: peakHours.map((
                                                      ph,
                                                    ) {
                                                      final st =
                                                          ph['startTime']
                                                              ?.toString() ??
                                                          '--:--';
                                                      final et =
                                                          ph['endTime']
                                                              ?.toString() ??
                                                          '--:--';
                                                      final pr =
                                                          ph['price']
                                                              ?.toString() ??
                                                          '0';
                                                      return Padding(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              vertical: 3,
                                                            ),
                                                        child: Row(
                                                          children: [
                                                            const Icon(
                                                              Icons.schedule,
                                                              size: 16,
                                                              color: Color(
                                                                0xFF0C1E2C,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              width: 8,
                                                            ),
                                                            Expanded(
                                                              child: Text(
                                                                '$st → $et',
                                                                style: TextStyle(
                                                                  color: Colors
                                                                      .grey[800],
                                                                  fontSize: 14,
                                                                ),
                                                              ),
                                                            ),
                                                            Text(
                                                              'Rs. $pr',
                                                              style: const TextStyle(
                                                                color: Color(
                                                                  0xFF0C1E2C,
                                                                ),
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 14,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    }).toList(),
                                                  ),

                                                const SizedBox(height: 12),
                                                Align(
                                                  alignment:
                                                      Alignment.centerRight,
                                                  child: ElevatedButton.icon(
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor:
                                                          const Color(
                                                            0xFF0C1E2C,
                                                          ),
                                                      foregroundColor:
                                                          Colors.white,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
                                                      ),
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 16,
                                                            vertical: 10,
                                                          ),
                                                    ),
                                                    onPressed: () {
                                                      final club =
                                                          filteredClubs[index];
                                                      editCourt(
                                                        playgroundId:
                                                            club['_id']
                                                                as String,
                                                        court: c,
                                                        updateCourtsApi:
                                                            (
                                                              id,
                                                              body,
                                                            ) => _fetchVendorApi
                                                                .updateCourtById(
                                                                  id,
                                                                  body,
                                                                ),
                                                        onAfterSave: () =>
                                                            fetchPlaygrounds(
                                                              showLoader: false,
                                                            ),
                                                      );
                                                    },
                                                    icon: const Icon(
                                                      Icons.edit,
                                                      size: 18,
                                                    ),
                                                    label: const Text(
                                                      'Edit',
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
      barrierColor: Colors.black.withOpacity(0.7),
      barrierDismissible: true,
    ).then((_) {
      _viewCourtsTimer?.cancel();
      pageCtrl.dispose();
    });

    debugPrint(
      'viewCourts opened for clubId=$clubId, initial courts=${currentCourts.length}',
    );
  }

  // =================== ADD COURT (NEW) ===================

  void _openAddCourtDialog({
    required String playgroundId,
    required Future<void> Function()? onAdded,
  }) {
    const brand = Color(0xFF0C1E2C);
    const allowedDurations = <int>[30, 60, 90, 120, 150, 180];

    final courtNumberCtrl = TextEditingController();
    final List<String> typeOptions = [
      'Wall',
      'Crystal',
      'Panoramic',
      'Indoor',
      'Outdoor',
    ];
    final RxList<String> selectedTypes = <String>[].obs;

    // Pricing rows
    final RxList<_PricingRow> pricingRows = <_PricingRow>[
      _PricingRow(duration: 60, priceCtrl: TextEditingController(text: '0')),
    ].obs;

    // Peak hour rows
    final RxList<_PeakRow> peakRows = <_PeakRow>[].obs;

    String _hhmm(TimeOfDay t) =>
        '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

    Future<void> _pickHHmm(TextEditingController ctrl) async {
      final picked = await showTimePicker(
        context: Get.context!,
        initialTime: TimeOfDay.now(),
        initialEntryMode: TimePickerEntryMode.dial,
        builder: (ctx, child) => MediaQuery(
          data: MediaQuery.of(ctx!).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        ),
      );
      if (picked != null) ctrl.text = _hhmm(picked);
    }

    Future<void> _save() async {
      // Validate
      if (courtNumberCtrl.text.trim().isEmpty) {
        Get.snackbar(
          'Validation',
          'Court name / number is required',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }
      if (selectedTypes.isEmpty) {
        Get.snackbar(
          'Validation',
          'Select at least one court type',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }
      if (pricingRows.isEmpty) {
        Get.snackbar(
          'Validation',
          'Add at least one pricing row',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }
      for (int i = 0; i < pricingRows.length; i++) {
        final r = pricingRows[i];
        final price = int.tryParse(r.priceCtrl.text.trim());
        if (!allowedDurations.contains(r.duration) || price == null) {
          Get.snackbar(
            'Validation',
            'Invalid pricing in row ${i + 1}',
            backgroundColor: Colors.orange,
            colorText: Colors.white,
          );
          return;
        }
      }
      for (int i = 0; i < peakRows.length; i++) {
        final r = peakRows[i];
        final okTime =
            _isHHmm(r.startCtrl.text.trim()) && _isHHmm(r.endCtrl.text.trim());
        final price = int.tryParse(r.priceCtrl.text.trim());
        if (!okTime || price == null) {
          Get.snackbar(
            'Validation',
            'Invalid peak hour in row ${i + 1}',
            backgroundColor: Colors.orange,
            colorText: Colors.white,
          );
          return;
        }
      }

      final courtPayload = {
        "courtNumber": courtNumberCtrl.text.trim(),
        "courtType": selectedTypes.toList(),
        "pricing": pricingRows
            .map(
              (e) => {
                "duration": e.duration,
                "price": int.parse(e.priceCtrl.text.trim()),
              },
            )
            .toList(),
        "peakHours": peakRows
            .map(
              (e) => {
                "startTime": e.startCtrl.text.trim(),
                "endTime": e.endCtrl.text.trim(),
                "price": int.parse(e.priceCtrl.text.trim()),
              },
            )
            .toList(),
      };

      // Call API
      Get.back(); // close dialog
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );
      try {
        await _vendorApi.addCourts(
          playgroundId: playgroundId,
          courts: [courtPayload],
        );
        Get.back(); // loader
        Get.snackbar(
          'Success',
          'Court added successfully',
          backgroundColor: const Color(0xFF162A3A),
          colorText: Colors.white,
        );
        await onAdded?.call();
      } catch (e) {
        Get.back(); // loader
        Get.snackbar(
          'Error',
          e.toString(),
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }

    Get.dialog(
      StatefulBuilder(
        builder: (context, setState) {
          final size = MediaQuery.of(context).size;
          final isPhone = size.width < 600;
          final maxW = isPhone
              ? size.width - 20
              : ((size.width).clamp(600.0, 900.0) as double) - 20;
          final maxH = isPhone ? size.height * 0.96 : size.height * 0.85;

          return Dialog(
            backgroundColor: Colors.white,
            insetPadding: const EdgeInsets.all(12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            child: SafeArea(
              child: SizedBox(
                width: maxW,
                height: maxH,
                child: Column(
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: const BoxDecoration(
                        color: brand,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(18),
                        ),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.add, color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Add Court',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Body
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _field(
                              label: "Court Number / Name",
                              controller: courtNumberCtrl,
                              icon: Icons.confirmation_number,
                            ),

                            const Text(
                              "Court Types",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
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
                                    labelStyle: TextStyle(
                                      color: sel ? Colors.white : Colors.black,
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                            const SizedBox(height: 12),

                            Row(
                              children: const [
                                Text(
                                  "Pricing (Rs.)",
                                  style: TextStyle(
                                    color: brand,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  "(choose Duration and set Price)",
                                  style: TextStyle(color: Colors.black54),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // Pricing rows
                            Obx(
                              () => ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: pricingRows.length,
                                itemBuilder: (_, i) {
                                  final row = pricingRows[i];
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.black12),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: LayoutBuilder(
                                      builder: (_, cts) {
                                        final twoCols = cts.maxWidth > 520;

                                        if (!twoCols) {
                                          return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              DropdownButtonFormField<int>(
                                                value: row.duration,
                                                decoration:
                                                    const InputDecoration(
                                                      labelText: 'Duration',
                                                      border:
                                                          OutlineInputBorder(),
                                                    ),
                                                isExpanded: true,
                                                items: allowedDurations
                                                    .map(
                                                      (d) =>
                                                          DropdownMenuItem<int>(
                                                            value: d,
                                                            child: Text(
                                                              '$d min',
                                                            ),
                                                          ),
                                                    )
                                                    .toList(),
                                                onChanged: (v) {
                                                  if (v == null) return;
                                                  setState(
                                                    () => row.duration = v,
                                                  );
                                                },
                                              ),
                                              const SizedBox(height: 10),
                                              TextField(
                                                controller: row.priceCtrl,
                                                keyboardType:
                                                    TextInputType.number,
                                                inputFormatters: [
                                                  FilteringTextInputFormatter
                                                      .digitsOnly,
                                                ],
                                                decoration:
                                                    const InputDecoration(
                                                      labelText: 'Price (Rs.)',
                                                      border:
                                                          OutlineInputBorder(),
                                                    ),
                                              ),
                                              Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: IconButton(
                                                  tooltip: 'Remove',
                                                  onPressed: () {
                                                    if (pricingRows.length >
                                                        1) {
                                                      final x = pricingRows
                                                          .removeAt(i);
                                                      x.priceCtrl.dispose();
                                                      setState(() {});
                                                    }
                                                  },
                                                  icon: const Icon(
                                                    Icons.delete_outline,
                                                    color: Colors.redAccent,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        }

                                        return Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            ConstrainedBox(
                                              constraints: const BoxConstraints(
                                                minWidth: 160,
                                                maxWidth: 200,
                                              ),
                                              child: DropdownButtonFormField<int>(
                                                value: row.duration,
                                                decoration:
                                                    const InputDecoration(
                                                      labelText: 'Duration',
                                                      border:
                                                          OutlineInputBorder(),
                                                    ),
                                                isExpanded: true,
                                                items: allowedDurations
                                                    .map(
                                                      (d) =>
                                                          DropdownMenuItem<int>(
                                                            value: d,
                                                            child: Text(
                                                              '$d min',
                                                            ),
                                                          ),
                                                    )
                                                    .toList(),
                                                onChanged: (v) {
                                                  if (v == null) return;
                                                  setState(
                                                    () => row.duration = v,
                                                  );
                                                },
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: TextField(
                                                controller: row.priceCtrl,
                                                keyboardType:
                                                    TextInputType.number,
                                                inputFormatters: [
                                                  FilteringTextInputFormatter
                                                      .digitsOnly,
                                                ],
                                                decoration:
                                                    const InputDecoration(
                                                      labelText: 'Price (Rs.)',
                                                      border:
                                                          OutlineInputBorder(),
                                                    ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            IconButton(
                                              tooltip: 'Remove',
                                              onPressed: () {
                                                if (pricingRows.length > 1) {
                                                  final x = pricingRows
                                                      .removeAt(i);
                                                  x.priceCtrl.dispose();
                                                  setState(() {});
                                                }
                                              },
                                              icon: const Icon(
                                                Icons.delete_outline,
                                                color: Colors.redAccent,
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),

                            Align(
                              alignment: Alignment.centerLeft,
                              child: TextButton.icon(
                                onPressed: () {
                                  pricingRows.add(
                                    _PricingRow(
                                      duration: 60,
                                      priceCtrl: TextEditingController(
                                        text: '0',
                                      ),
                                    ),
                                  );
                                  setState(() {});
                                },
                                icon: const Icon(Icons.add),
                                label: const Text('Add pricing'),
                                style: TextButton.styleFrom(
                                  foregroundColor: brand,
                                ),
                              ),
                            ),

                            const SizedBox(height: 8),
                            const Text(
                              'Peak Hours',
                              style: TextStyle(
                                color: brand,
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 6),

                            // Peak rows
                            Obx(
                              () => ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: peakRows.length,
                                itemBuilder: (_, i) {
                                  final row = peakRows[i];
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.black12),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      children: [
                                        LayoutBuilder(
                                          builder: (_, cts) {
                                            final twoCols = cts.maxWidth > 520;
                                            final child = (Widget w) => twoCols
                                                ? Expanded(child: w)
                                                : w;

                                            final startField = TextField(
                                              controller: row.startCtrl,
                                              readOnly: true,
                                              onTap: () =>
                                                  _pickHHmm(row.startCtrl),
                                              decoration: const InputDecoration(
                                                labelText: 'Start (HH:MM)',
                                                border: OutlineInputBorder(),
                                                prefixIcon: Icon(
                                                  Icons.schedule,
                                                ),
                                              ),
                                            );
                                            final endField = TextField(
                                              controller: row.endCtrl,
                                              readOnly: true,
                                              onTap: () =>
                                                  _pickHHmm(row.endCtrl),
                                              decoration: const InputDecoration(
                                                labelText: 'End (HH:MM)',
                                                border: OutlineInputBorder(),
                                                prefixIcon: Icon(
                                                  Icons.schedule,
                                                ),
                                              ),
                                            );

                                            if (!twoCols) {
                                              return Column(
                                                children: [
                                                  startField,
                                                  const SizedBox(height: 10),
                                                  endField,
                                                ],
                                              );
                                            }

                                            return Row(
                                              children: [
                                                child(startField),
                                                const SizedBox(width: 12),
                                                child(endField),
                                              ],
                                            );
                                          },
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: TextField(
                                                controller: row.priceCtrl,
                                                keyboardType:
                                                    TextInputType.number,
                                                inputFormatters: [
                                                  FilteringTextInputFormatter
                                                      .digitsOnly,
                                                ],
                                                decoration:
                                                    const InputDecoration(
                                                      labelText: 'Price (Rs.)',
                                                      border:
                                                          OutlineInputBorder(),
                                                      prefixIcon: Icon(
                                                        Icons.money,
                                                      ),
                                                    ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            IconButton(
                                              tooltip: 'Remove',
                                              onPressed: () {
                                                final x = peakRows.removeAt(i);
                                                x.dispose();
                                                setState(() {});
                                              },
                                              icon: const Icon(
                                                Icons.delete_outline,
                                                color: Colors.redAccent,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),

                            Align(
                              alignment: Alignment.centerLeft,
                              child: TextButton.icon(
                                onPressed: () {
                                  peakRows.add(_PeakRow());
                                  setState(() {});
                                },
                                icon: const Icon(Icons.add),
                                label: const Text('Add peak hour'),
                                style: TextButton.styleFrom(
                                  foregroundColor: brand,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Footer
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: Get.back,
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: brand,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: _save,
                              child: const Text(
                                "ADD COURT",
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      barrierDismissible: true,
    );
  }

  // =================== EDIT COURT (existing) ===================

  void editCourt({
    required String playgroundId,
    required Map<String, dynamic> court,
    required Future<void> Function(
      String playgroundId,
      Map<String, dynamic> payload,
    )
    updateCourtsApi,
    VoidCallback? onAfterSave,
  }) {
    const brand = Color(0xFF0C1E2C);
    const allowedDurations = <int>[30, 60, 90, 120, 150, 180];

    final TextEditingController courtNumberCtrl = TextEditingController(
      text: (court['courtNumber'] ?? '').toString(),
    );

    final List<String> typeOptions = [
      'Wall',
      'Crystal',
      'Panoramic',
      'Indoor',
      'Outdoor',
    ];
    List<String> selectedTypes =
        ((court['courtType'] as List?)?.map((e) => e.toString()).toList() ??
                <String>[])
            .toList();
    bool isActive = (court['isActive'] ?? false) as bool;

    final List<int> durations = [];
    final List<TextEditingController> priceCtrls = [];
    final List<FocusNode> priceFocus = [];

    void seedPricing() {
      final src = (court['pricing'] as List? ?? []);
      if (src.isEmpty) {
        durations.add(60);
        priceCtrls.add(TextEditingController(text: '0'));
        priceFocus.add(FocusNode());
        return;
      }
      for (final e in src) {
        final m = Map<String, dynamic>.from(e as Map);
        durations.add((m['duration'] is int) ? m['duration'] as int : 60);
        priceCtrls.add(
          TextEditingController(text: (m['price'] ?? '0').toString()),
        );
        priceFocus.add(FocusNode());
      }
    }

    seedPricing();

    void addPricingRow(void Function(void Function()) setState) {
      setState(() {
        durations.add(60);
        priceCtrls.add(TextEditingController(text: '0'));
        priceFocus.add(FocusNode());
      });
    }

    void removePricingRow(int i, void Function(void Function()) setState) {
      if (durations.length <= 1) return;
      setState(() {
        durations.removeAt(i);
        priceCtrls.removeAt(i).dispose();
        priceFocus.removeAt(i).dispose();
      });
    }

    Future<void> onSave() async {
      if (courtNumberCtrl.text.trim().isEmpty) {
        Get.snackbar(
          "Validation",
          "Court number / name is required",
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }
      for (int i = 0; i < durations.length; i++) {
        final d = durations[i];
        final prStr = priceCtrls[i].text.trim();
        if (!allowedDurations.contains(d)) {
          Get.snackbar(
            "Validation",
            "Invalid duration value",
            backgroundColor: Colors.orange,
            colorText: Colors.white,
          );
          return;
        }
        if (prStr.isEmpty || int.tryParse(prStr) == null) {
          Get.snackbar(
            "Validation",
            "Invalid price in row ${i + 1}",
            backgroundColor: Colors.orange,
            colorText: Colors.white,
          );
          return;
        }
      }

      final payloadCourt = {
        "courtNumber": courtNumberCtrl.text.trim(),
        "courtType": selectedTypes,
        "pricing": List.generate(durations.length, (i) {
          return {
            "duration": durations[i],
            "price": int.parse(priceCtrls[i].text.trim()),
          };
        }),
        "peakHours": court['peakHours'] ?? [],
        "isActive": isActive,
      };

      Get.back();
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      try {
        await updateCourtsApi(playgroundId, {
          "courts": [payloadCourt],
        });
        Get.back();
        Get.snackbar(
          "Success",
          "Court updated successfully",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        onAfterSave?.call();
      } catch (e) {
        Get.back();
        Get.snackbar(
          "Error",
          e.toString(),
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }

    Get.dialog(
      StatefulBuilder(
        builder: (context, setState) {
          final size = MediaQuery.of(context).size;
          final isPhone = size.width < 600;
          final maxW = isPhone
              ? size.width - 20
              : ((size.width).clamp(600.0, 900.0) as double) - 20;
          final maxH = isPhone ? size.height * 0.96 : size.height * 0.85;

          return Dialog(
            backgroundColor: Colors.white,
            insetPadding: const EdgeInsets.all(12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            child: SafeArea(
              child: SizedBox(
                width: maxW,
                height: maxH,
                child: Column(
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: const BoxDecoration(
                        color: brand,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(18),
                        ),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.edit, color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Edit Court',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Body
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _field(
                              label: "Court Number / Name",
                              controller: courtNumberCtrl,
                              icon: Icons.confirmation_number,
                            ),

                            const Text(
                              "Court Types",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: typeOptions.map((t) {
                                final sel = selectedTypes.contains(t);
                                return ChoiceChip(
                                  label: Text(t),
                                  selected: sel,
                                  onSelected: (v) {
                                    setState(() {
                                      if (v) {
                                        if (!sel) selectedTypes.add(t);
                                      } else {
                                        selectedTypes.remove(t);
                                      }
                                    });
                                  },
                                  selectedColor: brand,
                                  backgroundColor: Colors.grey[200],
                                  labelStyle: TextStyle(
                                    color: sel ? Colors.white : Colors.black,
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 12),

                            SwitchListTile(
                              value: isActive,
                              onChanged: (v) => setState(() => isActive = v),
                              title: const Text('Active'),
                              activeColor: brand,
                              contentPadding: EdgeInsets.zero,
                            ),
                            const SizedBox(height: 8),

                            Row(
                              children: const [
                                Text(
                                  "Pricing (Rs.)",
                                  style: TextStyle(
                                    color: brand,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  "(choose Duration and set Price)",
                                  style: TextStyle(color: Colors.black54),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // PRICING LIST - overflow safe
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: durations.length,
                              itemBuilder: (_, i) {
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.black12),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: LayoutBuilder(
                                    builder: (_, cts) {
                                      final twoCols = cts.maxWidth > 520;

                                      if (!twoCols) {
                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            // Duration
                                            DropdownButtonFormField<int>(
                                              value: durations[i],
                                              decoration: const InputDecoration(
                                                labelText: 'Duration',
                                                border: OutlineInputBorder(),
                                              ),
                                              isExpanded: true,
                                              items: allowedDurations
                                                  .map(
                                                    (d) =>
                                                        DropdownMenuItem<int>(
                                                          value: d,
                                                          child: Text('$d min'),
                                                        ),
                                                  )
                                                  .toList(),
                                              onChanged: (v) {
                                                if (v == null) return;
                                                setState(
                                                  () => durations[i] = v,
                                                );
                                              },
                                            ),
                                            const SizedBox(height: 10),
                                            // Price
                                            TextField(
                                              controller: priceCtrls[i],
                                              focusNode: priceFocus[i],
                                              keyboardType:
                                                  TextInputType.number,
                                              inputFormatters: [
                                                FilteringTextInputFormatter
                                                    .digitsOnly,
                                              ],
                                              decoration: const InputDecoration(
                                                labelText: 'Price (Rs.)',
                                                border: OutlineInputBorder(),
                                              ),
                                            ),
                                            Align(
                                              alignment: Alignment.centerRight,
                                              child: IconButton(
                                                tooltip: 'Remove',
                                                onPressed: () =>
                                                    removePricingRow(
                                                      i,
                                                      setState,
                                                    ),
                                                icon: const Icon(
                                                  Icons.delete_outline,
                                                  color: Colors.redAccent,
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      }

                                      // Wide layout (Row 2-col)
                                      return Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Duration (fixed)
                                          ConstrainedBox(
                                            constraints: const BoxConstraints(
                                              minWidth: 160,
                                              maxWidth: 200,
                                            ),
                                            child: DropdownButtonFormField<int>(
                                              value: durations[i],
                                              decoration: const InputDecoration(
                                                labelText: 'Duration',
                                                border: OutlineInputBorder(),
                                              ),
                                              isExpanded: true,
                                              items: allowedDurations
                                                  .map(
                                                    (d) =>
                                                        DropdownMenuItem<int>(
                                                          value: d,
                                                          child: Text('$d min'),
                                                        ),
                                                  )
                                                  .toList(),
                                              onChanged: (v) {
                                                if (v == null) return;
                                                setState(
                                                  () => durations[i] = v,
                                                );
                                              },
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          // Price (flex)
                                          Expanded(
                                            child: TextField(
                                              controller: priceCtrls[i],
                                              focusNode: priceFocus[i],
                                              keyboardType:
                                                  TextInputType.number,
                                              inputFormatters: [
                                                FilteringTextInputFormatter
                                                    .digitsOnly,
                                              ],
                                              decoration: const InputDecoration(
                                                labelText: 'Price (Rs.)',
                                                border: OutlineInputBorder(),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          IconButton(
                                            tooltip: 'Remove',
                                            onPressed: () =>
                                                removePricingRow(i, setState),
                                            icon: const Icon(
                                              Icons.delete_outline,
                                              color: Colors.redAccent,
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                );
                              },
                            ),

                            Align(
                              alignment: Alignment.centerLeft,
                              child: TextButton.icon(
                                onPressed: () => addPricingRow(setState),
                                icon: const Icon(Icons.add),
                                label: const Text('Add pricing'),
                                style: TextButton.styleFrom(
                                  foregroundColor: brand,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Footer
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: Get.back,
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: brand,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: onSave,
                              child: const Text(
                                "SAVE CHANGES",
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      barrierDismissible: true,
    );
  }

  // =================== HELPERS ===================

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon, {
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
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: brand, width: 1.5),
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
            builder: (ctx, child) => MediaQuery(
              data: MediaQuery.of(ctx!).copyWith(alwaysUse24HourFormat: true),
              child: child!,
            ),
          );
          if (pickedTime != null) {
            controller.text =
                '${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}';
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
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: Colors.black26),
          ),
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: Colors.black26),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: brand, width: 1.5),
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

  bool _isHHmm(String s) {
    final re = RegExp(r'^(?:[01]\d|2[0-3]):[0-5]\d$');
    return re.hasMatch(s);
  }

  // Deep equals (very light)
  bool _listDeepEquals(
    List<Map<String, dynamic>> a,
    List<Map<String, dynamic>> b,
  ) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (!_mapShallowEquals(a[i], b[i])) return false;
    }
    return true;
  }

  bool _mapShallowEquals(Map<String, dynamic> a, Map<String, dynamic> b) {
    if (a.length != b.length) return false;
    for (final k in a.keys) {
      final va = a[k], vb = b[k];
      if (va is Map && vb is Map) {
        if (va.toString() != vb.toString()) return false;
      } else if (va is List && vb is List) {
        if (va.toString() != vb.toString()) return false;
      } else if (va != vb) {
        return false;
      }
    }
    return true;
  }
}

// ---------- local row models for Add Court dialog ----------
class _PricingRow {
  _PricingRow({required this.duration, required this.priceCtrl});
  int duration;
  final TextEditingController priceCtrl;
}

class _PeakRow {
  final TextEditingController startCtrl = TextEditingController();
  final TextEditingController endCtrl = TextEditingController();
  final TextEditingController priceCtrl = TextEditingController(text: '0');
  void dispose() {
    startCtrl.dispose();
    endCtrl.dispose();
    priceCtrl.dispose();
  }
}
