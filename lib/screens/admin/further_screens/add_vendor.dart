// lib/screens/add_vendor_screen.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:padel_pro/screens/admin/further_screens/add_vendor_by_admin_controller.dart';


class AddVendorScreen extends StatefulWidget {
  const AddVendorScreen({super.key});

  @override
  State<AddVendorScreen> createState() => _AddVendorScreenState();
}

class _AddVendorScreenState extends State<AddVendorScreen> {
  final _formKey = GlobalKey<FormState>();

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final cnicController = TextEditingController();
  final phoneController = TextEditingController();
  final cityController = TextEditingController();
  final ntnController = TextEditingController();

  final _picker = ImagePicker();
  XFile? _photo;

  AddVendorByAdminController get addVendorCtrl => Get.find<AddVendorByAdminController>();

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    cnicController.dispose();
    phoneController.dispose();
    cityController.dispose();
    ntnController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked != null) {
      setState(() => _photo = picked);
    }
  }

  void _clearFields() {
    firstNameController.clear();
    lastNameController.clear();
    emailController.clear();
    cnicController.clear();
    phoneController.clear();
    cityController.clear();
    ntnController.clear();
    setState(() => _photo = null);
  }

  void _showSuccessDialog() {
    Get.defaultDialog(
      backgroundColor: const Color(0xFF0A3B5C),
      title: "Vendor Added",
      titleStyle: GoogleFonts.poppins(
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      content: Column(
        children: [
          const Icon(Icons.check_circle_outline, color: Colors.white, size: 50),
          const SizedBox(height: 12),
          Text(
            "Vendor created and credentials emailed.\nWhat would you like to do next?",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(color: Colors.white70),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Get.back();
            Get.back();
          },
          child: Text("Back to Dashboard",
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500, color: Colors.white)),
        ),
        TextButton(
          onPressed: () {
            Get.back();
            Get.toNamed('/requests');
          },
          child: Text("Go to Requests",
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600, color: Colors.white)),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (_photo == null) {
      Get.snackbar('Photo required', 'Please select a vendor photo.',
          backgroundColor: Color(0xFF0A3B5C), colorText: Colors.white);
      return;
    }
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final data = {
      "firstName": firstNameController.text.trim(),
      "lastName":  lastNameController.text.trim(),
      "email":     emailController.text.trim(),
      "city":      cityController.text.trim(),
      "phone":     phoneController.text.trim(),
      "cnic":      cnicController.text.trim(),
      if (ntnController.text.trim().isNotEmpty) "ntn": ntnController.text.trim(),
    };

    final ok = await addVendorCtrl.submit(
      formData: data,
      imagePath: _photo!.path,
    );

    if (ok && mounted) {
      _clearFields();
      _showSuccessDialog();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF072A40),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A3B5C),
        title: const Text("Add Vendor", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        leading: const BackButton(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Photo picker
              GestureDetector(
                onTap: _pickPhoto,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A3B5C),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 26,
                        backgroundImage: _photo != null ? FileImage(File(_photo!.path)) : null,
                        child: _photo == null
                            ? const Icon(Icons.photo_camera, color: Color(0xFF0A3B5C))
                            : null,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          _photo == null
                              ? 'Tap to select photo (required)'
                              : File(_photo!.path).path.split(Platform.pathSeparator).last,
                          style: GoogleFonts.poppins(color: Colors.white),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(Icons.upload_file, color: Colors.white70),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              _buildTextField("First Name", firstNameController),
              _buildTextField("Last Name", lastNameController),
              _buildTextField("Email", emailController, type: TextInputType.emailAddress),
              _buildTextField("Phone", phoneController, type: TextInputType.phone),
              _buildTextField("CNIC", cnicController, type: TextInputType.number),
              _buildTextField("City", cityController),
              _buildTextField("NTN (Optional)", ntnController, isOptional: true),

              const SizedBox(height: 30),

              Obx(() {
                final submitting = addVendorCtrl.isSubmitting.value;
                return ElevatedButton(
                  onPressed: submitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0A3B5C),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: submitting
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                      : Text(
                    "Submit",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      String label,
      TextEditingController controller, {
        TextInputType type = TextInputType.text,
        bool isOptional = false,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        cursorColor: Colors.white,
        controller: controller,
        keyboardType: type,
        style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white30),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          errorStyle: GoogleFonts.poppins(color: Colors.redAccent, fontSize: 12),
        ),
        validator: (v) {
          if (isOptional) return null;
          final value = v?.trim() ?? '';
          if (value.isEmpty) return 'Required';

          if (label == 'Email') {
            final emailReg = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
            if (!emailReg.hasMatch(value)) return 'Invalid email';
          }
          if (label == 'Phone') {
            if (value.length != 11 || int.tryParse(value) == null) {
              return 'Phone must be 11 digits';
            }
          }
          if (label == 'CNIC') {
            if (value.length != 13 || int.tryParse(value) == null) {
              return 'CNIC must be 13 digits';
            }
          }
          return null;
        },
      ),
    );
  }
}
