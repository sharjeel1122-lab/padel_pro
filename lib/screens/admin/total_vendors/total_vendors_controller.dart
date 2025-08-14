import 'dart:async';
import 'package:get/get.dart';
import 'package:padel_pro/model/vendors model/vendors_model.dart';
import 'package:padel_pro/services/admin api/fetch_all_vendors.dart';

class TotalVendorsController extends GetxController {
  final FetchAllVendorsApi service = FetchAllVendorsApi();

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

  /// Fetch vendors. If [silent] is true, avoid noisy snackbars (for initial splash).
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

// // If your UI uses delete:
// Future<void> deleteVendor(int index) async {
//   final item = filteredVendors[index];
//   final i = vendors.indexWhere((v) => v.id == item.id);
//   if (i == -1) return;
//
//   final backup = vendors[i];
//   vendors.removeAt(i); // optimistic
//
//   try {
//     final ok = await service.deleteVendor(item.id);
//     if (!ok) {
//       vendors.insert(i, backup);
//       Get.snackbar("Delete failed", "Could not delete vendor");
//     } else {
//       Get.snackbar("Deleted", "Vendor removed successfully");
//     }
//   } catch (e) {
//     vendors.insert(i, backup);
//     Get.snackbar("Error", e.toString());
//   }
// }
}
