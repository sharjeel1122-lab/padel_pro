import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:padel_pro/screens/user/user_controller/user_fetch_booking_controller.dart';

class EditBookingSheet extends StatelessWidget {
  const EditBookingSheet({super.key, required this.controller});
  final UserBookingController controller;

  Color get brand => const Color(0xFF0C1E2C);

  String _fmt2(int v) => v < 10 ? '0$v' : '$v';
  String _fmtDate(DateTime d) => '${d.year}-${_fmt2(d.month)}-${_fmt2(d.day)}';
  String _fmtTime(TimeOfDay t) => '${_fmt2(t.hour)}:${_fmt2(t.minute)}';

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final init = controller.editDate.value ?? today;

    final picked = await showDatePicker(
      context: context,
      firstDate: today,
      lastDate: today.add(const Duration(days: 120)),
      initialDate: init.isBefore(today) ? today : init,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFF0C1E2C), onPrimary: Colors.white),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      // if picking today & time is in past -> clear time
      final t = controller.editTime.value;
      if (t != null) {
        final selected = DateTime(picked.year, picked.month, picked.day, t.hour, t.minute);
        if (selected.isBefore(DateTime.now())) {
          controller.editTime.value = null;
        }
      }
      controller.editDate.value = picked;
    }
  }

  Future<void> _pickTime(BuildContext context) async {
    final init = controller.editTime.value ?? const TimeOfDay(hour: 10, minute: 0);
    final picked = await showTimePicker(
      context: context,
      initialTime: init,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFF0C1E2C)),
          timePickerTheme: const TimePickerThemeData(
            backgroundColor: Colors.white,
            hourMinuteTextColor: Colors.black, // visible text
            dialHandColor: Color(0xFF0C1E2C),
            dialBackgroundColor: Color(0x110C1E2C),
            entryModeIconColor: Color(0xFF0C1E2C),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      // disallow past time for today
      final d = controller.editDate.value ?? DateTime.now();
      final selected = DateTime(d.year, d.month, d.day, picked.hour, picked.minute);
      if (DateTime.now().isAfter(selected)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a future time.')),
        );
        return;
      }
      controller.editTime.value = picked;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final d = controller.editDate.value;
      final t = controller.editTime.value;
      final dur = controller.editDuration.value;
      final court = controller.editCourt.value ?? '';

      final dateStr = d == null ? 'Select date' : _fmtDate(d);
      final timeStr = t == null ? 'Select time' : _fmtTime(t);
      final isSaving = controller.isUpdating.value;

      final durations = const [30, 45, 60, 90, 120];

      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.78,
        minChildSize: 0.5,
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
                      width: 40, height: 5,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.black12, borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Icon(LucideIcons.pencil, color: brand),
                      const SizedBox(width: 8),
                      Text('Edit Booking',
                          style: TextStyle(color: brand, fontWeight: FontWeight.w800, fontSize: 18)),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Court
                  const Text('Court Number', style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: TextEditingController(text: court),
                    onChanged: (v) => controller.editCourt.value = v.trim(),
                    decoration: InputDecoration(
                      hintText: 'e.g. 1',
                      filled: true,
                      fillColor: brand.withOpacity(.04),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.black12.withOpacity(.2)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: brand, width: 1.2),
                      ),
                      prefixIcon: Icon(LucideIcons.doorOpen, color: brand),
                    ),
                    keyboardType: TextInputType.number,
                  ),

                  const SizedBox(height: 16),

                  // Date & Time
                  Row(
                    children: [
                      Expanded(
                        child: _FieldCard(
                          icon: LucideIcons.calendar,
                          label: 'Date',
                          value: dateStr,
                          onTap: () => _pickDate(context),
                          brand: brand,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _FieldCard(
                          icon: LucideIcons.clock,
                          label: 'Start Time',
                          value: timeStr,
                          onTap: () {
                            if (controller.editDate.value == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Please select a date first.')),
                              );
                              return;
                            }
                            _pickTime(context);
                          },
                          brand: brand,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Duration chips
                  const Text('Duration', style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: durations.map((m) {
                      final selected = dur == m;
                      return ChoiceChip(
                        label: Text('$m min'),
                        selected: selected,
                        onSelected: (_) => controller.editDuration.value = m,
                        selectedColor: brand,
                        labelStyle: TextStyle(
                          color: selected ? Colors.white : brand,
                          fontWeight: FontWeight.w700,
                        ),
                        backgroundColor: brand.withOpacity(.08),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 20),

                  // Summary
                  _Summary(
                    brand: brand,
                    date: d == null ? '—' : _fmtDate(d),
                    time: t == null ? '—' : _fmtTime(t),
                    court: (controller.editCourt.value ?? '').isEmpty ? '—' : controller.editCourt.value!,
                    duration: dur == null ? '—' : '$dur min',
                  ),
                ],
              ),

              // Save button
              Positioned(
                left: 16, right: 16, bottom: 20,
                child: ElevatedButton.icon(
                  onPressed: isSaving ? null : controller.submitEdit,
                  icon: isSaving
                      ? const SizedBox(
                    height: 20, width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                  )
                      : const Icon(LucideIcons.checkCircle2),
                  label: Text(isSaving ? 'Saving...' : 'Save Changes'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brand,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 54),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 6,
                    shadowColor: brand.withOpacity(.3),
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
    required this.brand,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;
  final Color brand;

  @override
  Widget build(BuildContext context) {
    final isHint = value.toLowerCase().startsWith('select');
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: brand.withOpacity(.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black12),
        ),
        child: Row(
          children: [
            Icon(icon, color: brand),
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

class _Summary extends StatelessWidget {
  const _Summary({
    required this.brand,
    required this.date,
    required this.time,
    required this.court,
    required this.duration,
  });

  final Color brand;
  final String date;
  final String time;
  final String court;
  final String duration;

  @override
  Widget build(BuildContext context) {
    Widget tile(IconData i, String t, String v) => Expanded(
      child: Container(
        constraints: const BoxConstraints(minHeight: 60),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(i, color: brand, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(t, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                const SizedBox(height: 2),
                Text(v, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700)),
              ]),
            ),
          ],
        ),
      ),
    );

    return LayoutBuilder(builder: (context, c) {
      final w = c.maxWidth;
      if (w >= 700) {
        return Row(
          children: [
            tile(LucideIcons.calendarDays, 'Date', date),
            const SizedBox(width: 10),
            tile(LucideIcons.clock4, 'Time', time),
            const SizedBox(width: 10),
            tile(LucideIcons.doorOpen, 'Court', court),
            const SizedBox(width: 10),
            tile(LucideIcons.timer, 'Duration', duration),
          ],
        );
      } else if (w >= 420) {
        return Column(
          children: [
            Row(children: [tile(LucideIcons.calendarDays, 'Date', date), const SizedBox(width: 10), tile(LucideIcons.clock4, 'Time', time)]),
            const SizedBox(height: 10),
            Row(children: [tile(LucideIcons.doorOpen, 'Court', court), const SizedBox(width: 10), tile(LucideIcons.timer, 'Duration', duration)]),
          ],
        );
      } else {
        return Column(
          children: [
            tile(LucideIcons.calendarDays, 'Date', date),
            const SizedBox(height: 10),
            tile(LucideIcons.clock4, 'Time', time),
            const SizedBox(height: 10),
            tile(LucideIcons.doorOpen, 'Court', court),
            const SizedBox(height: 10),
            tile(LucideIcons.timer, 'Duration', duration),
          ],
        );
      }
    });
  }
}
