// ignore_for_file: file_names

import 'dart:async';                       // <-- for Timer
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:padel_pro/services/user%20role%20api%20service/get_booked_time_slots_api.dart';

class TimeRange {
  final int startM; // inclusive minutes
  final int endM;   // exclusive minutes
  TimeRange(this.startM, this.endM);

  bool contains(int m) => m >= startM && m < endM;
  bool overlaps(int aStart, int aEnd) => aStart < endM && aEnd > startM;
}

int _parseMinutes(String hhmm) {
  try {
    final parts = hhmm.split(':');
    final h = int.parse(parts[0]);
    final m = int.parse(parts[1]);
    return h * 60 + m;
  } catch (_) {
    return -1;
  }
}

class BookedSlotsController extends GetxController {
  final _api = GetBookedTimeSlotsApi();

  // UI state
  final isLoading = false.obs;           // only used for explicit/first loads
  final booked = Rxn<BookedTimeSlotsDto>();
  final disabled = <TimeRange>[].obs;

  // --- Auto-refresh state ---
  Timer? _poller;
  final Duration _pollInterval = const Duration(seconds: 3);
  bool _isFetching = false;             // prevent overlap
  String? _lastPlaygroundId;
  int? _lastCourtNumber;
  String? _lastDateIso;

  @override
  void onClose() {
    _poller?.cancel();
    _poller = null;
    super.onClose();
  }

  /// Public: load slots. Use `quiet: true` for silent background refresh (no loader/snackbars).
  Future<void> load({
    required String playgroundId,
    required int courtNumber,
    required String dateIso,
    bool quiet = false,
  }) async {
    // remember latest target for polling
    _lastPlaygroundId = playgroundId;
    _lastCourtNumber = courtNumber;
    _lastDateIso = dateIso;

    if (_isFetching) return;
    _isFetching = true;

    if (!quiet) isLoading.value = true;
    try {
      final res = await _api.fetch(
        playgroundId: playgroundId,
        courtNumber: courtNumber,
        date: dateIso,
      );
      booked.value = res;

      // build disabled ranges
      final ranges = res.bookedSlots
          .map((s) => TimeRange(_parseMinutes(s.startTime), _parseMinutes(s.endTime)))
          .toList();
      disabled
        ..clear()
        ..addAll(ranges);
    } catch (e) {
      if (!quiet) {
        booked.value = null;
        disabled.clear();
        Get.snackbar(
          'Slots',
          e.toString().replaceFirst('Exception: ', ''),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
      // in quiet mode, keep previous data & stay silent
    } finally {
      if (!quiet) isLoading.value = false;
      _isFetching = false;
      _ensurePollingStarted(); // start once we have a target
    }
  }

  /// Background refresh using last known target; silent & non-overlapping.
  Future<void> _refreshQuiet() async {
    if (_lastPlaygroundId == null || _lastCourtNumber == null || _lastDateIso == null) return;
    await load(
      playgroundId: _lastPlaygroundId!,
      courtNumber: _lastCourtNumber!,
      dateIso: _lastDateIso!,
      quiet: true,
    );
  }

  void _ensurePollingStarted() {
    if (_poller != null) return;
    _poller = Timer.periodic(_pollInterval, (_) => _refreshQuiet());
  }

  // --- Helpers used by UI ---

  bool isBookedStart(TimeOfDay t) {
    final m = t.hour * 60 + t.minute;
    for (final r in disabled) {
      if (r.contains(m)) return true;
    }
    return false;
  }

  bool wouldConflict(TimeOfDay start, int durationMinutes) {
    final startM = start.hour * 60 + start.minute;
    final endM = startM + durationMinutes;
    for (final r in disabled) {
      if (r.overlaps(startM, endM)) return true;
    }
    return false;
  }
}
