import 'dart:async';
import 'package:get/get.dart';
import 'package:padel_pro/services/admin api/admin_request_api.dart';
import 'request_model.dart';

class RequestController extends GetxController {
  // Full source list (for search)
  final _allRequests = <RequestModel>[].obs;

  // List the UI reads from
  final requests = <RequestModel>[].obs;

  // UI states (used only for explicit/manual loads)
  final isRefreshing = false.obs;
  final isLoading = false.obs;

  // ---- auto refresh every 3s (silent) ----
  Timer? _autoTimer;
  bool _isAutoRefreshing = false;

  @override
  void onInit() {
    super.onInit();
    // First load (shows loader once)
    fetchPendingVendors();
    // Start silent polling
    _startAutoRefresh();
  }

  @override
  void onClose() {
    _autoTimer?.cancel();
    super.onClose();
  }

  void _startAutoRefresh() {
    _autoTimer?.cancel();
    _autoTimer = Timer.periodic(const Duration(seconds: 3), (_) => _silentRefresh());
  }

  Future<void> _silentRefresh() async {
    if (_isAutoRefreshing) return; // prevent overlap
    _isAutoRefreshing = true;
    try {
      final response = await AdminRequestApi.fetchPendingVendors();
      // Update both so search stays correct
      _allRequests.assignAll(response);
      requests.assignAll(response);
    } catch (_) {
      // swallow silently — no toasts/snackbars/log spam
    } finally {
      _isAutoRefreshing = false;
    }
  }

  // Manual fetch (optional UI pull-to-refresh / initial load)
  Future<void> fetchPendingVendors({bool isPullRefresh = false}) async {
    if (isPullRefresh) {
      isRefreshing.value = true;
    } else {
      isLoading.value = true;
    }

    try {
      final response = await AdminRequestApi.fetchPendingVendors();
      _allRequests.assignAll(response);
      requests.assignAll(response);
    } catch (e) {
      // Keep silent or log if you want:
      // debugPrint('fetchPendingVendors error: $e');
    } finally {
      if (isPullRefresh) {
        isRefreshing.value = false;
      } else {
        isLoading.value = false;
      }
    }
  }

  // 🔍 Search
  void search(String query) {
    final trimmed = query.trim().toLowerCase();
    if (trimmed.isEmpty) {
      requests.assignAll(_allRequests);
      return;
    }
    requests.assignAll(
      _allRequests.where(
            (req) =>
        req.name.toLowerCase().contains(trimmed) ||
            req.details.toLowerCase().contains(trimmed) ||
            req.type.name.toLowerCase().contains(trimmed),
      ),
    );
  }

  // ✅ Approve
  Future<void> approveRequest(int index) async {
    final request = requests[index];
    try {
      await AdminRequestApi.updateVendorStatus(request.id, 'approved');
      // Remove from both lists so search + UI stay in sync
      _allRequests.remove(request);
      requests.removeAt(index);
    } catch (e) {
      // debugPrint('approveRequest error: $e');
    }
  }

  // ❌ Decline
  Future<void> declineRequest(int index) async {
    final request = requests[index];
    try {
      await AdminRequestApi.updateVendorStatus(request.id, 'rejected');
      _allRequests.remove(request);
      requests.removeAt(index);
    } catch (e) {
      // debugPrint('declineRequest error: $e');
    }
  }
}
