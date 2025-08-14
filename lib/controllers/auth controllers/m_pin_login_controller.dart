import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:padel_pro/services/user_mpin_login_api.dart';

class MPINLoginController extends GetxController {
  final isLoading = false.obs;

  Future<void> loginWithMPIN(String mpin) async {
    if (mpin.length != 4) return;
    if (isLoading.value) return;

    try {
      isLoading.value = true;

      final result = await UserMPINLoginApi.loginWithMPIN(mpin);

      if (result.isEmpty) {
        throw Exception('Empty response from server');
      }

      final token = result['token'];
      final user  = result['user'];

      if (token == null || user == null) {
        throw Exception('Token or user missing in response');
      }

      final role = (user['role'] ?? '').toString().toLowerCase();

      print("Check Role${role}");

      switch (role) {
        case 'vendor':
          Get.offAllNamed('/vendor-dashboard');
          break;
        case 'admin':
          Get.offAllNamed('/admin-dashboard');
          break;
        case 'user':
          Get.offAllNamed('/userHome');
          break;
        default:
          Get.offAllNamed('/userHome');
      }
    } catch (e) {
      Get.snackbar(
        'Login failed',
        e.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF072A40),
        colorText: const Color(0xFFFFFFFF),
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(12),
        borderRadius: 10,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
