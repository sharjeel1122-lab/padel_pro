import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthResetService {
  // Dev LAN ya Prod — jo use karna ho
  // static const String baseUrl = "http://192.168.1.2:3000";
  static const String baseUrl = "https://padel-backend-git-main-invosegs-projects.vercel.app";

  static const String forgetPath = "/api/forget-password";

  Future<void> requestReset({required String email}) async {
    final res = await http.post(
      Uri.parse("$baseUrl$forgetPath"),
      headers: {'Accept': 'application/json', 'Content-Type': 'application/json'},
      body: jsonEncode({"email": email}),
    );

    if (res.statusCode != 200) {
      try {
        final m = jsonDecode(res.body) as Map<String, dynamic>;
        throw Exception(m['message'] ?? 'Password reset request failed (${res.statusCode})');
      } catch (_) {
        throw Exception('Password reset request failed (${res.statusCode})');
      }
    }
  }
}
