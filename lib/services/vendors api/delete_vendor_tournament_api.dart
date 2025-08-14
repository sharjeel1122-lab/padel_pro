// services/vendors api/delete_vendor_tournament_api.dart

import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class DeleteVendorTournamentApi {
  DeleteVendorTournamentApi({
    String? baseUrl,
    FlutterSecureStorage? storage,
  })  : _baseUrl = baseUrl ?? 'http://192.168.1.4:3000',
        _storage = storage ?? const FlutterSecureStorage();

  final String _baseUrl;
  final FlutterSecureStorage _storage;

  Future<String?> _token() => _storage.read(key: 'token');

  /// Returns true if deleted successfully, otherwise throws.
  Future<bool> deleteTournament(String tournamentId) async {
    final token = await _token();
    if (token == null) {
      throw Exception('Token missing. Please log in again.');
    }

    // Based on your backend controller (req.params.id):
    // DELETE /api/v1/tournament/delete/:id
    final uri = Uri.parse('$_baseUrl/api/v1/tournament/$tournamentId');
    print('🗑️ DELETE: $uri');

    http.Response res;
    try {
      res = await http
          .delete(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      )
          .timeout(const Duration(seconds: 20));
    } catch (e) {
      print('🚨 Network error while deleting tournament: $e');
      rethrow;
    }

    print('↩️ ${res.statusCode} ${res.reasonPhrase}');
    print(res.body);

    Map<String, dynamic>? body;
    try {
      body = res.body.isNotEmpty ? jsonDecode(res.body) as Map<String, dynamic> : null;
    } catch (_) {
      // Non-JSON response
    }

    if (res.statusCode >= 200 && res.statusCode < 300) {
      // Expecting successResponse with message: "Tournament deleted successfully"
      return true;
    }

    final msg = body?['message']?.toString() ??
        (res.statusCode == 403
            ? 'You are not authorized to delete this tournament'
            : res.statusCode == 404
            ? 'Tournament not found'
            : 'Delete tournament failed (${res.statusCode})');
    throw Exception(msg);
  }
}
