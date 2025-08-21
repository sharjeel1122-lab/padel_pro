import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Simple response model
class ApiResponse {
  final bool isOk;
  final int? statusCode;
  final String? message;
  final dynamic data;

  ApiResponse({required this.isOk, this.statusCode, this.message, this.data});
}

class RecommendedStatusService {
  static const String baseUrl =
      'https://padel-backend-git-main-invosegs-projects.vercel.app';

  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static Future<String?> _getToken() => _storage.read(key: 'token');

  Future<ApiResponse> updateRecommendedStatus({
    required String id,
    required bool recommended,
  }) async {
    final uri = Uri.parse('$baseUrl/api/v1/playground/updateRecommended/$id');

    try {
      final token = await _getToken();
      if (token == null || token.isEmpty) {
        return ApiResponse(
          isOk: false,
          message: 'Auth token missing. Save it first with FlutterSecureStorage.',
        );
      }

      final res = await http.patch(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'recommended': recommended}),
      );

      final body = res.body.isNotEmpty ? jsonDecode(res.body) : null;

      if (res.statusCode >= 200 && res.statusCode < 300) {
        return ApiResponse(
          isOk: true,
          statusCode: res.statusCode,
          message: (body is Map && body['message'] is String)
              ? body['message']
              : 'OK',
          data: body,
        );
      } else {
        return ApiResponse(
          isOk: false,
          statusCode: res.statusCode,
          message: (body is Map && (body['message'] ?? body['error']) is String)
              ? (body['message'] ?? body['error'])
              : 'Request failed',
          data: body,
        );
      }
    } catch (e) {
      return ApiResponse(isOk: false, message: e.toString());
    }
  }
}
