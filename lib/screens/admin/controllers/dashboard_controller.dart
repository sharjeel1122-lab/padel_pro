// lib/screens/admin/vendors controllers/dashboard_controller.dart
import 'dart:async';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:padel_pro/services/admin%20api/admin_request_api.dart';
import 'package:padel_pro/services/user%20role%20api%20service/user_fetch_allclubs_api.dart';

class DashboardController extends GetxController {
  var totalCourts = 0.obs;
  var vendors = 0.obs;
  var products = 0.obs;
  var requests = 0.obs;
  Timer? refreshTimer;

  @override
  void onInit() {
    super.onInit();
    loadStats();
    startAutoRefresh();
  }


  final courts = <CourtModel>[
    CourtModel(name: "Green Arena", date: "2024-07-10", type: "Indoor"),
  ].obs;

  void addVendor() {
    vendors.value++;
    update();
  }

  void addCourt({required String name, required String type}) {
    totalCourts.value++;
    requests.value++;
    courts.insert(
      0,
      CourtModel(name: name, date: DateTime.now().toString().split(' ')[0], type: type),
    );
    update();
  }

  void startAutoRefresh() {
    refreshTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      loadStats(); // refresh every 15 seconds
    });
  }

  //load states of stateGrid Admin
  Future<void> loadStats() async {
    try {

      final pendingVendors = await AdminRequestApi.fetchPendingVendors();
      requests.value = pendingVendors.length;
      // final totalCourts = await UserFetchAllClubsApi.fetchAllPlaygrounds();
      // totalCourts.value =   totalCourts.length;
      // vendors.value = await VendorApi.count();
      // products.value = await ProductApi.count();
    } catch (e) {
      print("Error Failed to load dashboard stats ${e}");
    }
  }



}




class CourtModel {
  final String name;
  final String date;
  final String type;

  CourtModel({required this.name, required this.date, required this.type});
}
