import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class VendorCreateApi {
  final String _baseUrl =
      'https://padel-backend-git-main-invosegs-projects.vercel.app';

  static final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Read admin JWT from secure storage (stored under 'token')
  static Future<String?> _getToken() async {
    return _storage.read(key: 'token');
  }

  Future<Map<String, dynamic>> createVendorByAdmin(
      Map<String, dynamic> data,
      File? photo, {
        String? bearerToken, // if not provided, we'll read from secure storage
      }) async {
    final uri = Uri.parse('$_baseUrl/api/vendors');
    final request = http.MultipartRequest('POST', uri);

    // Resolve token: prefer explicit bearerToken, else read from storage
    final token = (bearerToken != null && bearerToken.isNotEmpty)
        ? bearerToken
        : await _getToken();

    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    request.headers['Accept'] = 'application/json';

    // Add fields
    data.forEach((key, value) {
      if (value != null) request.fields[key] = value.toString();
    });

    // Add photo (backend requires it)
    if (photo != null) {
      request.files.add(await http.MultipartFile.fromPath('photo', photo.path));
    } else {
      // If you want to fail early instead of letting backend return 400:
      // throw Exception('photo is required');
    }

    // Send request
    late http.Response response;
    try {
      final streamed = await request.send();
      response = await http.Response.fromStream(streamed);
    } on SocketException {
      throw Exception('Network error. Check your internet connection.');
    }

    // Decode body if JSON
    Map<String, dynamic> decoded = {};
    if (response.body.isNotEmpty) {
      try {
        decoded = jsonDecode(response.body) as Map<String, dynamic>;
      } catch (_) {
        // leave decoded empty on non-JSON response
      }
    }

    final code = response.statusCode;

    // Treat any 2xx as success (some deployments return 200 instead of 201)
    if (code >= 200 && code < 300) {
      return {
        'status': 'success',
        'code': code,
        ...decoded,
      };
    }

    // Error path
    final msg = (decoded['message'] ??
        response.reasonPhrase ??
        'Request failed with $code')
        .toString();
    throw Exception(msg);
  }
}
