import 'package:get/get.dart';
import 'package:padel_pro/screens/admin/requests/request_model.dart'
    show RequestModel, RequestType;

class RequestController extends GetxController {
  // Source list (unfiltered)
  final _allRequests = <RequestModel>[
    RequestModel(name: "Ali Sports Ground", details: "Venue at Lahore", type: RequestType.venue),
    RequestModel(name: "Sara Vendors", details: "Vendor from Islamabad", type: RequestType.vendor),
  ].obs;

  // Reactive filtered list used by UI
  final requests = <RequestModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    // Initial state: show all requests
    requests.assignAll(_allRequests);
  }

  // 🔍 Search filter
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

  // ✅ Approve and remove from both lists
  void approveRequest(int index) {
    final approved = requests[index];
    // TODO: Send to backend if needed

    if (approved.type == RequestType.venue) {
      // Example: DashboardController.to.addVenue(approved);
    } else if (approved.type == RequestType.vendor) {
      // Example: DashboardController.to.addVendor(approved);
    }

    _allRequests.remove(approved);
    requests.removeAt(index);
  }

  // ❌ Decline and remove from both lists
  void declineRequest(int index) {
    final declined = requests[index];
    // TODO: Send to backend if needed

    _allRequests.remove(declined);
    requests.removeAt(index);
  }
}
