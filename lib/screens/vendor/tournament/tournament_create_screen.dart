import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class CreateTournamentController extends GetxController {
  final tournamentName = ''.obs;
  final description = ''.obs;
  final registrationLink = ''.obs;
  final location = ''.obs;
  final startDate = Rxn<DateTime>();
  final startTime = Rxn<TimeOfDay>();

  void createTournament() {
    // Implement API call to create tournament
    Get.snackbar('Success', 'Tournament created successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white);
  }
}

class CreateTournamentScreen extends StatelessWidget {
  final controller = Get.put(CreateTournamentController());

 CreateTournamentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C1E2C),
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Create Tournament', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF0C1E2C),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildTournamentCard(
              child: Column(
                children: [
                  _buildTextField(
                    label: 'Tournament Name',
                    hint: 'Enter tournament name',
                    onChanged: (value) => controller.tournamentName.value = value,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    label: 'Description',
                    hint: 'Enter tournament description',
                    maxLines: 3,
                    onChanged: (value) => controller.description.value = value,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildTournamentCard(
              child: Column(
                children: [
                  _buildTextField(
                    label: 'Registration Form Link',
                    hint: 'Enter Google Form or other link',
                    onChanged: (value) => controller.registrationLink.value = value,
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
            _buildTournamentCard(
              child: Column(
                children: [
                  _buildDatePicker(
                    label: 'Start Date',
                    date: controller.startDate.value,
                    onTap: () => _selectDate(context),
                  ),
                  const SizedBox(height: 20),
                  _buildTimePicker(
                    label: 'Start Time',
                    time: controller.startTime.value,
                    onTap: () => _selectTime(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: controller.createTournament,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Create Tournament',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: Color(0xFF0C1E2C)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTournamentCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E3354),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 2,
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
            fillColor: Colors.white.withOpacity(0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(15),
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildDatePicker({
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
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, color: Colors.white70),
                const SizedBox(width: 10),
                Text(
                  date != null
                      ? DateFormat('MMM dd, yyyy').format(date)
                      : 'Select date',
                  style: TextStyle(
                    color: date != null ? Colors.white : Colors.white.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimePicker({
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
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.access_time, color: Colors.white70),
                const SizedBox(width: 10),
                Text(
                  ''
                  // time != null
                  //     ? time.format(context)
                  //     : 'Select time',
                  // style: TextStyle(
                  //   color: time != null ? Colors.white : Colors.white.withOpacity(0.5),
                  // ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.blueAccent,
              onPrimary: Colors.white,
              surface: Color(0xFF1E3354),
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: const Color(0xFF0C1E2C),
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
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.blueAccent,
              onPrimary: Colors.white,
              surface: Color(0xFF1E3354),
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: const Color(0xFF0C1E2C),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      controller.startTime.value = picked;
    }
  }
}