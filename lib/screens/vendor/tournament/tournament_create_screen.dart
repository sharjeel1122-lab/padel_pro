// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:padel_pro/screens/vendor/tournament/create_tournment_controller.dart';

class CreateTournamentScreen extends StatelessWidget {
  final controller = Get.put(CreateTournamentController());
  final Color primaryColor = const Color(0xFF0C1E2C);
  final Color cardColor = const Color(0xFF1E3354);
  final Color accentColor = const Color(0xFF00B4D8);

  CreateTournamentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Create Tournament',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: primaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            // Cover Photo Section
            _buildTournamentCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Cover Photo',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: controller.pickCoverPhoto,
                    child: Obx(() {
                      final imageFile = controller.coverPhoto.value;
                      return Stack(
                        children: [
                          Container(
                            height: 180,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              image: imageFile != null
                                  ? DecorationImage(
                                image: FileImage(imageFile),
                                fit: BoxFit.cover,
                              )
                                  : null,
                            ),
                            child: imageFile == null
                                ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_photo_alternate,
                                    color:
                                    Colors.white.withOpacity(0.7),
                                    size: 50),
                                const SizedBox(height: 10),
                                Text(
                                  'Add Tournament Cover',
                                  style: TextStyle(
                                      color: Colors.white
                                          .withOpacity(0.7),
                                      fontSize: 16),
                                ),
                              ],
                            )
                                : null,
                          ),
                          if (imageFile != null)
                            Positioned(
                              top: 10,
                              right: 10,
                              child: GestureDetector(
                                onTap: controller.removeCoverPhoto,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.6),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.close,
                                      color: Colors.white, size: 20),
                                ),
                              ),
                            ),
                        ],
                      );
                    }),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Recommended size: 1200x600px',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.5), fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Tournament Info Section
            _buildTournamentCard(
              child: Column(
                children: [
                  _buildTextField(
                    label: 'Tournament Name*',
                    hint: 'Enter tournament name',
                    onChanged: (value) =>
                    controller.tournamentName.value = value,
                  ),
                  const SizedBox(height: 20),
                  _buildTournamentTypeDropdown(),
                  const SizedBox(height: 20),
                  _buildTextField(
                    label: 'Description',
                    hint: 'Enter tournament description',
                    maxLines: 4,
                    onChanged: (value) => controller.description.value = value,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Registration & Location Section
            _buildTournamentCard(
              child: Column(
                children: [
                  _buildTextField(
                    label: 'Registration Form Link',
                    hint: 'Enter Google Form or other link',
                    onChanged: (value) =>
                    controller.registrationLink.value = value,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    label: 'Location',
                    hint: 'Enter venue address',
                    onChanged: (value) => controller.location.value = value,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Date & Time Section
            _buildTournamentCard(
              child: Obx(() => Column(
                children: [
                  _buildDatePicker(
                    context: context,
                    label: 'Start Date',
                    date: controller.startDate.value,
                    onTap: () => _selectDate(context),
                  ),
                  const SizedBox(height: 20),
                  _buildTimePicker(
                    context: context,
                    label: 'Start Time',
                    time: controller.startTime.value,
                    onTap: () => _selectTime(context),
                  ),
                ],
              )),
            ),

            const SizedBox(height: 30),

            // Create Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: controller.createTournament,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3354),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Obx(() => controller.isLoading.value
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Create Tournament',
                    style: TextStyle(color: Colors.white))),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTournamentCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    int maxLines = 1,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 8),
        TextField(
          maxLines: maxLines,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
            filled: true,
            fillColor: Colors.white.withOpacity(0.08),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(14),
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildTournamentTypeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tournament Type',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Obx(() => Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButton<String>(
            value: controller.tournamentType.value,
            isExpanded: true,
            dropdownColor: cardColor,
            style: const TextStyle(color: Colors.white),
            underline: const SizedBox(), // Remove default underline
            items: controller.tournamentTypes.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                controller.tournamentType.value = newValue;
              }
            },
          ),
        )),
      ],
    );
  }

  // ----------------------- UPDATED: helper text + “future-only” hint -----------------------
  Widget _buildDatePicker({
    required BuildContext context,
    required String label,
    required DateTime? date,
    required Function() onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today,
                    color: Colors.white.withOpacity(0.7), size: 20),
                const SizedBox(width: 12),
                Text(
                  date != null
                      ? DateFormat('MMMM dd, yyyy').format(date)
                      : 'Select future date',
                  style: TextStyle(
                    color: date != null
                        ? Colors.white
                        : Colors.white.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        // Small helper text
        Text(
          'Please select a future date (after today).',
          style: TextStyle(
            color: Colors.white.withOpacity(0.55),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildTimePicker({
    required BuildContext context,
    required String label,
    required TimeOfDay? time,
    required Function() onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(Icons.access_time,
                    color: Colors.white.withOpacity(0.7), size: 20),
                const SizedBox(width: 12),
                Text(
                  time != null ? time.format(context) : 'Select time',
                  style: TextStyle(
                    color: time != null
                        ? Colors.white
                        : Colors.white.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ----------------------- UPDATED: today disabled (firstDate = tomorrow) -----------------------
  Future<void> _selectDate(BuildContext context) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    // Keep previously selected date if it's valid; otherwise start from tomorrow.
    final initial = controller.startDate.value ?? tomorrow;
    final safeInitial = initial.isBefore(tomorrow) ? tomorrow : initial;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: safeInitial,
      firstDate: tomorrow,                // <-- disallow today
      lastDate: DateTime(2101),
      builder: (context, child) {
        final base = Theme.of(context);
        return Theme(
          data: base.copyWith(
            colorScheme: ColorScheme.dark(
              primary: accentColor,
              onPrimary: Colors.white,
              surface: cardColor,
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: primaryColor,
            textTheme: base.textTheme.copyWith(
              bodyMedium: const TextStyle(color: Colors.white),
              titleMedium: TextStyle(color: Colors.white.withOpacity(0.85)),
            ),
            datePickerTheme: DatePickerThemeData(
              backgroundColor: primaryColor,
              headerBackgroundColor: cardColor,
              headerForegroundColor: Colors.white,
              dividerColor: Colors.white12,
              dayForegroundColor: MaterialStateProperty.resolveWith((states) {
                if (states.contains(MaterialState.selected)) return Colors.white;
                if (states.contains(MaterialState.disabled)) return Colors.white30;
                return Colors.white70;
              }),
              dayOverlayColor: MaterialStateProperty.all(Colors.white10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                textStyle: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      controller.startDate.value = picked;
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await _showCustomTimePicker(context,
        initialTime: controller.startTime.value);
    if (picked != null) {
      controller.startTime.value = picked;
    }
  }

  Future<TimeOfDay?> _showCustomTimePicker(BuildContext context,
      {TimeOfDay? initialTime}) async {
    final List<int> hours = List<int>.generate(24, (i) => i);
    const List<int> quarterMinutes = [0, 15, 30, 45];

    int nearestQuarter(int m) {
      int best = 0;
      int bestDiff = 60;
      for (final q in quarterMinutes) {
        final d = (m - q).abs();
        if (d < bestDiff) {
          best = q;
          bestDiff = d;
        }
      }
      return best;
    }

    final now = TimeOfDay.now();
    int selectedHour = (initialTime?.hour ?? now.hour).clamp(0, 23);
    int selectedMinute = nearestQuarter(initialTime?.minute ?? now.minute);

    final hourCtrl = FixedExtentScrollController(
      initialItem: selectedHour,
    );
    final minCtrl = FixedExtentScrollController(
      initialItem: quarterMinutes.indexOf(selectedMinute),
    );

    return showDialog<TimeOfDay>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return AlertDialog(
              backgroundColor: primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text(
                'Select Time',
                style: TextStyle(color: Colors.white),
              ),
              content: SizedBox(
                height: 220,
                child: Row(
                  children: [
                    Expanded(
                      child: CupertinoPicker(
                        scrollController: hourCtrl,
                        itemExtent: 36,
                        magnification: 1.1,
                        useMagnifier: true,
                        backgroundColor: primaryColor,
                        onSelectedItemChanged: (i) => setState(() {
                          selectedHour = hours[i];
                        }),
                        selectionOverlay: CupertinoPickerDefaultSelectionOverlay(
                          background: Colors.white.withOpacity(0.08),
                        ),
                        children: hours
                            .map((h) => Center(
                                  child: Text(
                                    h.toString().padLeft(2, '0'),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CupertinoPicker(
                        scrollController: minCtrl,
                        itemExtent: 36,
                        magnification: 1.1,
                        useMagnifier: true,
                        backgroundColor: primaryColor,
                        onSelectedItemChanged: (i) => setState(() {
                          selectedMinute = quarterMinutes[i];
                        }),
                        selectionOverlay: CupertinoPickerDefaultSelectionOverlay(
                          background: Colors.white.withOpacity(0.08),
                        ),
                        children: quarterMinutes
                            .map((m) => Center(
                                  child: Text(
                                    m.toString().padLeft(2, '0'),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
                ),
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(
                    TimeOfDay(hour: selectedHour, minute: selectedMinute),
                  ),
                  child: Text('OK', style: TextStyle(color: accentColor, fontWeight: FontWeight.w600)),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
