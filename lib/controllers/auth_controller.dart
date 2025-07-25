import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../services/auth_api.dart';

class AuthController extends GetxController {
  final storage = FlutterSecureStorage();
  bool obscureText = true;
  bool rememberMe = false;
  bool isLoading = false;
  var isLoad = false.obs;

  void toggleVisibility() {
    obscureText = !obscureText;
    update();
  }

  void toggleRememberMe() {
    rememberMe = !rememberMe;
    update();
  }
  void togglePasswordVisibility() {
    obscureText = !obscureText;
    update();
  }

  Future<void> login(String email, String password) async {
    try {
      isLoading = true;
      update();
      Get.closeAllSnackbars();

      final response = await AuthApi.login(email, password);

      // Validate response structure
      if (response['token'] == null || response['user']?['role'] == null) {
        throw Exception('Invalid response structure from server');
      }

      final token = response['token'];
      final role = response['user']['role'];

      await storage.write(key: 'token', value: token);
      await storage.write(key: 'role', value: role);

      Get.snackbar(
        'Login Successful',
        'Welcome ${role.toUpperCase()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Role-based navigation with delay
      await Future.delayed(Duration(seconds: 1));
      switch (role.toLowerCase()) {
        case 'admin':
          Get.offAllNamed('/admin-dashboard');
          break;
        case 'vendor':
          Get.offAllNamed('/vendor-dashboard');
          break;
        default:
          Get.offAllNamed('/user-home');
      }

    } on http.ClientException {
      Get.snackbar(
        'Network Error',
        'Please check your internet connection',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
      );
    } catch (e) {
      Get.snackbar(
        'Login Failed',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
      );
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> logout() async {
    try {
      await storage.delete(key: 'token');
      await storage.delete(key: 'role');

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

  Future<void> signupVendor({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String mpin,
    required String city,
    required String phone,
    required String cnic,
    required String ntn,
    String? photo,
  }) async {
    try {
      isLoading = true;
      update();
      Get.closeAllSnackbars();

      await AuthApi.signupVendor(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        mpin: mpin,
        city: city,
        phone: phone,
        cnic: cnic,
        ntn: ntn,
        photo: photo,
      );

      Get.snackbar(
        'Success',
        'Vendor registration submitted for approval',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      Get.offAllNamed('/login');
    } on http.ClientException {
      Get.snackbar(
        'Network Error',
        'Failed to connect to server',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
      );
    } catch (e) {
      Get.snackbar(
        'Registration Failed',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
      );
    } finally {
      isLoading = false;
      update();
    }
  }



//Sign up

  Future<void> signupUser({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String mpin,
    required String city,
    required String phone,
    String? photoPath,
  }) async {
    try {
      isLoading = true;
      update();

      final response = await AuthApi.signupUser(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        mpin: mpin,
        city: city,
        phone: phone,

      );

      Get.snackbar(
        'Signup Successful',
        response['message'] ?? 'Account created. Check your email for OTP.',
        backgroundColor: Colors.green,
        snackPosition: SnackPosition.BOTTOM,
        colorText: Colors.white,
      );

      Get.offAllNamed('/verify-otp');

    } catch (e) {
      Get.snackbar(
        'Signup Failed',
        e.toString().replaceAll('Exception: ', ''),
        backgroundColor: Colors.red,
        snackPosition: SnackPosition.BOTTOM,
        colorText: Colors.white,
      );
    } finally {
      isLoading = false;
      update();
    }
  }




}