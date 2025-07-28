  import 'package:get/get.dart';

  import '../../../services/vendors api/create_club_courts_api.dart';


  class DashboardController extends GetxController {
    final CreateVendorApi _apiService = CreateVendorApi();
    final clubs = <Map<String, dynamic>>[].obs;
    final isLoading = false.obs;

    @override
    void onInit() {
      super.onInit();
      // fetchVendorPlaygrounds();
    }

    // Future<void> fetchVendorPlaygrounds() async {
    //   try {
    //     isLoading(true);
    //     final response = await _apiService.getVendorPlaygrounds();
    //     clubs.assignAll(response.map((club) => club as Map<String, dynamic>).toList());
    //   } finally {
    //     isLoading(false);
    //   }
    // }

    Future<void> createNewPlayground(Map<String, dynamic> data, List<String> photoPaths) async {
      try {
        isLoading(true);
        await _apiService.createPlayground(data, photoPaths);
        // await fetchVendorPlaygrounds(); // Refresh list after creation
        Get.back(); // Close create form
        Get.snackbar('Success', 'Playground created successfully');
      } catch (e) {
        Get.snackbar('Error', e.toString());
      } finally {
        isLoading(false);
      }
    }

    void viewCourts(int index) {
      Get.toNamed('/courts', arguments: clubs[index]);
    }
  }