import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../controllers/booking controller/booking_controller.dart';

class BookingSheet extends StatelessWidget {
  const BookingSheet({
    super.key,
    required this.playgroundId,
    required this.courts,
  });

  final String playgroundId;
  final List courts;

  // ---- Helpers ----

  List<String> _extractCourtNumbers() {
    // Prefer backend "courtNumber", fallback to "courtName"
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
      (c['courtNumber']?.toString() ?? c['courtName']?.toString() ?? '') ==
          courtNumber);
    }

    for (final c in courtList) {
      final pricing = (c['pricing'] as List?) ?? [];
      for (final p in pricing) {
        final d = int.tryParse(p['duration']?.toString() ?? '');
        if (d != null) durations.add(d);
      }
    }
    final list = durations.toList()..sort();
    return list.isEmpty ? [60] : list; // sensible default
  }

  num? _priceFor(String? courtNumber, int? duration) {
    if (courtNumber == null || courtNumber.isEmpty || duration == null) return null;

    final court = courts.firstWhereOrNull((c) =>
    (c['courtNumber']?.toString() ?? c['courtName']?.toString() ?? '') ==
        courtNumber);

    if (court == null) return null;

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

  /// Round `now` up to the next 15-minute mark and return as TimeOfDay.
  TimeOfDay _nextUpcomingSlot15m(DateTime base) {
    final add = (15 - (base.minute % 15)) % 15;
    final rounded = base.add(Duration(minutes: add == 0 ? 15 : add));
    return TimeOfDay(hour: rounded.hour, minute: rounded.minute - (rounded.minute % 15));
  }

  Future<void> _pickDate(BuildContext context, BookingController ctrl) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final initial = ctrl.selectedDate.value ?? today;

    final picked = await showDatePicker(
      context: context,
      firstDate: today, // ⛔️ no past dates
      lastDate: today.add(const Duration(days: 120)),
      initialDate: initial.isBefore(today) ? today : initial,
      useRootNavigator: true, // show above the bottom sheet
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF0C1E2C),
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: Colors.black,
          ),
          textTheme: Theme.of(context)
              .textTheme
              .apply(bodyColor: Colors.black, displayColor: Colors.black),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      // If switching to today and time is in the past, clear time
      final t = ctrl.selectedTime.value;
      if (t != null && _isPastTodayTime(picked, t)) {
        ctrl.selectedTime.value = null;
        ctrl.selectedTime.refresh();
      }
      ctrl.selectedDate.value = picked;
    }
  }

  Future<void> _pickTime(BuildContext context, BookingController ctrl) async {
    final date = ctrl.selectedDate.value ?? DateTime.now();
    final today = DateTime.now();
    final isToday = DateTime(date.year, date.month, date.day) ==
        DateTime(today.year, today.month, today.day);

    // Initial time: if today -> next 15-min upcoming slot, else fallback 10:00
    final initialTOD = isToday
        ? _nextUpcomingSlot15m(today)
        : const TimeOfDay(hour: 10, minute: 0);

    final picked = await showTimePicker(
      context: context,
      initialTime: initialTOD,
      useRootNavigator: true, // show above the bottom sheet
      builder: (context, child) {
        // 🔒 Force 24-hour picker
        final mq = MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true);
        return MediaQuery(
          data: mq,
          child: Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: Color(0xFF0C1E2C),
                onPrimary: Colors.white,
                surface: Colors.white,
                onSurface: Colors.black,
              ),
              timePickerTheme: const TimePickerThemeData(
                hourMinuteTextColor: Colors.black,
                dayPeriodTextColor: Colors.black,
                dialHandColor: Color(0xFF0C1E2C),
                dialTextColor: Colors.black,
                helpTextStyle: TextStyle(color: Colors.black),
                hourMinuteColor: Colors.white,
                hourMinuteTextStyle: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 24,
                ),
                entryModeIconColor: Color(0xFF0C1E2C),
              ),
            ),
            child: child!,
          ),
        );
      },
    );

    if (picked != null) {
      // If today and user chose a past time, override to next upcoming slot + message
      if (isToday && _isPastTodayTime(date, picked)) {
        final nextSlot = _nextUpcomingSlot15m(DateTime.now());
        ctrl.selectedTime.value = nextSlot;
        ctrl.selectedTime.refresh();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Past time is not allowed. Set to next available: ${_formatTime(nextSlot)}',
            ),
          ),
        );
        return;
      }

      ctrl.selectedTime.value = picked;
      ctrl.selectedTime.refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final courtNumbers = _extractCourtNumbers();

    // unique tag so this temp controller dies with the sheet
    final tag = 'booking-${playgroundId}-${DateTime.now().millisecondsSinceEpoch}';

    final ctrl = Get.put(
      BookingController(
        playgroundId: playgroundId,
        availableCourts: courtNumbers,
        durationOptions: const [],
      ),
      tag: tag,
    );

    // preselect sensible defaults
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    ctrl.selectedCourtNumber.value ??= courtNumbers.isNotEmpty ? courtNumbers.first : null;
    ctrl.selectedDate.value ??= today;
    // time stays null until user picks — UI will show "Select time"

    return Obx(() {
      // reactive touches
      final selectedCourt = ctrl.selectedCourtNumber.value;
      final selectedTime = ctrl.selectedTime.value;
      final selectedDuration = ctrl.selectedDuration.value;

      final dateVal = ctrl.selectedDate.value;
      final dateString = dateVal == null ? '' : _formatDate(dateVal);
      final timeString = selectedTime == null ? '' : _formatTime(selectedTime);

      // durations for the selected court
      final durations = _extractDurationsFor(selectedCourt);

      // keep duration valid
      if (durations.isNotEmpty &&
          (selectedDuration == null || !durations.contains(selectedDuration))) {
        ctrl.selectedDuration.value = durations.first;
      }
      if (durations.isEmpty && selectedDuration != null) {
        ctrl.selectedDuration.value = null;
      }

      // compute price
      final currentPrice = _priceFor(selectedCourt, ctrl.selectedDuration.value);
      final priceString = currentPrice == null ? '—' : 'Rs. $currentPrice';

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
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
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

                  // Court selector (backend numbers)
                  const Text('Court', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  if (courtNumbers.isEmpty)
                    const Text('No courts available', style: TextStyle(color: Colors.grey))
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: courtNumbers.map((num) {
                        final isSelected = selectedCourt == num;
                        return ChoiceChip(
                          label: Text(num),
                          selected: isSelected,
                          onSelected: (_) => ctrl.selectedCourtNumber.value = num,
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
                          onTap: () => _pickDate(context, ctrl),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _FieldCard(
                          icon: LucideIcons.clock,
                          label: 'Start Time',
                          value: timeString.isEmpty
                              ? (DateTime.now().difference(
                              DateTime((dateVal ?? DateTime.now()).year,
                                  (dateVal ?? DateTime.now()).month,
                                  (dateVal ?? DateTime.now()).day)) ==
                              Duration.zero
                              ? 'Select time (next: ${_formatTime(_nextUpcomingSlot15m(DateTime.now()))})'
                              : 'Select time')
                              : timeString,
                          onTap: () {
                            if (ctrl.selectedDate.value == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Please select a date first.')),
                              );
                              return;
                            }
                            _pickTime(context, ctrl);
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Duration + Price chips
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

                  const SizedBox(height: 20),

                  // Responsive summary (now with Price)
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
                  onPressed: ctrl.isLoading.value ? null : ctrl.submit,
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
                        : (currentPrice == null
                        ? 'Confirm Booking'
                        : 'Confirm Booking • Rs. $currentPrice'),
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
        // 5 across
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
        // 3 + 2 layout
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
        // stacked
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
