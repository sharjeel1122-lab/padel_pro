import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VerificationController extends GetxController {
  final List<TextEditingController> otpControllers =
  List.generate(6, (index) => TextEditingController());

  final List<FocusNode> focusNodes =
  List.generate(6, (index) => FocusNode());

  var isLoading = false.obs;
  var countdown = 60.obs;
  var email = ''.obs;

  @override
  void onInit() {
    super.onInit();

    // ✅ Safe assignment from route arguments
    final args = Get.arguments;
    if (args != null && args is Map && args.containsKey('email')) {
      email.value = args['email'] ?? '';
    } else {
      email.value = 'No Email Provided';
    }

    startCountdown();
  }

  void startCountdown() {
    Future.delayed(const Duration(seconds: 1), () {
      if (countdown.value > 0) {
        countdown.value--;
        startCountdown();
      }
    });
  }

  void resendCode() {
    countdown.value = 60;
    startCountdown();

    Get.snackbar(
      'Code Sent',
      'A new verification code has been sent to ${email.value}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF072A40),
      colorText: Colors.white,
    );
  }

  void verifyOtp() async {
    isLoading.value = true;

    // ✅ Combine all 6 digits
    final otp = otpControllers.map((c) => c.text).join();

    // TODO: Add actual API call for OTP verification here

    await Future.delayed(const Duration(seconds: 2)); // Simulate network delay

    isLoading.value = false;

    // ✅ Navigate to user home screen after successful verification
    Get.offAllNamed('/userHome');
  }

  @override
  void onClose() {
    for (var controller in otpControllers) {
      controller.dispose();
    }
    for (var node in focusNodes) {
      node.dispose();
    }
    super.onClose();
  }
}
