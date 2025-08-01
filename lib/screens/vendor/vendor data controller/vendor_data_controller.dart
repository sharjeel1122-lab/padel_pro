//   import 'package:get/get.dart';
// import 'package:padel_pro/screens/vendor/vendor%20data%20controller/reate_playground_controller.dart';
// import 'package:padel_pro/services/vendors%20api/fetch_club_courts_api.dart';
//
//   import '../../../services/vendors api/create_club_courts_api.dart';
//
//
//   class DashboardController extends GetxController {
//     final CreateVendorApi _createVendorApi = CreateVendorApi();
//     final FetchVendorApi _fetchVendorApi = FetchVendorApi();
//     final clubs = <Map<String, dynamic>>[].obs;
//     final isLoading = false.obs;
//     var playgrounds = [].obs;
//
//     final createPlaygroundController = Get.find<CreatePlaygroundController>();
//
//     @override
//     void onInit() {
//       super.onInit();
//       // fetchPlaygrounds();
//     }
//
//     //fetch
//
//     // void fetchPlaygrounds() async {
//     //   try {
//     //     isLoading.value = true;
//     //     final data = await _fetchVendorApi.getVendorPlaygrounds();
//     //     playgrounds.value = data;
//     //   } catch (e) {
//     //     print("Error fetching playgrounds: $e");
//     //   } finally {
//     //     isLoading.value = false;
//     //   }
//     // }
//
//
//
//      //create
//
//     Future<void> createNewPlayground(Map<String, dynamic> data, List<String> photoPaths) async {
//       try {
//         isLoading(true);
//         await _createVendorApi.createPlayground(data, photoPaths);
//         // await fetchVendorPlaygrounds(); // Refresh list after creation
//         Get.back(); // Close create form
//         Get.snackbar('Success', 'Playground created successfully');
//         createPlaygroundController.clearForm();
//       } catch (e) {
//         Get.snackbar('Error', e.toString());
//       } finally {
//         isLoading(false);
//       }
//     }
//
//     void viewCourts(int index) {
//       Get.toNamed('/courts', arguments: clubs[index]);
//     }
//   }