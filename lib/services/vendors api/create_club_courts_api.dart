import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class CreateVendorApi {
  final _baseUrl = 'http://192.168.0.102:3000';
  final _storage = const FlutterSecureStorage();

  // Get token from FlutterSecureStorage
  Future<String?> _getToken() async {
    return await _storage.read(key: 'token');
  }

  // Create playground (with photos)
  Future<void> createPlayground(Map<String, dynamic> data, List<String> photoPaths) async {
    try {
      final token = await _getToken();

      if (token == null) throw Exception("Unauthorized. Token missing or expired.");

      final url = Uri.parse('$_baseUrl/api/v1/playground/createPlaygorund');

      var request = http.MultipartRequest('POST', url);
      request.headers['Authorization'] = 'Bearer $token';

      // Add fields
      data.forEach((key, value) {
        request.fields[key] = value.toString();
      });

      // Add supported images only
      for (String path in photoPaths) {
        final ext = path.split('.').last.toLowerCase();
        MediaType? contentType;

        switch (ext) {
          case 'jpg':
          case 'jpeg':
            contentType = MediaType('image', 'jpeg');
            break;
          case 'png':
            contentType = MediaType('image', 'png');
            break;
          case 'gif':
            contentType = MediaType('image', 'gif');
            break;
          default:
            continue; // skip unsupported file
        }

        request.files.add(
          await http.MultipartFile.fromPath(
            'photos',
            path,
            contentType: contentType,
          ),
        );
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 201) {
        Get.snackbar(
          "Success",
          "Playground created successfully!",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        print('✅ Playground created: ${jsonDecode(responseBody)}');
      } else {
        throw Exception(
          '❌ Failed. Status: ${response.statusCode}, Body: $responseBody',
        );
      }
    } catch (e) {
      print('❌ Error: $e');
      Get.snackbar('Error', e.toString(), backgroundColor: Colors.red, colorText: Colors.white);
      rethrow;
    }
  }

  // Get all vendor's playgrounds
  Future<List<dynamic>> getVendorPlaygrounds() async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception("Unauthorized. Token missing or expired.");

      final url = Uri.parse('$_baseUrl/api/v1/playground/vendor');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return decoded['data'] ?? [];
      } else {
        throw Exception(
          '❌ Failed to fetch playgrounds. Status: ${response.statusCode}, Body: ${response.body}',
        );
      }
    } catch (e) {
      print('Error in getVendorPlaygrounds API call: $e');
      rethrow;
    }
  }
}
