import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:padel_pro/services/user%20role%20api%20service/create_booking_user.dart';

class BookingController extends GetxController {
  BookingController({
    required this.playgroundId,
    required this.availableCourts,
    required this.durationOptions,
  });

  final String playgroundId;
  final List<String> availableCourts;
  final List<int> durationOptions;

  final isLoading = false.obs;

  // form state
  final selectedCourtNumber = RxnString();
  final selectedDate = Rxn<DateTime>();
  final selectedTime = Rxn<TimeOfDay>();
  final selectedDuration = RxnInt();

  // helpers
  String get dateString {
    final d = selectedDate.value;
    if (d == null) return '';
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }

  String get timeString {
    final t = selectedTime.value;
    if (t == null) return '';
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String? validate() {
    if ((selectedCourtNumber.value ?? '').isEmpty) return 'Please select a court';
    if (selectedDate.value == null) return 'Please choose a date';
    if (selectedTime.value == null) return 'Please choose a start time';
    if (selectedDuration.value == null) return 'Please choose a duration';
    return null;
  }

  Future<void> submit() async {
    final error = validate();
    if (error != null) {
      Get.snackbar('Missing info', error,
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    if (isLoading.value) return;
    isLoading.value = true;

    try {
      final api = BookingApi();
      final result = await api.createBooking(
        playgroundId: playgroundId,
        courtNumber: selectedCourtNumber.value!,
        date: dateString,
        startTime: timeString,
        duration: selectedDuration.value!,
      );

      if (result['success'] == true) {
        Get.back(); // close sheet
        Get.snackbar(
          'Booked!',
          'Your court has been booked successfully.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF0C1E2C),
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Booking failed',
          (result['message'] ?? 'Something went wrong').toString(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
