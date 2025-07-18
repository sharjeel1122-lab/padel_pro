import 'dart:convert';
import 'package:get/get.dart';
import '../services/auth_api.dart';

class AuthController extends GetxController {
  bool obscureText = true;
  bool rememberMe = false;

  void toggleVisibility() {
    obscureText = !obscureText;
    update();
  }

  void toggleRememberMe() {
    rememberMe = !rememberMe;
    update();
  }

  Future<void> signup({
    required String fullName,
    required String email,
    required String password,
    required String phone,
    required String city,
  }) async {
    final res = await AuthApi.signup(
      fullName: fullName,
      email: email,
      password: password,
      phone: phone,
      city: city,
    );

    if (res.statusCode == 201) {
      Get.snackbar("Success", "User created successfully");
      Get.offAllNamed('/login');
    } else {
      final msg = jsonDecode(res.body)['message'] ?? "Signup failed";
      Get.snackbar("Error", msg);
    }
  }

  Future<void> login(String email, String password) async {
    // 🔐 Hardcoded static credentials
    final users = {
      'admin@test.com': {'password': 'admin123', 'role': 'admin'},
      'vendor@test.com': {'password': 'vendor123', 'role': 'vendor'},
      'user@test.com': {'password': 'user123', 'role': 'user'},
    };

    // Trim inputs
    final trimmedEmail = email.trim();
    final trimmedPassword = password.trim();

    if (!users.containsKey(trimmedEmail)) {
      Get.snackbar("Login Failed", "Email not found", snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final user = users[trimmedEmail]!;

    if (user['password'] != trimmedPassword) {
      Get.snackbar("Login Failed", "Incorrect password", snackPosition: SnackPosition.BOTTOM);
      return;
    }

    // ✅ Navigate based on role
    switch (user['role']) {
      case 'admin':
        Get.toNamed('/admin');
        break;
      case 'vendor':
        Get.toNamed('/vendorLogin');
        break;
      default:
        Get.toNamed('/userHome');
    }
  }


// Future<void> login(String email, String password) async {
  //   final res = await AuthApi.login(email, password);
  //
  //   if (res.statusCode == 200) {
  //     final user = jsonDecode(res.body)['user'];
  //     final role = user['role'];
  //
  //     if (role == 'admin') {
  //       Get.offAllNamed('/adminHome');
  //     } else {
  //       Get.offAllNamed('/home');
  //     }
  //   } else {
  //     final msg = jsonDecode(res.body)['message'] ?? "Login failed";
  //     Get.snackbar("Login Error", msg);
  //   }
  // }
}
