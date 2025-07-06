import 'package:get/get.dart';
import 'package:flutter/material.dart';

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

  // 🔐 Temporary test login logic
  void login(String email, String password) {
    if (email == 'admin@test.com' && password == 'admin123') {
      Get.snackbar("Success", "Logged in as Admin");
      Get.offAllNamed('/addGround');
    } else if (email == 'user@test.com' && password == 'user123') {
      Get.snackbar("Success", "Logged in as User");
      Get.offAllNamed('/home');
    } else {
      Get.snackbar("Error", "Invalid credentials");
    }
  }
}
