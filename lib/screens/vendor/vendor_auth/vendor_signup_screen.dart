import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:padel_pro/app_color.dart';
import 'package:padel_pro/controllers/auth%20controllers/vendor_signup_controller.dart';
import '../../../custom textfield/vendor_signup_fields.dart';

class VendorSignUpScreen extends StatelessWidget {
  VendorSignUpScreen({super.key});

  final _formKey = GlobalKey<FormState>();
  final VendorSignUpController vendorController = Get.find<VendorSignUpController>();
  final RxString _imagePath = RxString('');

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

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _imagePath.value = pickedFile.path;
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
                  child: Obx(() => GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColors.lightGrey,
                      backgroundImage: _imagePath.value.isNotEmpty
                          ? FileImage(File(_imagePath.value))
                          : null,
                      child: _imagePath.value.isEmpty
                          ? const Icon(
                        Icons.camera_alt,
                        size: 30,
                        color: AppColors.primary,
                      )
                          : null,
                    ),
                  )),
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
                Obx(() => CustomTextField(
                  controller: _passwordController,
                  label: 'Password',
                  icon: Icons.lock_outline,
                  obscureText: vendorController.obscureText.value,
                  suffixIcon: IconButton(
                    icon: Icon(
                      vendorController.obscureText.value
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: AppColors.primary,
                    ),
                    onPressed: vendorController.togglePasswordVisibility,
                  ),
                  validator: (value) => value == null || value.length < 6
                      ? 'Minimum 6 characters'
                      : null,
                )),

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
                Obx(() => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: vendorController.isLoading.value
                        ? null
                        : () {
                      if (_formKey.currentState!.validate()) {
                        vendorController.signupVendor({
                          'firstName': _firstNameController.text.trim(),
                          'lastName': _lastNameController.text.trim(),
                          'email': _emailController.text.trim(),
                          'password': _passwordController.text.trim(),
                          'mpin': _mpinController.text.trim(),
                          'phone': _phoneController.text.trim(),
                          'cnic': _cnicController.text.trim(),
                          'ntn': _ntnController.text.trim(),
                          'city': _cityController.text.trim(),
                          // 'address': _addressController.text.trim(),
                        }, _imagePath.value.isNotEmpty ? File(_imagePath.value) : null);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: vendorController.isLoading.value
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                      'REGISTER AS VENDOR',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )),

                const SizedBox(height: 20),

                // Already have account
                Center(
                  child: TextButton(
                    onPressed: () => Get.back(),
                    child: Text.rich(
                      TextSpan(
                        text: 'Already have an account? ',
                        style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.black
                        ),
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