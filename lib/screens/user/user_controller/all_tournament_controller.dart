// controllers/vendor_tournament_controller.dart

import 'package:get/get.dart';
import 'package:padel_pro/services/user%20role%20api%20service/fetch_all_tournaments.dart';

class AllTournamentController extends GetxController {
  var isLoading = false.obs;
  var tournaments = [].obs;

  Future<void> fetchAllTournaments() async {
    isLoading.value = true;
    try {
      final data = await GetAllTournamentsApi().getAllTournaments();
      tournaments.assignAll(data);
    } catch (e) {
      print('❌ Fetch tournament error: $e');
      // Get.snackbar('Error', 'Failed to fetch tournaments');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onInit() {
    fetchAllTournaments();
    super.onInit();
  }
}
