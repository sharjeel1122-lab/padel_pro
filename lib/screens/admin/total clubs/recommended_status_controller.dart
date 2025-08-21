import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:padel_pro/services/admin%20api/update_recommended_api.dart';

class RecommendedStatusController extends GetxController {
  final _service = RecommendedStatusService();

  /// Track loading state per playground id
  final Map<String, RxBool> _busy = {};

  RxBool isBusyFor(String id) {
    return _busy.putIfAbsent(id, () => false.obs);
  }

  Future<void> updateRecommended({
    required String id,
    required bool recommended,
    VoidCallback? onLocalSuccess,
  }) async {
    if (id.isEmpty) {
      Get.snackbar('Error', 'Invalid playground id');
      return;
    }

    final busy = isBusyFor(id);
    if (busy.value) return;

    try {
      busy.value = true;
      final result = await _service.updateRecommendedStatus(id: id, recommended: recommended);

      if (result.isOk) {
        onLocalSuccess?.call();
        final msg = recommended ? 'Marked as recommended' : 'Removed from recommended';
        Get.snackbar(
          backgroundColor: Color(0xFF072A40),
            colorText: Colors.white,
            'Success', msg);
      } else {
        Get.snackbar(
            backgroundColor: Colors.red,
            colorText: Colors.white,
            'Error', result.message ?? 'Failed to update status');
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      busy.value = false;
    }
  }
}
