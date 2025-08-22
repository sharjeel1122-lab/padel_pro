// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../controllers/booking controller/booking_controller.dart';
import '../../../controllers/booking controller/booked_slots_controller.dart';

class BookingSheet extends StatelessWidget {
  const BookingSheet({
    super.key,
    required this.playgroundId,
    required this.courts,
    this.openingTime,
    this.closingTime,
  });

  final String playgroundId;
  final List courts;
  final String? openingTime; // Format: "HH:MM"
  final String? closingTime; // Format: "HH:MM"

  // ---- helpers ----

  List<String> _extractCourtNumbers() {
    final set = <String>{};
    for (final c in courts) {
      final raw = (c['courtNumber'] ?? c['courtName'] ?? '').toString().trim();
      if (raw.isNotEmpty) set.add(raw);
    }
    final list = set.toList();
    list.sort((a, b) {
      final ai = int.tryParse(a);
      final bi = int.tryParse(b);
      if (ai != null && bi != null) return ai.compareTo(bi);
      return a.compareTo(b);
    });
    return list;
  }

  List<int> _extractDurationsFor(String? courtNumber) {
    final durations = <int>{};

    Iterable courtList = courts;
    if (courtNumber != null && courtNumber.isNotEmpty) {
      courtList = courts.where((c) =>
      (c['courtNumber']?.toString() ?? c['courtName']?.toString() ?? '') == courtNumber);
    }

    for (final c in courtList) {
      final pricing = (c['pricing'] as List?) ?? [];
      for (final p in pricing) {
        final d = int.tryParse(p['duration']?.toString() ?? '');
        if (d != null) durations.add(d);
      }
    }
    final list = durations.toList()..sort();
    return list.isEmpty ? [60] : list;
  }

  // Check if a time is within the club's operating hours
  bool _isWithinOperatingHours(TimeOfDay time) {
    if (openingTime == null || closingTime == null) return true;

    // Parse opening and closing times
    final openParts = openingTime!.split(':');
    final closeParts = closingTime!.split(':');

    if (openParts.length < 2 || closeParts.length < 2) return true;

    final openHour = int.tryParse(openParts[0]) ?? 0;
    final openMinute = int.tryParse(openParts[1]) ?? 0;
    final closeHour = int.tryParse(closeParts[0]) ?? 23;
    final closeMinute = int.tryParse(closeParts[1]) ?? 59;

    final openTimeOfDay = TimeOfDay(hour: openHour, minute: openMinute);
    final closeTimeOfDay = TimeOfDay(hour: closeHour, minute: closeMinute);

    // Convert to minutes for easier comparison
    final openMinutes = openTimeOfDay.hour * 60 + openTimeOfDay.minute;
    final closeMinutes = closeTimeOfDay.hour * 60 + closeTimeOfDay.minute;
    final selectedMinutes = time.hour * 60 + time.minute;

    // Handle cases where closing time is on the next day
    if (closeMinutes < openMinutes) {
      return selectedMinutes >= openMinutes || selectedMinutes <= closeMinutes;
    }

    return selectedMinutes >= openMinutes && selectedMinutes <= closeMinutes;
  }

  // Check if a time falls within peak hours for a specific court
  bool _isDuringPeakHours(String? courtNumber, TimeOfDay time) {
    if (courtNumber == null || courtNumber.isEmpty) return false;

    final idx = courts.indexWhere((c) =>
    (c['courtNumber']?.toString() ?? c['courtName']?.toString() ?? '') == courtNumber);
    if (idx < 0) return false;

    final court = courts[idx];
    final peakHours = (court['peakHours'] as List?) ?? [];

    if (peakHours.isEmpty) return false;

    // Convert selected time to minutes for easier comparison
    final selectedMinutes = time.hour * 60 + time.minute;

    for (final peak in peakHours) {
      final startTime = peak['startTime']?.toString() ?? '';
      final endTime = peak['endTime']?.toString() ?? '';

      if (startTime.isEmpty || endTime.isEmpty) continue;

      final startParts = startTime.split(':');
      final endParts = endTime.split(':');

      if (startParts.length < 2 || endParts.length < 2) continue;

      final startHour = int.tryParse(startParts[0]) ?? 0;
      final startMinute = int.tryParse(startParts[1]) ?? 0;
      final endHour = int.tryParse(endParts[0]) ?? 0;
      final endMinute = int.tryParse(endParts[1]) ?? 0;

      final startMinutes = startHour * 60 + startMinute;
      final endMinutes = endHour * 60 + endMinute;

      // Handle cases where peak hours cross midnight
      if (endMinutes < startMinutes) {
        if (selectedMinutes >= startMinutes || selectedMinutes < endMinutes) {
          return true;
        }
      } else if (selectedMinutes >= startMinutes && selectedMinutes < endMinutes) {
        return true;
      }
    }

    return false;
  }

  // Get peak hour price adjustment for a specific court and time with duration consideration
  num? _getPeakHourPriceAdjustment(String? courtNumber, TimeOfDay? time, {int? duration}) {
    if (courtNumber == null || courtNumber.isEmpty || time == null) return null;

    final idx = courts.indexWhere((c) =>
    (c['courtNumber']?.toString() ?? c['courtName']?.toString() ?? '') == courtNumber);
    if (idx < 0) return null;

    final court = courts[idx];
    final peakHours = (court['peakHours'] as List?) ?? [];

    if (peakHours.isEmpty) return null;

    // Convert selected time to minutes for easier comparison
    final selectedMinutes = time.hour * 60 + time.minute;

    for (final peak in peakHours) {
      final startTime = peak['startTime']?.toString() ?? '';
      final endTime = peak['endTime']?.toString() ?? '';
      final peakPrice = peak['price'];

      if (startTime.isEmpty || endTime.isEmpty || peakPrice == null) continue;

      final startParts = startTime.split(':');
      final endParts = endTime.split(':');

      if (startParts.length < 2 || endParts.length < 2) continue;

      final startHour = int.tryParse(startParts[0]) ?? 0;
      final startMinute = int.tryParse(startParts[1]) ?? 0;
      final endHour = int.tryParse(endParts[0]) ?? 0;
      final endMinute = int.tryParse(endParts[1]) ?? 0;

      final startMinutes = startHour * 60 + startMinute;
      final endMinutes = endHour * 60 + endMinute;
      
      // Calculate total peak hour duration in minutes
      int totalPeakMinutes = endMinutes - startMinutes;
      if (totalPeakMinutes < 0) { // Handle cases where peak hours cross midnight
        totalPeakMinutes = (24 * 60) - startMinutes + endMinutes;
      }
      
      // Handle cases where peak hours cross midnight
      bool isInPeakHours = false;
      if (endMinutes < startMinutes) {
        isInPeakHours = selectedMinutes >= startMinutes || selectedMinutes < endMinutes;
      } else {
        isInPeakHours = selectedMinutes >= startMinutes && selectedMinutes < endMinutes;
      }
      
      if (isInPeakHours) {
        num? peakPriceValue;
        if (peakPrice is num) {
          peakPriceValue = peakPrice;
        } else {
          peakPriceValue = num.tryParse(peakPrice.toString());
        }
        
        // If duration is provided, calculate proportional price
        if (duration != null && peakPriceValue != null && totalPeakMinutes > 0) {
          // Calculate the proportion of the booking duration to the total peak hours
          final proportion = duration / totalPeakMinutes;
          // If booking is shorter than peak period, adjust price proportionally
          if (proportion < 1.0) {
            return peakPriceValue * proportion;
          }
        }
        
        return peakPriceValue;
      }
    }

    return null;
  }

  num? _priceFor(String? courtNumber, int? duration, {TimeOfDay? selectedTime}) {
    if (courtNumber == null || courtNumber.isEmpty || duration == null) return null;

    final idx = courts.indexWhere((c) =>
    (c['courtNumber']?.toString() ?? c['courtName']?.toString() ?? '') == courtNumber);
    if (idx < 0) return null;
    final court = courts[idx];

    final pricing = (court['pricing'] as List?) ?? [];
    for (final p in pricing) {
      final d = int.tryParse(p['duration']?.toString() ?? '');
      if (d == duration) {
        final val = p['price'];
        num? basePrice;

        if (val is num) {
          basePrice = val;
        } else {
          basePrice = num.tryParse(val?.toString() ?? '');
        }

        // Apply peak hour pricing if applicable
        if (basePrice != null && selectedTime != null) {
          final peakPrice = _getPeakHourPriceAdjustment(courtNumber, selectedTime, duration: duration);
          if (peakPrice != null) {
            return peakPrice;
          }
        }

        return basePrice;
      }
    }
    return null;
  }

  String _fmt2(int v) => v < 10 ? '0$v' : '$v';
  String _formatDate(DateTime d) => '${d.year}-${_fmt2(d.month)}-${_fmt2(d.day)}';
  String _formatTime(TimeOfDay t) => '${_fmt2(t.hour)}:${_fmt2(t.minute)}';

  bool _isPastTodayTime(DateTime date, TimeOfDay t) {
    final now = DateTime.now();
    final selected = DateTime(date.year, date.month, date.day, t.hour, t.minute);
    return selected.isBefore(now);
  }

  Future<TimeOfDay?> _showCustomTimePicker(
      BuildContext context, {
        TimeOfDay? initialTime,
      }) async {
    final List<int> hours = List<int>.generate(24, (i) => i);
    const List<int> quarterMinutes = <int>[0, 15, 30, 45];

    final TimeOfDay base = initialTime ?? const TimeOfDay(hour: 10, minute: 0);
    int selectedHour = base.hour.clamp(0, 23);
    int selectedMinuteIndex = quarterMinutes.indexWhere(
          (m) => m == (base.minute ~/ 15) * 15,
    );
    if (selectedMinuteIndex == -1) selectedMinuteIndex = 0;

    return showDialog<TimeOfDay>(
      context: context,
      useRootNavigator: true,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Container(
            color: Colors.white,
            child: SizedBox(
              height: 220,
              child: Row(
                children: [
                  Expanded(
                    child: CupertinoPicker(
                      scrollController: FixedExtentScrollController(initialItem: selectedHour),
                      itemExtent: 32,
                      onSelectedItemChanged: (i) {
                        selectedHour = hours[i];
                      },
                      children: hours
                          .map((h) => Center(
                        child: Text(
                          h.toString().padLeft(2, '0'),
                          style: TextStyle(
                            fontSize: 18, 
                            color: Colors.black,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ))
                          .toList(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: CupertinoPicker(
                      scrollController: FixedExtentScrollController(initialItem: selectedMinuteIndex),
                      itemExtent: 32,
                      onSelectedItemChanged: (i) {
                        selectedMinuteIndex = i;
                      },
                      children: quarterMinutes
                          .map((m) => Center(
                        child: Text(
                          m.toString().padLeft(2, '0'),
                          style: TextStyle(
                            fontSize: 18, 
                            color: Colors.black,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ))
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel', style: TextStyle(color: Colors.black87)),
            ),
            TextButton(
              onPressed: () {
                final int minute = quarterMinutes[selectedMinuteIndex];
                final selectedTime = TimeOfDay(hour: selectedHour, minute: minute);
                
                // Check if the selected time is in the past
                final now = DateTime.now();
                final today = DateTime(now.year, now.month, now.day);
                final selectedDate = Get.find<BookingController>(tag: 'booking-$playgroundId').selectedDate.value ?? today;
                
                if (selectedDate.year == today.year && 
                    selectedDate.month == today.month && 
                    selectedDate.day == today.day) {
                  // Only check for past time if the selected date is today
                  final currentTime = TimeOfDay.now();
                  final currentMinutes = currentTime.hour * 60 + currentTime.minute;
                  final selectedMinutes = selectedTime.hour * 60 + selectedTime.minute;
                  
                  if (selectedMinutes <= currentMinutes) {
                    // Show a snackbar message but don't close the time picker
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                          'The selected time has already passed. Please select a future time slot.',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        backgroundColor: Colors.orange.shade800,
                        duration: const Duration(seconds: 3),
                        action: SnackBarAction(
                          label: 'OK',
                          textColor: Colors.white,
                          onPressed: () {},
                        ),
                      ),
                    );
                    return;
                  }
                }
                
                Navigator.of(ctx).pop(selectedTime);
              },
              child: const Text('OK', style: TextStyle(color: Color(0xFF0C1E2C), fontWeight: FontWeight.w600)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickDate(
      BuildContext context,
      BookingController ctrl,
      BookedSlotsController bCtrl,
      ) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final initial = ctrl.selectedDate.value ?? today;

    final picked = await showDatePicker(
      context: context,
      firstDate: today,
      lastDate: today.add(const Duration(days: 120)),
      initialDate: initial.isBefore(today) ? today : initial,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF0C1E2C),
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: Colors.black,
          ),
          textTheme: Theme.of(context).textTheme.apply(
            bodyColor: Colors.black,
            displayColor: Colors.black,
          ),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      final t = ctrl.selectedTime.value;
      if (t != null && _isPastTodayTime(picked, t)) {
        ctrl.selectedTime.value = null;
        ctrl.selectedTime.refresh();
      }
      ctrl.selectedDate.value = picked;

      final courtStr = ctrl.selectedCourtNumber.value;
      if (courtStr != null && courtStr.isNotEmpty) {
        final cnum = int.tryParse(courtStr);
        if (cnum != null) {
          await bCtrl.load(
            playgroundId: ctrl.playgroundId,
            courtNumber: cnum,
            dateIso: _formatDate(picked),
          );
          final st = ctrl.selectedTime.value;
          final dur = ctrl.selectedDuration.value ?? 0;
          if (st != null &&
              (dur > 0 ? bCtrl.wouldConflict(st, dur) : bCtrl.isBookedStart(st))) {
            ctrl.selectedTime.value = null;
            ctrl.selectedTime.refresh();
          }
        }
      }
    }
  }

  Future<void> _pickTime(
      BuildContext context,
      BookingController ctrl,
      BookedSlotsController bCtrl,
      ) async {
    final init = ctrl.selectedTime.value ?? const TimeOfDay(hour: 10, minute: 0);
    final picked = await _showCustomTimePicker(context, initialTime: init);

    if (picked != null) {
      final date = ctrl.selectedDate.value ?? DateTime.now();
      final today = DateTime.now();
      final dateOnly = DateTime(date.year, date.month, date.day);
      final todayOnly = DateTime(today.year, today.month, today.day);

      // Check if the selected time is in the past
      if (dateOnly == todayOnly && _isPastTodayTime(date, picked)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'The selected time has already passed. Please select a future time slot.',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            backgroundColor: Colors.orange.shade800,
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
        return;
      }

      // Check if the selected time is within club operating hours
      if (!_isWithinOperatingHours(picked)) {
        final openStr = openingTime ?? "00:00";
        final closeStr = closingTime ?? "23:59";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'This time is outside club operating hours. Please select a time between $openStr and $closeStr.',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            backgroundColor: Colors.blue.shade700,
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
        return;
      }

      // Check if the selected time conflicts with already booked slots
      final dur = ctrl.selectedDuration.value ?? 0;
      final conflicts = dur > 0 ? bCtrl.wouldConflict(picked, dur) : bCtrl.isBookedStart(picked);
      if (conflicts) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'This time slot is unavailable because it has already been booked by another user. Please select a different time.',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            backgroundColor: Colors.red.shade700,
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
        return;
      }

      // ✅ instant UI update
      ctrl.selectedTime.value = picked;
      ctrl.selectedTime.refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final courtNumbers = _extractCourtNumbers();

    // stable tag so controllers aren't recreated
    final tag = 'booking-$playgroundId';

    final ctrl = Get.isRegistered<BookingController>(tag: tag)
        ? Get.find<BookingController>(tag: tag)
        : Get.put(
      BookingController(
        playgroundId: playgroundId,
        availableCourts: courtNumbers,
        durationOptions: const [],
      ),
      tag: tag,
    );

    final bCtrl = Get.isRegistered<BookedSlotsController>(tag: 'booked-$tag')
        ? Get.find<BookedSlotsController>(tag: 'booked-$tag')
        : Get.put(BookedSlotsController(), tag: 'booked-$tag');

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    ctrl.selectedCourtNumber.value ??= courtNumbers.isNotEmpty ? courtNumbers.first : null;
    ctrl.selectedDate.value ??= today;

    return Obx(() {
      final selectedCourt = ctrl.selectedCourtNumber.value;
      final selectedTime = ctrl.selectedTime.value;
      final selectedDuration = ctrl.selectedDuration.value;

      final dateVal = ctrl.selectedDate.value;
      final dateString = dateVal == null ? '' : _formatDate(dateVal);
      final timeString = selectedTime == null ? '' : _formatTime(selectedTime);

      if (bCtrl.booked.value == null &&
          selectedCourt != null &&
          selectedCourt.isNotEmpty &&
          dateVal != null) {
        final cnum = int.tryParse(selectedCourt);
        if (cnum != null) {
          bCtrl.load(
            playgroundId: ctrl.playgroundId,
            courtNumber: cnum,
            dateIso: _formatDate(dateVal),
          );
        }
      }

      final durations = _extractDurationsFor(selectedCourt);

      if (durations.isNotEmpty &&
          (selectedDuration == null || !durations.contains(selectedDuration))) {
        ctrl.selectedDuration.value = durations.first;
      }
      if (durations.isEmpty && selectedDuration != null) {
        ctrl.selectedDuration.value = null;
      }

      // Check if the selected time is during peak hours
      final isPeakHour = selectedTime != null && _isDuringPeakHours(selectedCourt, selectedTime);

      // Get price considering peak hours
      final currentPrice = _priceFor(selectedCourt, ctrl.selectedDuration.value, selectedTime: selectedTime);
      final priceString = currentPrice == null ? '—' : 'Rs. $currentPrice';

      final bool pickedConflicts = (selectedTime != null)
          ? (ctrl.selectedDuration.value ?? 0) > 0
          ? bCtrl.wouldConflict(selectedTime, ctrl.selectedDuration.value!)
          : bCtrl.isBookedStart(selectedTime)
          : false;

      final canSubmit = !ctrl.isLoading.value &&
          !pickedConflicts &&
          selectedTime != null &&
          (ctrl.selectedDuration.value ?? 0) > 0 &&
          (selectedCourt != null && selectedCourt.isNotEmpty);

      return DraggableScrollableSheet(
        expand: false,
        minChildSize: 0.42,
        initialChildSize: 0.72,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Stack(
            children: [
              ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 130),
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(LucideIcons.calendarClock, color: Color(0xFF0C1E2C)),
                          SizedBox(width: 8),
                          Text(
                            'Book a Court',
                            style: TextStyle(
                              color: Color(0xFF0C1E2C),
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      if (openingTime != null && closingTime != null)
                        Text(
                          'Hours: $openingTime - $closingTime',
                          style: const TextStyle(
                            color: Color(0xFF0C1E2C),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Court selector
                  const Text('Court', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  if (courtNumbers.isEmpty)
                    const Text('No courts available', style: TextStyle(color: Colors.grey))
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: courtNumbers.map((numStr) {
                        final isSelected = selectedCourt == numStr;
                        return ChoiceChip(
                          label: Text(numStr),
                          selected: isSelected,
                          onSelected: (_) async {
                            ctrl.selectedCourtNumber.value = numStr;

                            final cnum = int.tryParse(numStr);
                            final d = ctrl.selectedDate.value;
                            if (cnum != null && d != null) {
                              await bCtrl.load(
                                playgroundId: ctrl.playgroundId,
                                courtNumber: cnum,
                                dateIso: _formatDate(d),
                              );
                            }

                            final t = ctrl.selectedTime.value;
                            final dur = ctrl.selectedDuration.value ?? 0;
                            if (t != null &&
                                (dur > 0 ? bCtrl.wouldConflict(t, dur) : bCtrl.isBookedStart(t))) {
                              ctrl.selectedTime.value = null;
                              ctrl.selectedTime.refresh();
                            }
                          },
                          selectedColor: const Color(0xFF0C1E2C),
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : const Color(0xFF0C1E2C),
                            fontWeight: FontWeight.w600,
                          ),
                          backgroundColor: const Color(0xFF0C1E2C).withOpacity(0.08),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        );
                      }).toList(),
                    ),

                  const SizedBox(height: 16),

                  // Date & Time
                  Row(
                    children: [
                      Expanded(
                        child: _FieldCard(
                          icon: LucideIcons.calendar,
                          label: 'Date',
                          value: dateString.isEmpty ? 'Select date' : dateString,
                          onTap: () => _pickDate(context, ctrl, bCtrl),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _FieldCard(
                          icon: LucideIcons.clock,
                          label: 'Start Time',
                          value: timeString.isEmpty ? 'Select time' : timeString,
                          onTap: () {
                            if (ctrl.selectedDate.value == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Please select a date first.')),
                              );
                              return;
                            }
                            _pickTime(context, ctrl, bCtrl);
                          },
                        ),
                      ),
                    ],
                  ),

                  if (pickedConflicts)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        children: const [
                          Icon(Icons.error_outline, color: Colors.red, size: 18),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'This slot is already booked. Please select another.',
                              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Display operating hours information
                  if (openingTime != null && closingTime != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        children: [
                          const Icon(LucideIcons.info, color: Colors.blue, size: 18),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Club operating hours: $openingTime - $closingTime',
                              style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Display peak hour information if applicable
                  if (isPeakHour)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        children: [
                          const Icon(LucideIcons.trendingUp, color: Colors.red, size: 18),
                          const SizedBox(width: 6),
                          const Expanded(
                            child: Text(
                              'Peak hour pricing applies',
                              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Duration + Price
                  const Text('Duration', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  if (durations.isEmpty)
                    const Text('No duration options found', style: TextStyle(color: Colors.grey))
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: durations.map((d) {
                        final isSelected = ctrl.selectedDuration.value == d;
                        final p = _priceFor(selectedCourt, d, selectedTime: selectedTime);
                        final label = p == null ? '$d min' : '$d min — Rs. $p';
                        return ChoiceChip(
                          label: Text(label),
                          selected: isSelected,
                          onSelected: (_) => ctrl.selectedDuration.value = d,
                          selectedColor: const Color(0xFF0C1E2C),
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : const Color(0xFF0C1E2C),
                            fontWeight: FontWeight.w600,
                          ),
                          backgroundColor: const Color(0xFF0C1E2C).withOpacity(0.08),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        );
                      }).toList(),
                    ),

                  const SizedBox(height: 14),

                  // Booked slots list (chips)
                  Obx(() {
                    final loading = bCtrl.isLoading.value;
                    final data = bCtrl.booked.value;
                    if (loading) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 6),
                        child: LinearProgressIndicator(minHeight: 3),
                      );
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(LucideIcons.info, size: 18, color: Colors.black54),
                            const SizedBox(width: 6),
                            Text(
                              'Booked on ${dateString.isEmpty ? 'selected date' : dateString}',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (data == null || data.bookedSlots.isEmpty)
                          const Text(
                            'No bookings — all slots open so far.',
                            style: TextStyle(color: Colors.black54),
                          )
                        else
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: data.bookedSlots
                                .map((s) => Chip(
                              label: Text(s.timeSlot),
                              backgroundColor: Colors.red.withOpacity(0.08),
                              side: BorderSide(color: Colors.red.withOpacity(0.3)),
                              labelStyle: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.w600,
                              ),
                            ))
                                .toList(),
                          ),
                      ],
                    );
                  }),

                  const SizedBox(height: 20),

                  // Summary
                  _ResponsiveSummary(
                    court: selectedCourt ?? '—',
                    date: dateString.isEmpty ? '—' : dateString,
                    time: timeString.isEmpty ? '—' : timeString,
                    duration: (ctrl.selectedDuration.value ?? 0) > 0
                        ? '${ctrl.selectedDuration.value} min'
                        : '—',
                    price: priceString,
                    isPeakHour: isPeakHour,
                  ),
                ],
              ),

              // Bottom CTA
              Positioned(
                left: 16,
                right: 16,
                bottom: 20,
                child: ElevatedButton.icon(
                  onPressed: canSubmit ? ctrl.submit : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0C1E2C),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 54),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 6,
                    shadowColor: const Color(0xFF0C1E2C).withOpacity(0.3),
                  ),
                  icon: ctrl.isLoading.value
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                      : const Icon(LucideIcons.checkCircle2),
                  label: Text(
                    ctrl.isLoading.value
                        ? 'Booking...'
                        : (!canSubmit
                        ? (pickedConflicts
                        ? 'Slot booked — pick another'
                        : 'Select court, date, time & duration')
                        : (currentPrice == null
                        ? 'Confirm Booking'
                        : 'Confirm Booking • Rs. $currentPrice')),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

/// ---------------- UI bits ----------------

class _FieldCard extends StatelessWidget {
  const _FieldCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isHint = value.trim().toLowerCase().startsWith('select');
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF0C1E2C).withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black12),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF0C1E2C)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: isHint ? Colors.black45 : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.black45),
          ],
        ),
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.title,
    required this.value,
    required this.icon,
    this.isPeakHour = false,
  });

  final String title;
  final String value;
  final IconData icon;
  final bool isPeakHour;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 60),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF0C1E2C), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                          value,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w700)
                      ),
                    ),
                    if (isPeakHour && title == 'Price')
                      const Icon(LucideIcons.trendingUp, size: 16, color: Colors.red),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ResponsiveSummary extends StatelessWidget {
  const _ResponsiveSummary({
    required this.court,
    required this.date,
    required this.time,
    required this.duration,
    required this.price,
    this.isPeakHour = false,
  });

  final String court;
  final String date;
  final String time;
  final String duration;
  final String price;
  final bool isPeakHour;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final w = c.maxWidth;

      if (w >= 860) {
        return Row(
          children: [
            Expanded(child: _SummaryTile(title: 'Court', value: court, icon: LucideIcons.doorOpen)),
            const SizedBox(width: 10),
            Expanded(child: _SummaryTile(title: 'Date', value: date, icon: LucideIcons.calendarDays)),
            const SizedBox(width: 10),
            Expanded(child: _SummaryTile(title: 'Time', value: time, icon: LucideIcons.clock4)),
            const SizedBox(width: 10),
            Expanded(child: _SummaryTile(title: 'Duration', value: duration, icon: LucideIcons.timer)),
            const SizedBox(width: 10),
            Expanded(child: _SummaryTile(title: 'Price', value: price, icon: LucideIcons.badgeDollarSign, isPeakHour: isPeakHour)),
          ],
        );
      } else if (w >= 560) {
        return Column(
          children: [
            Row(
              children: [
                Expanded(child: _SummaryTile(title: 'Court', value: court, icon: LucideIcons.doorOpen)),
                const SizedBox(width: 10),
                Expanded(child: _SummaryTile(title: 'Date', value: date, icon: LucideIcons.calendarDays)),
                const SizedBox(width: 10),
                Expanded(child: _SummaryTile(title: 'Time', value: time, icon: LucideIcons.clock4)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _SummaryTile(title: 'Duration', value: duration, icon: LucideIcons.timer)),
                const SizedBox(width: 10),
                Expanded(child: _SummaryTile(title: 'Price', value: price, icon: LucideIcons.badgeDollarSign, isPeakHour: isPeakHour)),
              ],
            ),
          ],
        );
      } else {
        return Column(
          children: [
            _SummaryTile(title: 'Court', value: court, icon: LucideIcons.doorOpen),
            const SizedBox(height: 10),
            _SummaryTile(title: 'Date', value: date, icon: LucideIcons.calendarDays),
            const SizedBox(height: 10),
            _SummaryTile(title: 'Time', value: time, icon: LucideIcons.clock4),
            const SizedBox(height: 10),
            _SummaryTile(title: 'Duration', value: duration, icon: LucideIcons.timer),
            const SizedBox(height: 10),
            _SummaryTile(title: 'Price', value: price, icon: LucideIcons.badgeDollarSign, isPeakHour: isPeakHour),
          ],
        );
      }
    });
  }
}