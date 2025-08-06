import 'package:get/get.dart';
import 'package:padel_pro/services/admin%20api/admin_request_api.dart';
import 'request_model.dart';


class RequestController extends GetxController {
  final _allRequests = <RequestModel>[].obs;
  final requests = <RequestModel>[].obs;
  final isRefreshing = false.obs;

  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPendingVendors(); // Load data from backend on init
  }

  // 🟡 Fetch pending vendors from backend
  // Future<void> fetchPendingVendors() async {
  //   isLoading.value = true;
  //
  //   try {
  //     final vendorList = await AdminRequestApi.fetchPendingVendors();
  //     _allRequests.assignAll(vendorList);
  //     requests.assignAll(vendorList);
  //   } catch (e) {
  //     print("Error" "Failed to load requests: ${e}");
  //     // Get.snackbar("Error", "Failed to load requests: $e");
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }

  Future<void> fetchPendingVendors({bool isPullRefresh = false}) async {
    if (isPullRefresh) {
      isRefreshing.value = true;
    } else {
      isLoading.value = true;
    }

    try {
      // simulate network delay or fetch your vendors here
      await Future.delayed(Duration(seconds: 1));

      // Replace with your actual fetch logic
      final response = await AdminRequestApi.fetchPendingVendors();
      requests.value = response; // update list
    } finally {
      if (isPullRefresh) {
        isRefreshing.value = false;
      } else {
        isLoading.value = false;
      }
    }
  }







  // 🔍 Search logic remains same
  void search(String query) {
    final trimmed = query.trim().toLowerCase();
    if (trimmed.isEmpty) {
      requests.assignAll(_allRequests);
    } else {
      requests.assignAll(_allRequests.where((req) =>
      req.name.toLowerCase().contains(trimmed) ||
          req.details.toLowerCase().contains(trimmed) ||
          req.type.name.toLowerCase().contains(trimmed)
      ));
    }
  }

  // ✅ Approve a vendor
  Future<void> approveRequest(int index) async {
    final request = requests[index];

    try {
      await AdminRequestApi.updateVendorStatus(request.id, 'approved');
      print("Success, ${request.name} approved");
      // Get.snackbar("Success", "${request.name} approved");

      _allRequests.remove(request);
      requests.removeAt(index);
    } catch (e) {
      print("Error" "Failed to approve: ${e}");
      // Get.snackbar("Error", "Failed to approve: $e");
    }
  }

  // ❌ Decline a vendor
  Future<void> declineRequest(int index) async {
    final request = requests[index];

    try {
      await AdminRequestApi.updateVendorStatus(request.id, 'rejected');
      print("Declined, ${request.name} rejected");
      // Get.snackbar("Declined", "${request.name} rejected");

      _allRequests.remove(request);
      requests.removeAt(index);
    } catch (e) {
      print("Error" "Failed to decline: ${e}");
      // Get.snackbar("Error", "Failed to decline: $e");

    }
  }
}













// import 'package:get/get.dart';
// import 'package:padel_pro/screens/admin/requests/request_model.dart'
//     show RequestModel, RequestType;
//
// class RequestController extends GetxController {
//   // Source list (unfiltered)
//   final _allRequests = <RequestModel>[
//     RequestModel(name: "Ali Sports Ground", details: "Venue at Lahore", type: RequestType.venue),
//     RequestModel(name: "Sara Vendors", details: "Vendor from Islamabad", type: RequestType.vendor),
//   ].obs;
//
//   // Reactive filtered list used by UI
//   final requests = <RequestModel>[].obs;
//
//   @override
//   void onInit() {
//     super.onInit();
//     // Initial state: show all requests
//     requests.assignAll(_allRequests);
//   }
//
//   // 🔍 Search filter
//   void search(String query) {
//     final trimmed = query.trim().toLowerCase();
//     if (trimmed.isEmpty) {
//       requests.assignAll(_allRequests);
//     } else {
//       requests.assignAll(_allRequests.where((req) =>
//       req.name.toLowerCase().contains(trimmed) ||
//           req.details.toLowerCase().contains(trimmed) ||
//           req.type.name.toLowerCase().contains(trimmed)
//       ));
//     }
//   }
//
//   // ✅ Approve and remove from both lists
//   void approveRequest(int index) {
//     final approved = requests[index];
//     // TODO: Send to backend if needed
//
//     if (approved.type == RequestType.venue) {
//       // Example: DashboardController.to.addVenue(approved);
//     } else if (approved.type == RequestType.vendor) {
//       // Example: DashboardController.to.addVendor(approved);
//     }
//
//     _allRequests.remove(approved);
//     requests.removeAt(index);
//   }
//
//   // ❌ Decline and remove from both lists
//   void declineRequest(int index) {
//     final declined = requests[index];
//     // TODO: Send to backend if needed
//
//     _allRequests.remove(declined);
//     requests.removeAt(index);
//   }
// }
