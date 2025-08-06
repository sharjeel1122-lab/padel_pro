
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showDeleteConfirmation({
  required BuildContext context,
  required String title,
  required String content,
  required VoidCallback onConfirm,
}) {
  Get.defaultDialog(
    title: title,
    titleStyle: Get.textTheme.titleMedium!,
    middleText: content,
    middleTextStyle: Get.textTheme.bodyMedium!,
    backgroundColor: Get.theme.dialogBackgroundColor,
    radius: 12,
    textCancel: 'Cancel',
    textConfirm: 'Delete',
    cancelTextColor: Colors.white,
    confirmTextColor: Colors.white,
    buttonColor: const Color(0xFFdc2626), // Red
    onConfirm: () {
      onConfirm();
      Get.back(); // Close dialog
    },
  );
}