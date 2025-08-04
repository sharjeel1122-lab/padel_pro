import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthOtpService {
  static const String _baseUrl = 'http://192.168.1.6:3000';

  Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String otp,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/verify-otp'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'email': email, 'otp': otp}),
    );

    final responseData = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return {
        'success': true,
        'token': responseData['token'],
        'user': responseData['user'],
        'message': responseData['message'] ?? 'Email verified successfully',
      };
    } else {
      // Handle specific error cases from your backend
      if (response.statusCode == 403) {
        final lockUntil = responseData['otpLockUntil'] != null
            ? DateTime.parse(responseData['otpLockUntil'])
            : null;

        return {
          'success': false,
          'error': responseData['message'] ?? 'Too many wrong attempts',
          'lockUntil': lockUntil,
          'remainingAttempts': 3 - (responseData['wrongOtpCount'] ?? 0),
          'statusCode': response.statusCode,
        };
      }

      return {
        'success': false,
        'error':
            responseData['message'] ??
            (response.statusCode == 400
                ? 'Invalid or expired OTP'
                : 'Verification failed'),
        'remainingAttempts': 3 - (responseData['wrongOtpCount'] ?? 0),
        'statusCode': response.statusCode,
      };
    }
  }

  // Add OTP resend functionality

  Future<Map<String, dynamic>> resendOtp({required String email}) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/resend-otp'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'email': email}),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'email': responseData['email'],
          'message':
              responseData['message'] ?? 'New OTP sent to your email address',
        };
      } else {
        // Handle specific error cases from your backend
        if (response.statusCode == 403) {
          final remainingTime = responseData['countExpires'] != null
              ? DateTime.now()
                    .difference(DateTime.parse(responseData['countExpires']))
                    .abs()
              : const Duration(minutes: 10);

          return {
            'success': false,
            'error':
                responseData['message'] ??
                'You have exceeded the maximum number of OTP requests',
            'retryAfter': remainingTime,
            'statusCode': response.statusCode,
          };
        }

        return {
          'success': false,
          'error':
              responseData['message'] ??
              (response.statusCode == 400
                  ? 'Email already verified'
                  : 'Failed to resend OTP'),
          'statusCode': response.statusCode,
        };
      }
    } on FormatException {
      return {'success': false, 'error': 'Invalid server response format'};
    } on http.ClientException catch (e) {
      return {'success': false, 'error': 'Network error: ${e.message}'};
    } catch (e) {
      return {'success': false, 'error': 'Unexpected error: ${e.toString()}'};
    }
  }
}
