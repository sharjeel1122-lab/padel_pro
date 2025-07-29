  import 'package:get/get.dart';

  import '../../../services/vendors api/create_club_courts_api.dart';


  class DashboardController extends GetxController {
    final CreateVendorApi _apiService = CreateVendorApi();
    final clubs = <Map<String, dynamic>>[].obs;
    final isLoading = false.obs;
    var playgrounds = [].obs;

    @override
    void onInit() {
      super.onInit();
      fetchPlaygrounds();
    }

    void fetchPlaygrounds() async {
      try {
        isLoading.value = true;
        final data = await _apiService.getVendorPlaygrounds();
        playgrounds.value = data;
      } catch (e) {
        print("Error fetching playgrounds: $e");
      } finally {
        isLoading.value = false;
      }
    }

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