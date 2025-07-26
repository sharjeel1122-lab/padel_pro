import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:padel_pro/services/verify_otp_api.dart';
import 'auth_base_controller.dart';

class OtpController extends BaseController {
  final AuthOtpService authOtpService = Get.find<AuthOtpService>();
  final countdown = 60.obs;
  final email = ''.obs;
  final otpControllers = List.generate(6, (index) => TextEditingController());
  final focusNodes = List.generate(6, (index) => FocusNode());
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();

    final dynamic arguments = Get.arguments;
    if (arguments is String) {
      email.value = arguments;
    } else if (arguments is Map && arguments['email'] != null) {
      email.value = arguments['email'];
    } else {
      Get.back();
      showSnackbar('Error', 'Email address is required', isError: true);
      return;
    }

    startCountdown();
  }

  @override
  void onClose() {
    _timer?.cancel();
    for (var controller in otpControllers) {
      controller.dispose();
    }
    for (var node in focusNodes) {
      node.dispose();
    }
    super.onClose();
  }

  void startCountdown() {
    countdown.value = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdown.value > 0) {
        countdown.value--;
      } else {
        timer.cancel();
      }
    });
  }

  String getOtpCode() {
    return otpControllers.map((c) => c.text).join();
  }

  Future<void> verifyOtp() async {
    if (getOtpCode().length != 6) {
      showSnackbar('Invalid OTP', 'Please enter 6-digit code', isError: true);
      return;
    }

    if (email.value.isEmpty) {
      showSnackbar('Error', 'Email address is missing', isError: true);
      return;
    }

    try {
      isLoading(true);
      final result = await authOtpService.verifyOtp(
        email: email.value,
        otp: getOtpCode(),
      );

      if (result['success'] == true) {
        showSnackbar('Verified', 'Email verified successfully. Please login.');
        await Future.delayed(const Duration(seconds: 1));
        Get.offAllNamed('/login');
      } else {
        showSnackbar(
          'OTP Verification Failed',
          result['message'] ?? 'Verification failed',
          isError: true,
        );
      }
    } catch (e) {
      showSnackbar('Error', 'Verification failed: $e', isError: true);
    } finally {
      isLoading(false);
    }
  }

  Future<void> resendCode() async {
    if (email.value.isEmpty) {
      showSnackbar('Error', 'Email address is missing', isError: true);
      return;
    }

    try {
      isLoading(true);
      final result = await authOtpService.resendOtp(email: email.value);

      if (result['success'] == true) {
        showSnackbar('OTP Sent', result['message'] ?? 'New OTP sent');
        startCountdown();
      } else {
        showSnackbar('Resend Failed', result['message'] ?? 'Try again', isError: true);
      }
    } catch (e) {
      showSnackbar('Error', 'Failed to resend OTP: $e', isError: true);
    } finally {
      isLoading(false);
    }
  }
}
