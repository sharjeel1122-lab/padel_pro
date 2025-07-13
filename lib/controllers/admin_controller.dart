// controllers/admin_controller.dart
import 'package:get/get.dart';

class Vendor {
  final String id;
  final String name;
  final List<Court> courts;

  Vendor({required this.id, required this.name, required this.courts});
}

class Court {
  final String id;
  final String title;
  final String location;
  final int price;

  Court({required this.id, required this.title, required this.location, required this.price});
}

class AdminController extends GetxController {
  final vendors = <Vendor>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchVendors();
  }

  void fetchVendors() {
    vendors.assignAll([
      Vendor(
        id: 'v1',
        name: 'Vendor A',
        courts: [
          Court(id: 'c1', title: 'Court 1', location: 'Karachi', price: 3000),
          Court(id: 'c2', title: 'Court 2', location: 'Lahore', price: 2500),
        ],
      ),
      Vendor(
        id: 'v2',
        name: 'Vendor B',
        courts: [
          Court(id: 'c3', title: 'Court A', location: 'Islamabad', price: 2800),
        ],
      ),
    ]);
  }

  void deleteCourt(String vendorId, String courtId) {
    final vendorIndex = vendors.indexWhere((v) => v.id == vendorId);
    if (vendorIndex != -1) {
      vendors[vendorIndex].courts.removeWhere((c) => c.id == courtId);
      vendors.refresh();
    }
  }

  void updateCourt(String vendorId, Court updatedCourt) {
    final vendor = vendors.firstWhere((v) => v.id == vendorId);
    final courtIndex = vendor.courts.indexWhere((c) => c.id == updatedCourt.id);
    if (courtIndex != -1) {
      vendor.courts[courtIndex] = updatedCourt;
      vendors.refresh();
    }
  }
}
