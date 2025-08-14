// lib/services/admin_request_api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:padel_pro/screens/admin/requests/request_model.dart';

class AdminRequestApi {
  static const String baseUrl = 'https://padel-backend-git-main-invosegs-projects.vercel.app';
  static final FlutterSecureStorage _storage = FlutterSecureStorage();

  // Get auth token
  static Future<String?> _getToken() async {
    return await _storage.read(key: 'token');
  }


  static Future<List<RequestModel>> fetchPendingVendors() async {
    final token = await _getToken();
    final uri = Uri.parse('$baseUrl/api/v1/admin-booking-management/pending-vendors');

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print("Fetch Response (${response.statusCode}): ${response.body}");

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      final List data = result['data']['data'];
      return data.map<RequestModel>((json) => RequestModel.fromJson(json)).toList();
    } else {
      throw Exception("Failed to fetch vendors: ${response.body}");
    }
  }

  // 🔁 Update vendor status (approve or reject)



  static Future<void> updateVendorStatus(String vendorId, String status) async {
    final token = await _getToken();
    final uri = Uri.parse('$baseUrl/api/vendors/approve/');

    final response = await http.put(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'vendorId': vendorId,
        'status': status,
      }),
    );

    print("Update Response (${response.statusCode}): ${response.body}");

    if (response.statusCode != 200) {
      throw Exception("Failed to update status: ${response.body}");
    }
  }

}
