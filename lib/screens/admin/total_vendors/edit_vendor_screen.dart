import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../model/vendor_model.dart';
import 'total_vendors_controller.dart';

class EditVendorScreen extends StatefulWidget {
  final VendorModel vendor;
  final int index;

  const EditVendorScreen({
    super.key,
    required this.vendor,
    required this.index,
  });

  @override
  State<EditVendorScreen> createState() => _EditVendorScreenState();
}

class _EditVendorScreenState extends State<EditVendorScreen> {
  final _formKey = GlobalKey<FormState>();
  final controller = Get.find<TotalVendorsController>();

  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController locationController;
  late TextEditingController ntnController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.vendor.name);
    emailController = TextEditingController(text: widget.vendor.email);
    phoneController = TextEditingController(text: widget.vendor.phone);
    locationController = TextEditingController(text: widget.vendor.location);
    ntnController = TextEditingController(text: widget.vendor.ntn ?? '');

  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    locationController.dispose();
    ntnController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF072A40),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A3B5C),
        title: const Text("Edit Vendor", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        leading: const BackButton(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField("Name", nameController),
              _buildTextField("Email", emailController, type: TextInputType.emailAddress),
              _buildTextField("Phone", phoneController, type: TextInputType.phone),
              _buildTextField("Location", locationController),
              _buildTextField("NTN (Optional)", ntnController, isOptional: true),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0A3B5C),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "Save Changes",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )
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
        style: GoogleFonts.poppins(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(color: Colors.white70),
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
          return v == null || v.trim().isEmpty ? 'Required' : null;
        },
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final updated = VendorModel(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        phone: phoneController.text.trim(),
        location: locationController.text.trim(),
        ntn: ntnController.text.trim().isNotEmpty ? ntnController.text.trim() : null,
      );

      controller.vendors[widget.index] = updated;

      Get.snackbar(
        "Vendor Updated",
        "Vendor details have been successfully updated",
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        duration: const Duration(seconds: 2),
      );

      // Clear fields
      nameController.clear();
      emailController.clear();
      phoneController.clear();
      locationController.clear();
      ntnController.clear();

      // Optionally go back after delay
      Future.delayed(const Duration(milliseconds: 800), () {
        Get.back(); // Close edit screen
      });
    }
  }
}
