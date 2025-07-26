import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:padel_pro/app_color.dart';
import 'package:padel_pro/controllers/auth%20controllers/user_signup_controller.dart';
import '../../../custom textfield/vendor_signup_fields.dart';

class SignUpScreen extends StatelessWidget {
  SignUpScreen({super.key});

  final _formKey = GlobalKey<FormState>();
  final UserSignUpController userSignUpController = Get.find<UserSignUpController>();
  final RxString _imagePath = RxString(''); // Initialize with empty string

  // Controllers
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _passwordController = TextEditingController();
  final _mpinController = TextEditingController();

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
                    'Create Account',
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

                // Full Name
                CustomTextField(
                  controller: _fullNameController,
                  label: 'Full Name',
                  icon: Icons.person_outline,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter full name';
                    } else if (value.trim().length < 3) {
                      return 'Full name must be at least 3 characters';
                    }
                    return null;
                  },
                ),

                // Email
                CustomTextField(
                  controller: _emailController,
                  label: 'Email',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter email';
                    } else if (!GetUtils.isEmail(value.trim())) {
                      return 'Enter a valid email';
                    }
                    return null;
                  },
                ),

                // Phone
                CustomTextField(
                  controller: _phoneController,
                  label: 'Phone Number',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter phone number';
                    } else if (!GetUtils.isPhoneNumber(value)) {
                      return 'Enter a valid number';
                    } else if (value.length < 11 || value.length > 13) {
                      return 'Number should be 11-13 digits';
                    }
                    return null;
                  },
                ),

                // City
                CustomTextField(
                  controller: _cityController,
                  label: 'Location',
                  icon: Icons.location_city_outlined,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter location';
                    }
                    return null;
                  },
                ),

                // MPIN
                CustomTextField(
                  controller: _mpinController,
                  label: '4-digit M-PIN',
                  icon: Icons.pin,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your M-PIN';
                    } else if (value.trim().length != 4 ||
                        !RegExp(r'^\d+$').hasMatch(value)) {
                      return 'M-PIN must be 4 digits';
                    }
                    return null;
                  },
                ),

                // Password
                Obx(() => CustomTextField(
                  controller: _passwordController,
                  label: 'Password',
                  icon: Icons.lock_outline,
                  obscureText: userSignUpController.obscureText.value, // Add .value here
                  suffixIcon: IconButton(
                    icon: Icon(
                      userSignUpController.obscureText.value
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: AppColors.primary,
                    ),
                    onPressed: userSignUpController.togglePasswordVisibility,
                  ),
                  validator: (value) {
                    if (value == null || value.length < 6) {
                      return 'Enter at least 6 characters';
                    }
                    return null;
                  },
                )),

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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF072A40),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: userSignUpController.isLoading.value
                        ? null
                        : () {
                      if (_formKey.currentState!.validate()) {
                        userSignUpController.signupUser(
                          firstName: _fullNameController.text.trim().split(" ").first,
                          lastName: _fullNameController.text.trim().split(" ").skip(1).join(" "),
                          email: _emailController.text.trim(),
                          phone: _phoneController.text.trim(),
                          city: _cityController.text.trim(),
                          password: _passwordController.text.trim(),
                          mpin: _mpinController.text.trim(),
                          photoPath: _imagePath.value,
                        );
                      }
                    },
                    child: userSignUpController.isLoading.value
                        ? const CircularProgressIndicator(
                      color: Colors.white,
                    )
                        : Text(
                      'REGISTER',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )),

                const SizedBox(height: 20),

                // OR Divider
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        'OR',
                        style: GoogleFonts.poppins(fontSize: 14),
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),

                const SizedBox(height: 20),

                // Google Sign Up
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: Image.asset('assets/google_logo.png', height: 24),
                    label: Text(
                      'Sign up with Google',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: AppColors.primaryText,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

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
                          color: Colors.black,
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