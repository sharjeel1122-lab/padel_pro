// lib/screens/admin/vendors controllers/dashboard_controller.dart
import 'dart:async';
import 'dart:convert';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import 'package:padel_pro/services/admin%20api/admin_request_api.dart';
import 'package:padel_pro/services/user%20role%20api%20service/user_fetch_allclubs_api.dart';

class DashboardController extends GetxController {
  // NOTE: names kept to avoid breaking your UI:
  // totalCourts -> Total Users
  // vendors     -> Total Vendors
  // products    -> Total Clubs
  // requests    -> Pending Requests
  var totalCourts = 0.obs; // users
  var vendors = 0.obs;     // vendors
  var products = 0.obs;    // clubs
  var requests = 0.obs;    // pending
  var isLoading = false.obs; // loading state
  Timer? refreshTimer;

  // === Config ===
  static const String _baseUrl =
      'https://padel-backend-git-main-invosegs-projects.vercel.app';

  static const FlutterSecureStorage _secure = FlutterSecureStorage();

  // ✅ Instantiate the API that has instance methods
  final UserFetchAllClubsApi _clubsApi = UserFetchAllClubsApi();

  @override
  void onInit() {
    super.onInit();
    loadStats();
    startAutoRefresh();
  }

  // ------- Your existing demo list & helpers (kept) ------
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
      CourtModel(
        name: name,
        date: DateTime.now().toString().split(' ')[0],
        type: type,
      ),
    );
    update();
  }
  // -------------------------------------------------------

  void startAutoRefresh() {
    // Silent refresh every 5 seconds (no loading indicator)
    refreshTimer?.cancel();
    refreshTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      // Silent refresh without loading indicator
      _silentLoadStats();
    });
  }

  // Load dashboard stats
  Future<void> loadStats() async {
    try {
      isLoading.value = true;
      // Fetch in parallel for speed
      final results = await Future.wait<int>([
        _fetchTotalUsersCount(),                 // users
        _fetchTotalVendorsCount(),               // vendors
        _fetchTotalClubsCountUsingService(),     // clubs (instance API)
        _fetchPendingRequestsCountUsingService() // pending (your AdminRequestApi)
      ]);

      totalCourts.value = results[0];
      vendors.value     = results[1];
      products.value    = results[2];
      requests.value    = results[3];
    } catch (_) {
      // Keep last known values; no UI spam
    } finally {
      isLoading.value = false;
    }
  }

  // Manual refresh method (shows loading indicator)
  Future<void> refreshStats() async {
    await loadStats();
  }

  // Silent refresh method (no loading indicator)
  Future<void> _silentLoadStats() async {
    try {
      // Fetch in parallel for speed without setting loading state
      final results = await Future.wait<int>([
        _fetchTotalUsersCount(),                 // users
        _fetchTotalVendorsCount(),               // vendors
        _fetchTotalClubsCountUsingService(),     // clubs (instance API)
        _fetchPendingRequestsCountUsingService() // pending (your AdminRequestApi)
      ]);

      totalCourts.value = results[0];
      vendors.value     = results[1];
      products.value    = results[2];
      requests.value    = results[3];
    } catch (_) {
      // Keep last known values; no UI spam
    }
  }

  // ===== Helpers to call HTTP / existing services =====

  Future<Map<String, String>> _authHeaders() async {
    final token = await _secure.read(key: 'token');
    return {
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  // Users count from HTTP: GET /api/users
  Future<int> _fetchTotalUsersCount() async {
    try {
      final uri = Uri.parse('$_baseUrl/api/v1/admin-booking-management/all-users');

      final res = await http.get(uri, headers: await _authHeaders());

      if (res.statusCode >= 200 && res.statusCode < 300) {
        return _extractCount(_safeJson(res.body));
      }
    } catch (_) {}
    return 0;
  }

  Future<int> _fetchTotalVendorsCount() async {
    try {
      final uri = Uri.parse('$_baseUrl/api/v1/admin-booking-management/all-vendors');
      final res = await http.get(uri, headers: await _authHeaders());
      if (res.statusCode >= 200 && res.statusCode < 300) {
        return _extractCount(_safeJson(res.body));
      }
    } catch (_) {}
    return 0;
  }

  // Clubs count via your existing (instance) service
  Future<int> _fetchTotalClubsCountUsingService() async {
    try {
      final clubs = await _clubsApi.fetchAllPlaygrounds(); // <-- instance call
      return clubs.length;
    } catch (_) {
      // Optional HTTP fallback if your service fails
      try {
        final uri = Uri.parse('$_baseUrl/api/clubs');
        final res = await http.get(uri, headers: await _authHeaders());
        if (res.statusCode >= 200 && res.statusCode < 300) {
          return _extractCount(_safeJson(res.body));
        }
      } catch (_) {}
      return 0;
    }
  }

  // Pending requests via your existing AdminRequestApi
  Future<int> _fetchPendingRequestsCountUsingService() async {
    try {
      final pendingVendors = await AdminRequestApi.fetchPendingVendors();
      return pendingVendors.length;
    } catch (_) {
      // Optional HTTP fallback: /api/vendors?status=pending
      try {
        final uri = Uri.parse('$_baseUrl/api/vendors?status=pending');
        final res = await http.get(uri, headers: await _authHeaders());
        if (res.statusCode >= 200 && res.statusCode < 300) {
          return _extractCount(_safeJson(res.body));
        }
      } catch (_) {}
      return 0;
    }
  }

  Map<String, dynamic> _safeJson(String body) {
    if (body.isEmpty) return {};
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is List) return {'data': decoded};
      return {};
    } catch (_) {
      return {};
    }
  }

  int _extractCount(Map<String, dynamic> body) {
    final data = body['data'];

    if (data is List) return data.length;

    if (data is Map<String, dynamic>) {
      if (data['count'] is num) return (data['count'] as num).toInt();
      if (data['total'] is num) return (data['total'] as num).toInt();
      if (data['items'] is List) return (data['items'] as List).length;
      if (data['docs'] is List) return (data['docs'] as List).length;
    }

    if (body['count'] is num) return (body['count'] as num).toInt();
    if (body['total'] is num) return (body['total'] as num).toInt();
    if (body['data'] is List) return (body['data'] as List).length;

    return 0;
  }

  @override
  void onClose() {
    refreshTimer?.cancel();
    super.onClose();
  }
}

class CourtModel {
  final String name;
  final String date;
  final String type;

  CourtModel({required this.name, required this.date, required this.type});
}
