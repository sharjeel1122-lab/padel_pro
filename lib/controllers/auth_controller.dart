// controllers/auth_controller.dart
import 'package:get/get.dart';

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
}
