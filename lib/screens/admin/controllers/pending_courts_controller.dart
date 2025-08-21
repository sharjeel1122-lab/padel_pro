import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:padel_pro/services/admin%20api/fetch_pending_courts_api.dart';
import 'package:padel_pro/services/admin%20api/activate_court_api.dart';

class PendingCourtsController extends GetxController {
  final FetchPendingCourtsApi _pendingCourtsApi = FetchPendingCourtsApi();
  final ActivateCourtApi _activateCourtApi = ActivateCourtApi();

  final RxList<PendingCourt> pendingCourts = <PendingCourt>[].obs;
  final RxBool isLoading = false.obs;
  // Remove the general isActivating flag
  // final RxBool isActivating = false.obs;

  // Add a map to track activation status for each court
  final RxMap<String, bool> activatingCourts = <String, bool>{}.obs;

  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPendingCourts();
  }

  Future<void> fetchPendingCourts() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final courts = await _pendingCourtsApi.fetchPendingCourts();
      pendingCourts.value = courts;
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // Check if a specific court is being activated
  bool isCourtActivating(String playgroundId, String courtNumber) {
    final key = "$playgroundId-$courtNumber";
    return activatingCourts[key] ?? false;
  }

  Future<void> activateCourt(String playgroundId, String courtNumber) async {
    final key = "$playgroundId-$courtNumber";

    try {
      // Set loading state for this specific court only
      activatingCourts[key] = true;
      errorMessage.value = '';

      await _activateCourtApi.activateCourt(playgroundId, courtNumber);

      // Refresh the list after activation
      await fetchPendingCourts();

      Get.snackbar(
        'Success',
        'Court activated successfully',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF0A3B5C),
        colorText: Colors.white,
      );
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      // Clear loading state for this specific court
      activatingCourts.remove(key);
    }
  }

  void refreshData() {
    fetchPendingCourts();
  }
}