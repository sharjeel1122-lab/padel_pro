import 'dart:async';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:padel_pro/services/user role api service/fetch_booking_api.dart';

class UserBookingController extends GetxController {
  final api = UserBookingApi();

  final isLoading = false.obs;   // Only for the very first load (spinner)
  final isUpdating = false.obs;  // While submitting an edit
  final bookings = <BookingItem>[].obs;

  // Fields for editing (bottom sheet)
  final editBookingId = RxnString();
  final editDate = Rxn<DateTime>();
  final editTime = Rxn<TimeOfDay>();
  final editDuration = RxnInt();
  final editCourt = RxnString();

  Color get brand => const Color(0xFF0C1E2C);

  // --- polling ---
  Timer? _pollTimer;
  bool _polling = false; // guard to prevent overlapping requests

  @override
  void onInit() {
    super.onInit();
    fetch(initial: true);      // first load shows spinner if needed
    _startPolling();           // then keep it updated silently
  }

  @override
  void onClose() {
    _pollTimer?.cancel();
    super.onClose();
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      refreshSilently();
    });
  }

  /// Initial or manual fetch. If [initial] is true, shows the spinner
  /// when list is empty; otherwise stays silent.
  Future<void> fetch({bool initial = false}) async {
    try {
      if (initial) isLoading.value = true;
      final res = await api.fetchBookings();
      bookings.assignAll(res);
    } catch (e) {
      // Show error on the first load (so user isn't left on empty screen)
      if (initial) {
        Get.snackbar('Failed', e.toString(), snackPosition: SnackPosition.BOTTOM);
      }
    } finally {
      if (initial) isLoading.value = false;
    }
  }

  /// Background refresh that does not show any loaders/snackbars.
  Future<void> refreshSilently() async {
    if (_polling || isUpdating.value) return; // avoid overlap or clash with edits
    _polling = true;
    try {
      final res = await api.fetchBookings();
      bookings.assignAll(res);
    } catch (_) {
      // swallow errors to keep it silent
    } finally {
      _polling = false;
    }
  }

  // Initialize edit fields with current booking
  void startEdit(BookingItem b) {
    editBookingId.value = b.id;
    final parts = b.startTime.split(':');
    final hour = int.tryParse(parts.first) ?? 10;
    final minute = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;

    final dateParts = b.date.split('-');
    final y = int.tryParse(dateParts[0]) ?? DateTime.now().year;
    final m = int.tryParse(dateParts.length > 1 ? dateParts[1] : '1') ?? 1;
    final d = int.tryParse(dateParts.length > 2 ? dateParts[2] : '1') ?? 1;

    editDate.value = DateTime(y, m, d);
    editTime.value = TimeOfDay(hour: hour, minute: minute);
    editDuration.value = b.duration;
    editCourt.value = b.courtNumber;
  }

  String _fmt2(int v) => v < 10 ? '0$v' : '$v';
  String fmtDate(DateTime d) => '${d.year}-${_fmt2(d.month)}-${_fmt2(d.day)}';
  String fmtTime(TimeOfDay t) => '${_fmt2(t.hour)}:${_fmt2(t.minute)}';

  Future<void> submitEdit() async {
    final id = editBookingId.value;
    final d = editDate.value;
    final t = editTime.value;
    final dur = editDuration.value;
    final court = editCourt.value;

    if (id == null || d == null || t == null || dur == null || court == null || court.isEmpty) {
      Get.snackbar('Missing info', 'Please fill all fields',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    // No past time for today
    final now = DateTime.now();
    final selected = DateTime(d.year, d.month, d.day, t.hour, t.minute);
    if (selected.isBefore(now)) {
      Get.snackbar('Invalid time', 'Please select a future time',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    try {
      isUpdating.value = true;
      final updated = await api.updateBooking(
        bookingId: id,
        date: fmtDate(d),
        startTime: fmtTime(t),
        duration: dur,
        courtNumber: court,
      );

      // update in list
      final idx = bookings.indexWhere((e) => e.id == updated.id);
      if (idx != -1) {
        bookings[idx] = updated;
      } else {
        await fetch(); // fallback
      }

      Get.back(); // close sheet
      Get.snackbar('Updated', 'Booking updated successfully',
          backgroundColor: brand, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Update failed', e.toString(),
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isUpdating.value = false;
    }
  }
}
