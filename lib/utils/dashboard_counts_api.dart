// lib/services/admin_api/dashboard_counts_api.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class DashboardCounts {
  final int users;
  final int vendors;
  final int clubs;
  final int pendingRequests;

  const DashboardCounts({
    required this.users,
    required this.vendors,
    required this.clubs,
    required this.pendingRequests,
  });
}

class DashboardCountsApi {
  static const String _baseUrl =
      'https://padel-backend-git-main-invosegs-projects.vercel.app';

  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  Future<Map<String, String>> _authHeaders() async {
    final token = await _storage.read(key: 'token');
    return {
      'Accept': 'application/json',
      'Cache-Control': 'no-cache',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Future<DashboardCounts> fetchCounts() async {
    // Your endpoints
    final usersUri   = Uri.parse('$_baseUrl/api/v1/admin-booking-management/all-users');
    final vendorsUri = Uri.parse('$_baseUrl/api/v1/admin-booking-management/all-vendors');
    final clubsUri   = Uri.parse('$_baseUrl/api/v1/playground/allPlaygorund'); // note: endpoint typo kept as-is
    final pendingUri = Uri.parse('$_baseUrl/api/v1/admin-booking-management/pending-vendors');

    final headers = await _authHeaders();

    final responses = await Future.wait([
      http.get(usersUri, headers: headers),
      http.get(vendorsUri, headers: headers),
      http.get(clubsUri, headers: headers),
      http.get(pendingUri, headers: headers),
    ]);

    final usersCount   = _usersCount(responses[0]);
    final vendorsCount = _vendorsCount(responses[1]);
    final clubsCount   = _clubsCount(responses[2]);
    final pendingCount = _pendingCount(responses[3]);

    if (kDebugMode) {
      print('[DashboardCountsApi] users=$usersCount vendors=$vendorsCount clubs=$clubsCount pending=$pendingCount');
    }

    return DashboardCounts(
      users: usersCount,
      vendors: vendorsCount,
      clubs: clubsCount,
      pendingRequests: pendingCount,
    );
  }

  // ----------------- Endpoint-specific extractors -----------------

  int _usersCount(http.Response res) {
    final body = _decodeOk(res);
    if (body == null) return 0;
    // Common shapes:
    // { data: [users...] }
    // { data: { users: [...] } }
    // { users: [...] }
    // { data: { totalUsers: N } } or { totalUsers: N } or { usersCount: N }
    return _pickCountByKeys(body,
      listKeys: const ['users', 'allUsers', 'userList'],
      numberKeys: const ['totalUsers', 'usersCount', 'count', 'total'],
    );
  }

  int _vendorsCount(http.Response res) {
    final body = _decodeOk(res);
    if (body == null) return 0;
    return _pickCountByKeys(body,
      listKeys: const ['vendors', 'allVendors', 'vendorList'],
      numberKeys: const ['totalVendors', 'vendorsCount', 'count', 'total'],
    );
  }

  int _clubsCount(http.Response res) {
    final body = _decodeOk(res);
    if (body == null) return 0;
    // Endpoint is "allPlaygorund" — often returns list under data or top-level
    return _pickCountByKeys(body,
      listKeys: const [
        'playgrounds', 'allPlaygorund', 'clubs', 'allClubs', 'clubList', 'playgroundList'
      ],
      numberKeys: const ['totalPlaygrounds', 'totalClubs', 'count', 'total'],
    );
  }

  int _pendingCount(http.Response res) {
    final body = _decodeOk(res);
    if (body == null) return 0;
    return _pickCountByKeys(body,
      listKeys: const ['pendingVendors', 'pending', 'requests', 'pendingRequests'],
      numberKeys: const ['totalPending', 'pendingCount', 'count', 'total'],
    );
  }

  // ----------------- Generic helpers -----------------

  Map<String, dynamic>? _decodeOk(http.Response res) {
    if (res.statusCode < 200 || res.statusCode >= 300) {
      if (kDebugMode) print('[_decodeOk] HTTP ${res.statusCode}');
      return null;
    }
    if (res.body.isEmpty) return {};
    try {
      final decoded = jsonDecode(res.body);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is List) return {'data': decoded};
      return {};
    } catch (_) {
      return {};
    }
  }

  /// Try multiple shapes:
  /// 1) If any of [listKeys] exist and is a List -> length
  ///    - check top-level AND under `data`
  /// 2) If any of [numberKeys] exist and is num -> value
  ///    - check top-level AND under `data`
  /// 3) Fallbacks:
  ///    - if `data` is a List -> length
  ///    - if any first list exists under top-level or data -> length
  ///    - if `count`/`total` exist anywhere -> number
  int _pickCountByKeys(
      Map<String, dynamic> body, {
        required List<String> listKeys,
        required List<String> numberKeys,
      }) {
    // 1) direct list keys (top-level)
    for (final key in listKeys) {
      final v = body[key];
      if (v is List) return v.length;
    }
    // 1b) list keys under data
    final data = body['data'];
    if (data is Map<String, dynamic>) {
      for (final key in listKeys) {
        final v = data[key];
        if (v is List) return v.length;
        if (v is Map<String, dynamic>) {
          // nested list (e.g., data.users.docs)
          final nested = _firstList(v);
          if (nested != null) return nested.length;
        }
      }
    }

    // 2) number keys (top-level)
    for (final key in numberKeys) {
      final v = body[key];
      if (v is num) return v.toInt();
    }
    // 2b) number keys under data
    if (data is Map<String, dynamic>) {
      for (final key in numberKeys) {
        final v = data[key];
        if (v is num) return v.toInt();
      }
    }

    // 3) fallbacks
    if (data is List) return data.length;
    if (data is Map<String, dynamic>) {
      final anyListInData = _firstList(data);
      if (anyListInData != null) return anyListInData.length;
      final c = _pickNumber(data);
      if (c != null) return c;
    }

    final anyTopList = _firstList(body);
    if (anyTopList != null) return anyTopList.length;

    final cTop = _pickNumber(body);
    if (cTop != null) return cTop;

    return 0;
  }

  int? _pickNumber(Map<String, dynamic> m) {
    for (final key in const ['count', 'total', 'totalCount', 'totalDocs']) {
      final v = m[key];
      if (v is num) return v.toInt();
    }
    return null;
  }

  /// First list found either at top level or one level deeper
  List<dynamic>? _firstList(Map<String, dynamic> m) {
    for (final v in m.values) {
      if (v is List) return v;
    }
    for (final v in m.values) {
      if (v is Map<String, dynamic>) {
        for (final vv in v.values) {
          if (vv is List) return vv;
        }
      }
    }
    return null;
  }
}
