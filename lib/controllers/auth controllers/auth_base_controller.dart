import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

class BaseController extends GetxController {
  final isLoading = false.obs;
  final storage = const FlutterSecureStorage();

  void showSnackbar(String title, String message, {bool isError = false}) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: isError ? Colors.red : Colors.green,
      colorText: Colors.white,
    );
  }

  @override
  void onClose() {
    Get.closeAllSnackbars();
    super.onClose();
  }
}