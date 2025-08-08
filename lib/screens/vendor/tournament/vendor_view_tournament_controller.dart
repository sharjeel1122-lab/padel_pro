// controllers/vendor_tournament_controller.dart

import 'dart:async';
import 'package:get/get.dart';
import 'package:padel_pro/services/vendors%20api/fetch_vendor_tournament_api.dart';

class VendorTournamentController extends GetxController {
  var isLoading = false.obs;
  var tournaments = [].obs;

  Timer? _refreshTimer;

  Future<void> fetchVendorTournaments({bool showLoader = true}) async {
    try {
      if (showLoader) isLoading.value = true;

      final data = await GetVendorTournamentsApi().getVendorTournaments();
      tournaments.assignAll(data);
    } catch (e) {
      print('❌ Fetch tournament error: $e');
      Get.snackbar('Error', 'Failed to fetch tournaments');
    } finally {
      if (showLoader) isLoading.value = false;
    }
  }

  @override
  void onInit() {
    super.onInit();
    fetchVendorTournaments(showLoader: true);


    _refreshTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      fetchVendorTournaments(showLoader: false);
    });
  }

  @override
  void onClose() {
    _refreshTimer?.cancel();
    super.onClose();
  }
}
