import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart'; // For image picking
import 'dart:io'; // For File

class CreateTournamentController extends GetxController {
  final tournamentName = ''.obs;
  final description = ''.obs;
  final registrationLink = ''.obs;
  final location = ''.obs;
  final startDate = Rxn<DateTime>();
  final startTime = Rxn<TimeOfDay>();
  final coverPhoto = Rxn<File>();

  Future<void> pickCoverPhoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      coverPhoto.value = File(image.path);
    }
  }

  void createTournament() {
    // Implement API call to create tournament
    Get.snackbar('Success', 'Tournament created successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white);
  }

  void removeCoverPhoto() {
    coverPhoto.value = null;
  }

}

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
                                    color: Colors.white.withOpacity(0.7),
                                    size: 50),
                                const SizedBox(height: 10),
                                Text(
                                  'Add Tournament Cover',
                                  style: TextStyle(
                                      color: Colors.white.withOpacity(0.7),
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
                    onChanged: (value) => controller.tournamentName.value = value,
                  ),
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

            // Date & Time Section
            _buildTournamentCard(
              child: Column(
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
              ),
            ),
            const SizedBox(height: 30),

            // Create Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: controller.createTournament,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'CREATE TOURNAMENT',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0C1E2C),
                  ),
                ),
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
                    color: Colors.white.withOpacity(0.7),
                    size: 20),
                const SizedBox(width: 12),
                Text(
                  date != null
                      ? DateFormat('MMMM dd, yyyy').format(date)
                      : 'Select date',
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
                    color: Colors.white.withOpacity(0.7),
                    size: 20),
                const SizedBox(width: 12),
                Text(
                  time != null
                      ? time.format(context)
                      : 'Select time',
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: accentColor,
              onPrimary: Colors.white,
              surface: cardColor,
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: primaryColor,
            textTheme: TextTheme(
              bodyMedium: const TextStyle(color: Colors.white),
              titleMedium: TextStyle(color: Colors.white.withOpacity(0.8)),
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
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: accentColor,
              onPrimary: Colors.white,
              surface: cardColor,
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: primaryColor,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      controller.startTime.value = picked;
    }
  }}