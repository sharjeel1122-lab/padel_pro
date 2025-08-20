import 'dart:async';
import 'package:get/get.dart';
import 'package:padel_pro/model/vendors model/vendors_model.dart';
import 'package:padel_pro/services/admin api/fetch_all_vendors.dart';
import 'package:padel_pro/services/admin api/delete_vendor_api.dart';

class TotalVendorsController extends GetxController {
  final FetchAllVendorsApi service = FetchAllVendorsApi();
  final DeleteVendorApi deleteService = DeleteVendorApi();

  final vendors = <VendorsModel>[].obs;
  final searchQuery = ''.obs;
  final isLoading = true.obs;

  List<VendorsModel> get filteredVendors {
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isEmpty) return vendors;
    return vendors.where((v) {
      final fullName = "${v.firstName} ${v.lastName}".toLowerCase();
      return fullName.contains(q) ||
          v.email.toLowerCase().contains(q) ||
          (v.phone?.toLowerCase().contains(q) ?? false) ||
          (v.city?.toLowerCase().contains(q) ?? false) ||
          (v.ntn?.toLowerCase().contains(q) ?? false);
    }).toList();
  }

  @override
  void onInit() {
    super.onInit();
    _loadWithMinimumDelay();
  }

  void search(String query) => searchQuery.value = query;

  // Initial load with a minimum of 10s splash
  Future<void> _loadWithMinimumDelay() async {
    isLoading.value = true;
    final start = DateTime.now();

    await fetchAllVendors(silent: true);

    final elapsed = DateTime.now().difference(start);
    const minWait = Duration(seconds: 10);
    final remaining = minWait - elapsed;
    if (remaining > Duration.zero) {
      await Future.delayed(remaining);
    }
    isLoading.value = false;
  }

  Future<void> fetchAllVendors({bool silent = false}) async {
    try {
      final result = await service.fetchVendors(); // returns List<VendorsModel>
      vendors.assignAll(result);
    } catch (e) {
      if (!silent) {
        Get.snackbar("Error", e.toString());
      }
    }
  }

  Future<bool> deleteVendorById(String vendorId) async {
    try {
      return await deleteService.deleteVendorById(vendorId);
    } catch (e) {
      Get.snackbar("Error", e.toString());
      return false;
    }
  }
}
