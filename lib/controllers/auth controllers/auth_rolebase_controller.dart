import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:padel_pro/services/user_login_api.dart';

class AuthController extends GetxController {
  final saveVendorId = GetStorage();

  final storage = const FlutterSecureStorage();
  final obscureText = true.obs; // Observable for password visibility
  final rememberMe = false.obs; // Observable for remember me
  final isLoading = false.obs;  // Observable for loading state

  void toggleVisibility() {
    obscureText.toggle();
    update();
  }

  void toggleRememberMe() {
    rememberMe.toggle();
    update();
  }

  Future<void> login(String email, String password) async {
    try {
      isLoading(true);
      Get.closeAllSnackbars();

      final response = await UserLoginApi.login(email, password);
      final token = response['token'];
      final user = response['user'];
      final role = user['role'];
      final id = user['_id']; // Unique vendor ID from backend

      await storage.write(key: 'token', value: token);
      await storage.write(key: 'role', value: role);
      await storage.write(key: 'email', value: email);
      final savedToken = await storage.read(key: 'token');
      print('📦 Token stored in secure storage: $savedToken');
      if (role.toLowerCase() == 'vendor') {
        saveVendorId.write('vendorId', id); // ✅ Save vendor ID
      }

      Get.snackbar(
        'Login Successful',
        'Welcome ${role.toUpperCase()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      await Future.delayed(const Duration(seconds: 1));

      switch (role.toLowerCase()) {
        case 'admin':
          Get.offAllNamed('/admin-dashboard');
          break;
        case 'vendor':
          Get.offAllNamed('/vendor-dashboard');
          break;
        default:
          Get.offAllNamed('/userHome');
      }
    } catch (e) {
      Get.snackbar(
        'Login Failed',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading(false);
    }
  }

  Future<void> logout() async {
    try {
      await storage.delete(key: 'token');
      await storage.delete(key: 'role');
      saveVendorId.remove('vendorId'); // ✅ Clear vendorId on logout

      Get.snackbar(
        'Logged Out',
        'You have been successfully logged out',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue,
        colorText: Colors.white,
      );
      Get.offAllNamed('/login');
    } catch (e) {
      Get.snackbar(
        'Logout Error',
        'Failed to clear session data',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
      );
    }
  }
}
