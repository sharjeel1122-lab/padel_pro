// lib/controllers/add_vendor_by_admin_controller.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:padel_pro/services/admin api/add_vendor_by_admin.dart'; // <-- your VendorCreateApi file

class AddVendorByAdminController extends GetxController {
  final VendorCreateApi service;

  final Future<String?> Function()? tokenProvider;

  AddVendorByAdminController({
    required this.service,
    this.tokenProvider,
  });

  final isSubmitting = false.obs;

  Future<bool> submit({
    required Map<String, String> formData,
    required String imagePath,
    bool showToasts = true,
  }) async {
    if (isSubmitting.value) return false;
    isSubmitting.value = true;

    try {
      // turn the selected image path into a File for the service
      final photoFile = File(imagePath);

      // get bearer token if provided
      final token = tokenProvider != null ? await tokenProvider!() : null;

      final resp = await service.createVendorByAdmin(
        formData,                // fields
        photoFile,               // File? photo
        bearerToken: token,      // optional admin JWT
      );

      if (showToasts) {
        final msg = (resp['message'] ?? 'Vendor created successfully.').toString();
        final email = (resp['data']?['email'] ?? '').toString();
        Get.snackbar(
          'Success',
          email.isNotEmpty ? '$msg\n$email' : msg,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
      return true;
    } catch (e) {
      if (showToasts) {
        Get.snackbar(
          'Failed',
          e.toString().replaceFirst('Exception: ', ''),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }
}
