import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:padel_pro/screens/admin/controllers/dashboard_controller.dart';

class AddVenueScreen extends StatefulWidget {
  const AddVenueScreen({super.key});

  @override
  State<AddVenueScreen> createState() => _AddVenueScreenState();
}

class _AddVenueScreenState extends State<AddVenueScreen> {
  final controller = Get.find<DashboardController>();
  final _formKey = GlobalKey<FormState>();

  final titleController = TextEditingController();
  final locationController = TextEditingController();
  final pricePeakController = TextEditingController();
  final priceNonPeakController = TextEditingController();

  TimeOfDay? startTime;
  TimeOfDay? endTime;

  final RxList<File> images = <File>[].obs;
  final picker = ImagePicker();

  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            timePickerTheme: const TimePickerThemeData(
              backgroundColor: Color(0xFF0A3B5C),
              dialHandColor: Colors.white,
              hourMinuteColor: Colors.white24,
              entryModeIconColor: Colors.white,
              hourMinuteTextColor: Colors.white,
            ),
            colorScheme: const ColorScheme.dark(
              primary: Colors.white,
              onPrimary: Colors.black,
              surface: Color(0xFF0A3B5C),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        isStart ? startTime = picked : endTime = picked;
      });
    }
  }

  Future<void> _pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      images.add(File(picked.path));
    }
  }

  void _showSuccessDialog() {
    Get.defaultDialog(
      backgroundColor: const Color(0xFF0A3B5C),
      title: "Venue Submitted",
      titleStyle: GoogleFonts.poppins(
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      content: Column(
        children: [
          const Icon(Icons.check_circle_outline, color: Colors.white, size: 50),
          const SizedBox(height: 12),
          Text(
            "Venue successfully submitted.\nWhat would you like to do next?",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(color: Colors.white70),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Get.back(); // dialog
            Get.back(); // form
          },
          child: Text("Back to Dashboard", style: GoogleFonts.poppins(color: Colors.white)),
        ),
        TextButton(
          onPressed: () {
            Get.back(); // dialog
            Get.toNamed('/requests');
          },
          child: Text("Go to Requests", style: GoogleFonts.poppins(fontWeight: FontWeight.w600,color: Colors.white)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF072A40),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A3B5C),
        title: const Text("Add Venue", style: TextStyle(color: Colors.white)),
        leading: const BackButton(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField("Ground Title", titleController),
              _buildTextField("Location", locationController),
              _buildTextField("Price/hour (Peak)", pricePeakController, type: TextInputType.number),
              _buildTextField("Price/hour (Non-Peak)", priceNonPeakController, type: TextInputType.number),
              const SizedBox(height: 16),
              _buildTimePickerTile("Start Time", startTime, () => _pickTime(true)),
              _buildTimePickerTile("End Time", endTime, () => _pickTime(false)),
              const SizedBox(height: 16),
              Obx(() => Wrap(
                spacing: 10,
                runSpacing: 10,
                children: images
                    .map((img) => Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(img, width: 80, height: 80, fit: BoxFit.cover),
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: GestureDetector(
                        onTap: () => images.remove(img),
                        child: const CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.red,
                          child: Icon(Icons.close, size: 14, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ))
                    .toList(),
              )),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.image, color: Colors.white),
                label: const Text("Add Image", style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0A3B5C),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate() && startTime != null && endTime != null) {
                    controller.addCourt(
                      name: titleController.text,
                      type: "Pending Approval",
                    );
                    _showSuccessDialog();
                  } else {
                    Get.snackbar("Missing Fields", "Please complete all fields including time.",
                        backgroundColor: Colors.red, colorText: Colors.white);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0A3B5C),
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: Text("Submit", style: GoogleFonts.poppins(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {TextInputType type = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        cursorColor: Colors.white,
        controller: controller,
        keyboardType: type,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          enabledBorder:
          const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white30)),
          focusedBorder:
          const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
        ),
        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
      ),
    );
  }

  Widget _buildTimePickerTile(String label, TimeOfDay? time, VoidCallback onTap) {
    return ListTile(
      title: Text(label, style: GoogleFonts.poppins(color: Colors.white70)),
      subtitle: Text(
        time != null ? time.format(context) : "Select",
        style: GoogleFonts.poppins(color: Colors.white),
      ),
      trailing: const Icon(Icons.access_time, color: Colors.white),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
    );
  }
}
