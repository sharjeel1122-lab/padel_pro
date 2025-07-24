import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:padel_pro/app_color.dart';
import '../../../controllers/auth_controller.dart';
import '../../../custom textfield/vendor_signup_fields.dart';

class VendorSignUpScreen extends StatefulWidget {
  const VendorSignUpScreen({super.key});

  @override
  State<VendorSignUpScreen> createState() => _VendorSignUpScreenState();
}

class _VendorSignUpScreenState extends State<VendorSignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final authController = Get.put(AuthController());
  String? _imagePath;

  // Controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _mpinController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cnicController = TextEditingController();
  final _ntnController = TextEditingController();
  final _cityController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _mpinController.dispose();
    _phoneController.dispose();
    _cnicController.dispose();
    _ntnController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back Button
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: AppColors.primary),
                  onPressed: () => Get.back(),
                ),

                const SizedBox(height: 10),

                // Title
                Center(
                  child: Text(
                    'Create Vendor Account',
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryText,
                    ),
                  ),
                ),

                const SizedBox(height: 5),

                Center(
                  child: Text(
                    'Fill in your details to get started',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.secondaryText,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Profile Picture
                Center(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColors.lightGrey,
                      backgroundImage: _imagePath != null
                          ? FileImage(File(_imagePath!))
                          : null,
                      child: _imagePath == null
                          ? const Icon(
                              Icons.camera_alt,
                              size: 30,
                              color: AppColors.primary,
                            )
                          : null,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Two Column Layout for Name Fields
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: _firstNameController,
                        label: 'First Name',
                        icon: Icons.person_outline,
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? 'Required field'
                            : null,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: CustomTextField(
                        controller: _lastNameController,
                        label: 'Last Name',
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? 'Required field'
                            : null,
                      ),
                    ),
                  ],
                ),

                CustomTextField(
                  controller: _emailController,
                  label: 'Email',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Required field';
                    if (!GetUtils.isEmail(value.trim())) return 'Invalid email';
                    return null;
                  },
                ),

                // Password with visibility toggle
                GetBuilder<AuthController>(
                  builder: (controller) {
                    return CustomTextField(
                      controller: _passwordController,
                      label: 'Password',
                      icon: Icons.lock_outline,
                      obscureText: controller.obscureText,
                      suffixIcon: IconButton(
                        icon: Icon(
                          controller.obscureText
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: AppColors.primary,
                        ),
                        onPressed: controller.togglePasswordVisibility,
                      ),
                      validator: (value) => value == null || value.length < 6
                          ? 'Minimum 6 characters'
                          : null,
                    );
                  },
                ),

                CustomTextField(
                  controller: _mpinController,
                  label: '4-digit M-PIN',
                  icon: Icons.lock_outline,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty)
                      return 'Required field';
                    if (value.trim().length != 4 ||
                        !RegExp(r'^\d+$').hasMatch(value)) {
                      return 'Must be 4 digits';
                    }
                    return null;
                  },
                ),

                CustomTextField(
                  controller: _phoneController,
                  label: 'Phone Number',
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty)
                      return 'Required field';
                    if (!RegExp(r'^[0-9]{11,}$').hasMatch(value)) {
                      return 'Invalid phone number';
                    }
                    return null;
                  },
                ),

                CustomTextField(
                  controller: _cnicController,
                  label: 'CNIC (Without dashes)',
                  icon: Icons.credit_card,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty)
                      return 'Required field';
                    if (value.trim().length != 13) return 'Must be 13 digits';
                    return null;
                  },
                ),

                CustomTextField(
                  controller: _ntnController,
                  label: 'NTN Number',
                  icon: Icons.business,
                  keyboardType: TextInputType.number,
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Required field'
                      : null,
                ),

                CustomTextField(
                  controller: _cityController,
                  label: 'City',
                  icon: Icons.location_city,
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Required field'
                      : null,
                ),

                CustomTextField(
                  controller: _addressController,
                  label: 'Business Address',
                  icon: Icons.home,
                  maxLines: 3,
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Required field'
                      : null,
                ),

                const SizedBox(height: 30),

                // Terms and Conditions
                Row(
                  children: [
                    Checkbox(
                      value: true,
                      onChanged: (value) {},
                      activeColor: AppColors.primary,
                    ),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          text: 'I agree to the ',
                          style: GoogleFonts.poppins(fontSize: 12),
                          children: [
                            TextSpan(
                              text: 'Terms & Conditions',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Sign Up Button
                GetBuilder<AuthController>(
                  builder: (controller) {
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: controller.isLoading
                            ? null
                            : () {
                                if (_formKey.currentState!.validate()) {
                                  controller.signupVendor(
                                    firstName: _firstNameController.text.trim(),
                                    lastName: _lastNameController.text.trim(),
                                    email: _emailController.text.trim(),
                                    password: _passwordController.text.trim(),
                                    mpin: _mpinController.text.trim(),
                                    phone: _phoneController.text.trim(),
                                    cnic: _cnicController.text.trim(),
                                    ntn: _ntnController.text.trim(),
                                    city: _cityController.text.trim(),
                                    photo: _imagePath,
                                  );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: controller.isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : Text(
                                'REGISTER AS VENDOR',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20),

                // Already have account
                Center(
                  child: TextButton(
                    onPressed: () => Get.back(),
                    child: Text.rich(
                      TextSpan(
                        text: 'Already have an account? ',
                        style: GoogleFonts.poppins(fontSize: 14, color: Colors.black),
                        children: [
                          TextSpan(
                            text: 'Sign In',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
