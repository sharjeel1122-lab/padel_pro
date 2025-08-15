import 'dart:convert';
import 'package:http/http.dart' as http;

/// Simple response model
class ApiResponse {
  final bool isOk;
  final int? statusCode;
  final String? message;
  final dynamic data;

  ApiResponse({required this.isOk, this.statusCode, this.message, this.data});
}

class RecommendedStatusService {
  // TODO: Set your real base URL
  static const String baseUrl = 'https://padel-backend-git-main-invosegs-projects.vercel.app';

  // If your backend route is different, adjust the path below accordingly.
  // Backend given:
  // exports.updateRecommendedStatus = async (req, res) => {
  //   const playground = await Playground.findByIdAndUpdate(req.params.id, { recommended }, { new: true, runValidators: true });
  // }
  //
  // Common REST shape:
  // PUT or PATCH /playgrounds/:id/recommended
  // Body: { "recommended": true/false }
  Future<ApiResponse> updateRecommendedStatus({
    required String id,
    required bool recommended,
  }) async {
    final uri = Uri.parse('$baseUrl/playgrounds/$id/recommended');

    try {
      final res = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          // 'Authorization': 'Bearer <token>', // if needed
        },
        body: jsonEncode({'recommended': recommended}),
      );

      final body = res.body.isNotEmpty ? jsonDecode(res.body) : null;

      if (res.statusCode >= 200 && res.statusCode < 300) {
        return ApiResponse(
          isOk: true,
          statusCode: res.statusCode,
          message: (body is Map && body['message'] is String) ? body['message'] : 'OK',
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
