import 'dart:ui';

import 'package:get/get.dart';
import '../../../model/vendor_model.dart';

class TotalVendorsController extends GetxController {
  final vendors = <VendorModel>[].obs;
  final searchQuery = ''.obs;

  List<VendorModel> get filteredVendors {
    if (searchQuery.isEmpty) return vendors;
    final query = searchQuery.value.toLowerCase();
    return vendors.where((v) {
      return v.name.toLowerCase().contains(query) ||
          v.email.toLowerCase().contains(query) ||
          v.phone.toLowerCase().contains(query);
    }).toList();
  }

  void search(String query) {
    searchQuery.value = query;
  }

  void deleteVendor(int index) {
    vendors.removeAt(index);
  }

  void editVendor(int index) {
    // For now: just show snackbar
    Get.snackbar("Edit", "Edit vendor: ${vendors[index].name}",
        backgroundColor: const Color(0xFF0A3B5C),
        colorText: const Color(0xFFFFFFFF));
  }

  @override
  void onInit() {
    vendors.addAll([
      VendorModel(name: "Asad Ali", email: "asad@gmail.com", phone: "03001234567", location: "Lahore"),
      VendorModel(name: "Ahmed Khan", email: "ahmed@gmail.com", phone: "03121234567", location: "Karachi"),
      VendorModel(name: "Sara Iqbal", email: "sara@gmail.com", phone: "03211234567", location: "Islamabad"),
    ]);
    super.onInit();
  }
}
