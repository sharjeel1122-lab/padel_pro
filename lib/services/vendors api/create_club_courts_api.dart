import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class CreateVendorApi {
  // final _baseUrl = 'http://192.168.1.6:3000';
  static const String _baseUrl = 'https://padel-backend-git-main-invosegs-projects.vercel.app';

  final _storage = const FlutterSecureStorage();

  Future<String?> _getToken() async {
    return await _storage.read(key: 'token');
  }

  // ----------------- Create Playground (existing) -----------------
  Future<void> createPlayground(Map<String, dynamic> club, List<String> photoPaths) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception("Unauthorized: Token not found");

      final url = Uri.parse('$_baseUrl/api/v1/playground/createPlaygorund');
      final request = http.MultipartRequest('POST', url);
      request.headers['Authorization'] = 'Bearer $token';

      // fields that must be JSON-encoded
      final jsonFields = ['facilities', 'courts'];

      club.forEach((key, value) {
        if (jsonFields.contains(key)) {
          try {
            request.fields[key] = jsonEncode(value);
          } catch (_) {
            throw Exception('Invalid JSON format in field: $key');
          }
        } else {
          request.fields[key] = value.toString();
        }
      });

      for (String path in photoPaths) {
        final ext = path.split('.').last.toLowerCase();
        MediaType? contentType;

        if (ext == 'jpg' || ext == 'jpeg') {
          contentType = MediaType('image', 'jpeg');
        } else if (ext == 'png') {
          contentType = MediaType('image', 'png');
        } else {
          // Skip unsupported
          debugPrint("Unsupported image type: $path");
          continue;
        }

        final file = await http.MultipartFile.fromPath(
          'photos',
          path,
          contentType: contentType,
        );
        request.files.add(file);
      }

      if (request.files.isEmpty) {
        throw Exception("At least one valid image is required.");
      }

      final response = await request.send();
      final body = await response.stream.bytesToString();

      if (response.statusCode == 201) {
        final data = jsonDecode(body);
        debugPrint('✅ Playground Created: $data');
      } else {
        debugPrint('❌ Failed [${response.statusCode}]: $body');
        throw Exception('Error: ${response.statusCode}\n$body');
      }
    } catch (e) {
      debugPrint('❌ Exception: $e');
      rethrow;
    }
  }

  // ----------------- Add Courts (NEW) -----------------
  /// Adds one or more courts to an existing playground.
  /// Backend route (with path param): /api/v1/playground/addCourts/{playgroundId}
  ///
  /// Expected `courts` item shape:
  /// {
  ///   "courtNumber": "1",
  ///   "courtType": ["Indoor"],                // array, per backend
  ///   "pricing": [{"duration":60,"price":1200}],   // at least 1, durations in [30,60,90,120,150,180]
  ///   "peakHours": [{"startTime":"09:00","endTime":"12:00","price":1500}] // optional
  /// }
  Future<Map<String, dynamic>> addCourts({
    required String playgroundId,
    required List<Map<String, dynamic>> courts,
  }) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception("Unauthorized: Token not found");
    }

    // (Optional) quick client-side validation matching your backend rules
    if (courts.isEmpty) {
      throw Exception('At least one court is required');
    }

    final allowedDurations = {30, 60, 90, 120, 150, 180};
    final timeRe = RegExp(r'^(?:[01]\d|2[0-3]):[0-5]\d$');

    for (final c in courts) {
      if (!(c['courtNumber'] != null && c['courtType'] != null && c['pricing'] != null)) {
        throw Exception('Invalid court details');
      }
      final pricing = (c['pricing'] as List?) ?? [];
      if (pricing.isEmpty) throw Exception('At least one pricing option is required per court');

      for (final p in pricing) {
        if (!(p['duration'] != null && p['price'] != null)) {
          throw Exception('Invalid pricing details');
        }
        if (!allowedDurations.contains(p['duration'])) {
          throw Exception('Invalid duration value: ${p['duration']}');
        }
      }

      final peak = (c['peakHours'] as List?) ?? [];
      for (final ph in peak) {
        if (!(ph['startTime'] != null && ph['endTime'] != null && ph['price'] != null)) {
          throw Exception('Invalid peak hours details');
        }
        if (!timeRe.hasMatch(ph['startTime']) || !timeRe.hasMatch(ph['endTime'])) {
          throw Exception('Please enter valid time (HH:MM) for peak hours');
        }
      }
    }

    final url = Uri.parse('$_baseUrl/api/v1/playground/addCourts/$playgroundId');

    final res = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'courts': courts}),
    );

    final respBody = res.body.isNotEmpty ? jsonDecode(res.body) : {};

    if (res.statusCode >= 200 && res.statusCode < 300) {
      // Example response usually: { success, message, data: <updated playground> }
      return (respBody is Map<String, dynamic>) ? respBody : {'data': respBody};
    }

    final msg = (respBody is Map && respBody['message'] != null)
        ? respBody['message'].toString()
        : 'Failed to add courts (${res.statusCode})';
    throw Exception(msg);
  }
}




















// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
// import 'package:http_parser/http_parser.dart';
//
// class CreateVendorApi {
//   // final _baseUrl = 'http://192.168.1.6:3000';
//   static const String _baseUrl = 'https://padel-backend-git-main-invosegs-projects.vercel.app';
//
//   // // final _baseUrl = 'https://padel-backend-git-main-invosegs-projects.vercel.app';
//   // static const String _baseUrl = 'https://padel-backend-git-main-invosegs-projects.vercel.app';
//   final _storage = FlutterSecureStorage();
//
//   Future<String?> _getToken() async {
//     return await _storage.read(key: 'token');
//   }
//
//   Future<void> createPlayground(Map<String, dynamic> club, List<String> photoPaths) async {
//     try {
//       final token = await _getToken();
//       if (token == null) throw Exception("Unauthorized: Token not found");
//
//       final url = Uri.parse('$_baseUrl/api/v1/playground/createPlaygorund');
//       final request = http.MultipartRequest('POST', url);
//       request.headers['Authorization'] = 'Bearer $token';
//
//       final jsonFields = ['facilities', 'courts'];
//
//       club.forEach((key, value) {
//         if (jsonFields.contains(key)) {
//           try {
//             request.fields[key] = jsonEncode(value);
//           } catch (_) {
//             throw Exception('Invalid JSON format in field: $key');
//           }
//         } else {
//           request.fields[key] = value.toString();
//         }
//       });
//
//       for (String path in photoPaths) {
//         final ext = path.split('.').last.toLowerCase();
//         MediaType? contentType;
//
//         if (ext == 'jpg' || ext == 'jpeg') {
//           contentType = MediaType('image', 'jpeg');
//         } else if (ext == 'png') {
//           contentType = MediaType('image', 'png');
//         } else {
//           print(" Unsupported image type: $path");
//           continue;
//         }
//
//         final file = await http.MultipartFile.fromPath(
//           'photos',
//           path,
//           contentType: contentType,
//         );
//         request.files.add(file);
//       }
//
//       if (request.files.isEmpty) {
//         throw Exception("At least one valid image is required.");
//       }
//
//       final response = await request.send();
//       final body = await response.stream.bytesToString();
//
//       if (response.statusCode == 201) {
//         final data = jsonDecode(body);
//         print(' Playground Created: $data');
//         // Get.snackbar("Success", "Playground created!",
//         //     snackPosition: SnackPosition.BOTTOM,
//         //     backgroundColor: Colors.green,
//         //     colorText: Colors.white);
//       } else {
//         print('❌ Failed [${response.statusCode}]: $body');
//         throw Exception('Error: ${response.statusCode}\n$body');
//       }
//     } catch (e) {
//       print('❌ Exception: $e');
//       // Get.snackbar('Error', e.toString(),
//       //     backgroundColor: Colors.red, colorText: Colors.white);
//       rethrow;
//     }
//   }
// }
