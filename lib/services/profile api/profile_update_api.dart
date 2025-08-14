import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ProfileUpdateApi {
  /// Adjust only these if needed
  static const String baseUrl = "https://padel-backend-git-main-invosegs-projects.vercel.app";
  static const String primaryPath = "/api/update-profile";
  static const String altPath = "/api/update-profile/update"; // fallback if server uses /update

  static const _storage = FlutterSecureStorage();

  /// Public API
  Future<Map<String, dynamic>> updateProfile({
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? city,
    String? town,
    File? photoFile,
  }) async {
    final token = await _storage.read(key: 'token');
    if (token == null || token.isEmpty) {
      throw Exception("Missing auth token");
    }

    final hasAnyTextField =
        (firstName?.trim().isNotEmpty ?? false) ||
            (lastName?.trim().isNotEmpty ?? false) ||
            (email?.trim().isNotEmpty ?? false) ||
            (phone?.trim().isNotEmpty ?? false) ||
            (city?.trim().isNotEmpty ?? false) ||
            (town?.trim().isNotEmpty ?? false);

    final hasPhoto = photoFile != null;
    if (!hasAnyTextField && !hasPhoto) {
      throw Exception("At least one field (firstName, lastName, email, phone, city, town, photo) must be provided.");
    }

    // Build the payload
    final Map<String, String> textPayload = {};
    void put(String k, String? v) {
      if (v != null && v.trim().isNotEmpty) textPayload[k] = v.trim();
    }

    put('firstName', firstName);
    put('lastName',  lastName);
    put('email',     email);
    put('phone',     phone);
    put('city',      city);
    put('town',      town);

    // Try a sequence of (path, method) pairs to survive minor backend differences
    final attempts = <_Attempt>[
      // Most typical first:
      _Attempt(path: primaryPath, method: _HttpMethod.patch),
      _Attempt(path: primaryPath, method: _HttpMethod.put),
      _Attempt(path: "$primaryPath/update", method: _HttpMethod.patch),
      _Attempt(path: "$primaryPath/update", method: _HttpMethod.put),
      // Alternate root supplied:
      _Attempt(path: altPath, method: _HttpMethod.patch),
      _Attempt(path: altPath, method: _HttpMethod.put),
      // Last resort (some setups accept POST):
      _Attempt(path: primaryPath, method: _HttpMethod.post),
      _Attempt(path: "$primaryPath/update", method: _HttpMethod.post),
      _Attempt(path: altPath, method: _HttpMethod.post),
    ];

    final errors = <String>[];

    for (final attempt in attempts) {
      final uri = Uri.parse("$baseUrl${attempt.path}");
      try {
        http.Response res;

        if (hasPhoto) {
          res = await _sendMultipart(
            uri: uri,
            token: token,
            method: attempt.method,
            fields: textPayload,
            photoFile: photoFile!,
          );
        } else {
          res = await _sendJson(
            uri: uri,
            token: token,
            method: attempt.method,
            jsonBody: textPayload,
          );
        }

        _logResponseBrief(attempt, res);

        // Accept 200 OK, 201 Created, 204 No Content as success
        if (res.statusCode == 200 || res.statusCode == 201 || res.statusCode == 204) {
          final map = _safeDecode(res.body);
          return _extractPayload(map, res.statusCode);
        }

        // If it's a 404, we should try the next attempt (path/method combo)
        if (res.statusCode == 404) {
          errors.add(_formatError(attempt, res));
          continue;
        }

        // Non-404 error -> stop and throw with details
        throw Exception(_formatError(attempt, res));
      } catch (e) {
        // Network or other error -> collect and try next
        errors.add("Attempt ${attempt.method.name.toUpperCase()} ${attempt.path} failed: $e");
      }
    }

    // If we exit the loop, all attempts failed
    final err = (errors.isNotEmpty) ? errors.join("\n") : "Unknown error";
    debugPrint("❌ Profile update failed after all attempts:\n$err");
    throw Exception("Update failed. Last errors:\n$err");
  }

  // ============================================================
  // Internal helpers
  // ============================================================

  Future<http.Response> _sendJson({
    required Uri uri,
    required String token,
    required _HttpMethod method,
    required Map<String, String> jsonBody,
  }) async {
    final headers = <String, String>{
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'User-Agent': 'PadelPro/1.0 (Flutter)',
    };

    final body = jsonEncode(jsonBody);
    _logRequest(uri: uri, method: method, headers: headers, bodyPreview: body);

    switch (method) {
      case _HttpMethod.patch:
        return http
            .patch(uri, headers: headers, body: body)
            .timeout(const Duration(seconds: 30));
      case _HttpMethod.put:
        return http
            .put(uri, headers: headers, body: body)
            .timeout(const Duration(seconds: 30));
      case _HttpMethod.post:
        return http
            .post(uri, headers: headers, body: body)
            .timeout(const Duration(seconds: 30));
    }
  }

  Future<http.Response> _sendMultipart({
    required Uri uri,
    required String token,
    required _HttpMethod method,
    required Map<String, String> fields,
    required File photoFile,
  }) async {
    final req = http.MultipartRequest(method.name.toUpperCase(), uri);

    req.headers['Authorization'] = 'Bearer $token';
    req.headers['Accept'] = 'application/json';
    req.headers['User-Agent'] = 'PadelPro/1.0 (Flutter)';

    fields.forEach((k, v) => req.fields[k] = v);

    // NOTE: server field name is "photo" (change if backend expects "image")
    req.files.add(await http.MultipartFile.fromPath('photo', photoFile.path));

    _logMultipartPreview(uri: uri, method: method, headers: req.headers, fields: fields, filePath: photoFile.path);

    final streamed = await req.send().timeout(const Duration(seconds: 60));
    final res = await http.Response.fromStream(streamed);
    return res;
  }

  Map<String, dynamic> _extractPayload(Map<String, dynamic> map, int statusCode) {
    // If server sends { data: {...}, message: "..." }
    final data = (map['data'] is Map)
        ? Map<String, dynamic>.from(map['data'])
        : <String, dynamic>{};

    final message = (map['message'] is String) ? (map['message'] as String) : null;

    if (statusCode == 204) {
      // No body expected; just return a synthetic success map
      return {
        ...data,
        '_message': message ?? 'Profile updated successfully',
        '_statusCode': statusCode,
      };
    }

    if (message != null && message.isNotEmpty) {
      return {
        ...data,
        '_message': message,
        '_statusCode': statusCode,
      };
    }

    // Fall back to full map if shape is different
    return {
      ...map,
      if (!map.containsKey('_statusCode')) '_statusCode': statusCode,
    };
  }

  Map<String, dynamic> _safeDecode(String body) {
    if (body.isEmpty) return {};
    try {
      final decoded = jsonDecode(body);
      return decoded is Map<String, dynamic> ? decoded : {'raw': decoded};
    } catch (_) {
      return {'raw': body};
    }
  }

  // ============================================================
  // Logging (debug console prints)
  // ============================================================

  void _logRequest({
    required Uri uri,
    required _HttpMethod method,
    required Map<String, String> headers,
    String? bodyPreview,
  }) {
    debugPrint("➡️  ${method.name.toUpperCase()} $uri");
    debugPrint("   Headers: ${_pretty(headers)}");
    if (bodyPreview != null && bodyPreview.isNotEmpty) {
      debugPrint("   Body: ${_truncate(bodyPreview, 1500)}");
    }
    debugPrint("   cURL:\n${_curl(method, uri, headers, bodyPreview)}");
  }

  void _logMultipartPreview({
    required Uri uri,
    required _HttpMethod method,
    required Map<String, String> headers,
    required Map<String, String> fields,
    required String filePath,
  }) {
    debugPrint("➡️  ${method.name.toUpperCase()} (multipart) $uri");
    debugPrint("   Headers: ${_pretty(headers)}");
    debugPrint("   Fields: ${_pretty(fields)}");
    debugPrint("   File: $filePath");
    debugPrint("   cURL (approx):\n${_curlMultipart(method, uri, headers, fields, filePath)}");
  }

  void _logResponseBrief(_Attempt attempt, http.Response res) {
    final preview = _truncate(res.body, 1500);
    debugPrint("⬅️  ${res.statusCode} ${attempt.method.name.toUpperCase()} ${attempt.path}");
    debugPrint("   Response headers: ${_pretty(res.headers)}");
    debugPrint("   Response body: $preview");
  }

  String _formatError(_Attempt attempt, http.Response res) {
    final body = _truncate(res.body, 2000);
    return "[${res.statusCode}] ${attempt.method.name.toUpperCase()} ${baseUrl}${attempt.path}\n$body";
  }

  String _pretty(Map map) {
    try {
      return const JsonEncoder.withIndent('  ').convert(map);
    } catch (_) {
      return map.toString();
    }
  }

  String _truncate(String s, int max) {
    if (s.length <= max) return s;
    return s.substring(0, max) + "...(truncated)";
  }

  String _curl(_HttpMethod method, Uri uri, Map<String, String> headers, String? body) {
    final h = headers.entries.map((e) => "-H '${e.key}: ${e.value}'").join(' ');
    final m = method.name.toUpperCase();
    final d = (body != null && body.isNotEmpty) ? "--data '${body.replaceAll("'", r"'\''")}'" : "";
    return "curl -X $m $h $d '${uri.toString()}'";
  }

  String _curlMultipart(_HttpMethod method, Uri uri, Map<String, String> headers, Map<String, String> fields, String filePath) {
    final h = headers.entries.map((e) => "-H '${e.key}: ${e.value}'").join(' ');
    final f = fields.entries.map((e) => "-F '${e.key}=${e.value}'").join(' ');
    return "curl -X ${method.name.toUpperCase()} $h $f -F 'photo=@$filePath' '${uri.toString()}'";
  }
}

enum _HttpMethod { patch, put, post }

class _Attempt {
  final String path;
  final _HttpMethod method;
  const _Attempt({required this.path, required this.method});
}
