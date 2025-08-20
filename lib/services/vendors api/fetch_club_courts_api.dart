import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class FetchVendorApi {
  // final _baseUrl = 'http://192.168.1.6:3000';
  final String _baseUrl = 'https://padel-backend-git-main-invosegs-projects.vercel.app';

  final _storage = const FlutterSecureStorage();

  Future<String?> _getToken() async => await _storage.read(key: 'token');

  Future<List<dynamic>> getVendorPlaygrounds() async {
    try {
      final token = await _getToken();

      if (token == null) {
        throw Exception("❌ Missing token. Please log in again.");
      }

      final url = Uri.parse('$_baseUrl/api/v1/playground/vendorsPlaygound');
      print('🔄 GET: $url');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        print('✅ Vendor playgrounds fetched: ${decoded['data']['count']}');
        return decoded['data']['data']; // returns a List of playgrounds
      } else {
        throw Exception(
          '❌ Error ${response.statusCode}: ${response.reasonPhrase}\n${response.body}',
        );
      }
    } catch (e) {
      print('🚨 getVendorPlaygrounds error: $e');
      rethrow;
    }
  }

  //Delete Playground API
  Future<void> deletePlaygroundById(String id) async {
    final token = await _storage.read(key: 'token'); //
    final uri = Uri.parse('$_baseUrl/api/v1/playground/delete/$id');

    final response = await http.delete(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete playground');
    }
  }



  // Update Playground (Multipart approach like tournament update)

  Future<Map<String, dynamic>> updatePlaygroundById(
      String id,
      Map<String, dynamic> payload, {
        List<File>? photoFiles, // new photos picked from device
        List<String>? removePhotoUrls, // URLs to remove from gallery
      }) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception("❌ Token missing. Please log in again.");
      }

      final url = Uri.parse('$_baseUrl/api/v1/playground/update/$id');
      print("🔄 PATCH (multipart): $url");

      final request = http.MultipartRequest("PATCH", url);

      // Headers
      request.headers['Authorization'] = 'Bearer $token';

      // Add text fields
      payload.forEach((key, value) {
        if (value == null) return;
        if (key == "facilities" && value is List) {
          // facilities must be JSON string
          request.fields[key] = jsonEncode(value);
        } else if (key == "photos" && value is List) {
          // keep remaining photos
          request.fields[key] = jsonEncode(value);
        } else {
          request.fields[key] = value.toString();
        }
      });

      // If frontend supports removing photos
      if (removePhotoUrls != null && removePhotoUrls.isNotEmpty) {
        request.fields['removePhotoUrls'] = jsonEncode(removePhotoUrls);
      }

      // Attach new photo files
      if (photoFiles != null && photoFiles.isNotEmpty) {
        for (final file in photoFiles) {
          request.files.add(await http.MultipartFile.fromPath("photos", file.path));
        }
      }

      // Send request
      final response = await request.send();
      final resBody = await response.stream.bytesToString();
      print("📩 Response: $resBody");

      if (response.statusCode == 200) {
        return jsonDecode(resBody);
      } else {
        throw Exception(
          '❌ Error ${response.statusCode}: ${response.reasonPhrase}\n$resBody',
        );
      }
    } catch (e) {
      print("🚨 updatePlaygroundById error: $e");
      rethrow;
    }
  }




  //////END///////






  //Update Courts
  Future<Map<String, dynamic>> updateCourtById(
    String id,
    Map<String, dynamic> payload,
  ) async {
    final token = await _getToken();
    if (token == null) throw Exception('Missing token');
    final uri = Uri.parse('$_baseUrl/api/v1/playground/updateCourts/$id');
    print('🔄 PATCH courts: $uri');
    try {
      final res = await http.patch(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      );
      if (res.statusCode >= 200 && res.statusCode < 300) {
        return jsonDecode(res.body) as Map<String, dynamic>;
      } else {
        dynamic errorBody;
        try {
          errorBody = jsonDecode(res.body);
        } catch (_) {
          errorBody = res.body;
        }
        final msg = (errorBody is Map && errorBody['message'] != null)
            ? errorBody['message']
            : 'HTTP ${res.statusCode}: ${res.reasonPhrase ?? 'Unknown error'}';
        throw Exception('Update failed: $msg');
      }
    } catch (e) {
      rethrow;
    }
  }
}


