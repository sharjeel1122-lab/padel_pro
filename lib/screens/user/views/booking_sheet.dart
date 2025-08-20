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
  });

  final String playgroundId;
  final List courts;

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

  num? _priceFor(String? courtNumber, int? duration) {
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
        if (val is num) return val;
        final parsed = num.tryParse(val?.toString() ?? '');
        if (parsed != null) return parsed;
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
                          style: const TextStyle(fontSize: 18, color: Colors.black),
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
                          style: const TextStyle(fontSize: 18, color: Colors.black),
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
                Navigator.of(ctx).pop(TimeOfDay(hour: selectedHour, minute: minute));
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

      if (dateOnly == todayOnly && _isPastTodayTime(date, picked)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a future time.')),
        );
        return;
      }

      final dur = ctrl.selectedDuration.value ?? 0;
      final conflicts = dur > 0 ? bCtrl.wouldConflict(picked, dur) : bCtrl.isBookedStart(picked);
      if (conflicts) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('This slot is already booked. Please select another.')),
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

      final currentPrice = _priceFor(selectedCourt, ctrl.selectedDuration.value);
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
                    children: const [
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
                        final p = _priceFor(selectedCourt, d);
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
  const _SummaryTile({required this.title, required this.value, required this.icon});

  final String title;
  final String value;
  final IconData icon;

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
                Text(value, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700)),
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
  });

  final String court;
  final String date;
  final String time;
  final String duration;
  final String price;

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
            Expanded(child: _SummaryTile(title: 'Price', value: price, icon: LucideIcons.badgeDollarSign)),
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
                Expanded(child: _SummaryTile(title: 'Price', value: price, icon: LucideIcons.badgeDollarSign)),
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
            _SummaryTile(title: 'Price', value: price, icon: LucideIcons.badgeDollarSign),
          ],
        );
      }
    });
  }
}
