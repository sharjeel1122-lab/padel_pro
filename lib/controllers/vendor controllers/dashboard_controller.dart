import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:padel_pro/screens/vendor/views/create_playground_view.dart';
import 'package:padel_pro/services/vendors%20api/fetch_club_courts_api.dart';
import 'package:padel_pro/services/vendors%20api/create_club_courts_api.dart';
import 'package:padel_pro/controllers/vendor controllers/dialogs/edit_club_dialog.dart';
import 'package:padel_pro/controllers/vendor controllers/dialogs/edit_court_dialog.dart';
import 'package:padel_pro/controllers/vendor controllers/dialogs/add_court_dialog.dart';
import 'package:padel_pro/controllers/vendor controllers/dialogs/view_courts_dialog.dart';

class VendorDashboardController extends GetxController {
  final FetchVendorApi _fetchVendorApi = FetchVendorApi();
  final CreateVendorApi _vendorApi = CreateVendorApi();

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
    Get.to(CreatePlaygroundView());
  }

  // =================== EDIT CLUB ===================

  void editClub(int index) {
    final club = filteredClubs[index];
    EditClubDialog.show(club, _fetchVendorApi, () => fetchPlaygrounds(showLoader: false));
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
                            final club = filteredClubs[index];
    ViewCourtsDialog.show(
      club, 
      courts, 
      _fetchVendorApi, 
      _vendorApi,
      () => fetchPlaygrounds(showLoader: false),
      (updatedCourts) => currentCourts.assignAll(updatedCourts),
    );
  }

  // =================== EDIT COURT ===================

  void editCourt({
    required String playgroundId,
    required Map<String, dynamic> court,
    required Future<void> Function(
      String playgroundId,
      Map<String, dynamic> payload,
    ) updateCourtsApi,
    VoidCallback? onAfterSave,
  }) {
    EditCourtDialog.show(
      playgroundId, 
      court, 
      updateCourtsApi, 
      onAfterSave,
    );
  }

  // =================== ADD COURT ===================

  void addCourt({
    required String playgroundId,
    required Future<void> Function()? onAdded,
  }) {
    AddCourtDialog.show(playgroundId, _vendorApi, onAdded);
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
