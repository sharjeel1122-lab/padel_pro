import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class VendorSignupApi {
  static const String _baseUrl = 'http://192.168.1.3:3000';
  Future<Map<String, dynamic>> signupVendor(
    Map<String, dynamic> data,
    File? photo,
  ) async {
    final uri = Uri.parse('$_baseUrl/api/vendor-signup-itself');
    var request = http.MultipartRequest('POST', uri);

    // Add fields
    data.forEach((key, value) {
      request.fields[key] = value.toString();
    });

    // Add photo if available
    if (photo != null) {
      request.files.add(await http.MultipartFile.fromPath('photo', photo.path));
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    final decoded = jsonDecode(response.body);

    if (response.statusCode == 201) {
      return {'status': 'success', ...decoded};
    } else {
      throw Exception(decoded['message'] ?? 'Signup failed');
    }
  }
}
