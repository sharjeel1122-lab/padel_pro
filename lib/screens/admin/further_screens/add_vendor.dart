import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/dashboard_controller.dart';

class AddVendorScreen extends StatelessWidget {
  AddVendorScreen({super.key});

  final controller = Get.find<DashboardController>();
  final _formKey = GlobalKey<FormState>();

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final mpinController = TextEditingController();
  final cnicController = TextEditingController();
  final phoneController = TextEditingController();
  final locationController = TextEditingController();
  final ntnController = TextEditingController();

  void _clearFields() {
    firstNameController.clear();
    lastNameController.clear();
    emailController.clear();
    passwordController.clear();
    mpinController.clear();
    cnicController.clear();
    phoneController.clear();
    locationController.clear();
    ntnController.clear();
  }

  void _showSuccessDialog(BuildContext context) {
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
            "Vendor successfully submitted.\nWhat would you like to do next?",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(color: Colors.white70),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Get.back(); // Close dialog
            Get.back(); // Back to Dashboard
          },
          child: Text("Back to Dashboard",
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500, color: Colors.white)),
        ),
        TextButton(
          onPressed: () {
            Get.back(); // Close dialog
            Get.toNamed('/requests'); // Navigate to request screen
          },
          child: Text("Go to Requests",
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600, color: Colors.white, )),
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
        title: const Text("Add Vendor",
            style: TextStyle(color: Colors.white)),
        centerTitle: true,
        leading: const BackButton(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField("First Name", firstNameController),
              _buildTextField("Last Name", lastNameController),
              _buildTextField("Email", emailController, type: TextInputType.emailAddress),
              _buildTextField("Phone", phoneController, type: TextInputType.phone),
              _buildTextField("Password", passwordController, isObscure: true),
              _buildTextField("MPIN", mpinController, type: TextInputType.number),
              _buildTextField("CNIC", cnicController, type: TextInputType.number),
              _buildTextField("Location", locationController),
              _buildTextField("NTN (Optional)", ntnController, isOptional: true),

              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    controller.addVendor(); // for now static
                    _clearFields();
                    _showSuccessDialog(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0A3B5C),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text("Submit",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    )),
              ),
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
        bool isObscure = false,
        bool isOptional = false,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        cursorColor: Colors.white,
        controller: controller,
        keyboardType: type,
        obscureText: isObscure,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 14,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(
            color: Colors.white70,
            fontSize: 14,
          ),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white30),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          errorStyle: GoogleFonts.poppins(
            color: Colors.redAccent,
            fontSize: 12,
          ),
        ),
        validator: (v) {
          if (isOptional) return null;
          if (v == null || v.trim().isEmpty) return 'Required';
          if (label == 'Password' && v.length < 8) return 'Password must be 8 characters';
          if (label == 'MPIN' && v.length != 4) return 'MPIN must be 4 digits';
          if (label == 'CNIC' && v.length != 13) return 'CNIC must be 13 digits';
          if (label == 'Phone' && v.length != 11) return 'Phone must be 11 digits';
          return null;
        },
      ),
    );
  }

}

