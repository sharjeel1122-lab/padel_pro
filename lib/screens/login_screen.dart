import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';


import '../controllers/auth controllers/auth_rolebase_controller.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final _formKey = GlobalKey<FormState>();
  final _emailPhoneController = TextEditingController();
  final _passwordController = TextEditingController();

  final AuthController authController = Get.put(AuthController());


  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: size.height * 0.05),
                Text(
                  'Sign In',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text(
                        'Login to your account for the best',
                        style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        'experience.',
                        style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: size.height * 0.05),
                TextFormField(
                  controller: _emailPhoneController,
                  cursorColor: Colors.black,
                  keyboardType: TextInputType.emailAddress,
                  style: GoogleFonts.poppins(fontSize: 16),
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.grey, width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                Obx(() => TextFormField(
                  controller: _passwordController,
                  obscureText: authController.obscureText.value,
                  cursorColor: Colors.black,
                  style: GoogleFonts.poppins(fontSize: 16),
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        authController.obscureText.value
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: Colors.black,
                      ),
                      onPressed: authController.toggleVisibility,
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.grey, width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.length < 6) {
                      return 'Enter at least 6 characters';
                    }
                    return null;
                  },
                )),
                const SizedBox(height: 20),
                const SizedBox(height: 20),
                Obx(() => ElevatedButton.icon(
                  onPressed: authController.isLoading.value
                      ? null
                      : () async {
                    if (_formKey.currentState!.validate()) {
                      await authController.login(
                        _emailPhoneController.text.trim(),
                        _passwordController.text.trim(),
                      );
                    }

                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF072A40),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  icon: authController.isLoading.value
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : const Icon(Icons.arrow_forward, color: Colors.white),
                  label: Text(
                    authController.isLoading.value ? 'Signing in...' : 'SIGN IN',
                    style: GoogleFonts.poppins(color: Colors.white),
                  ),
                )),
                const SizedBox(height: 40),

                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Get.toNamed('/reset/request'), // or '/reset-verify' if you keep OTP UI
                    child: Text(
                      'Forgot password?',
                      style: GoogleFonts.poppins(color: Color(0xFF072A40), fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text('OR', style: GoogleFonts.poppins(fontSize: 14)),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 30),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: Image.asset('assets/google_logo.png', height: 24),
                  label: Text(
                    'Sign in with Google',
                    style: GoogleFonts.poppins(fontSize: 16, color: Colors.black),
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Register as user? ",
                        style: GoogleFonts.poppins(fontSize: 16)),
                    GestureDetector(
                      onTap: () => Get.toNamed('/signup'),
                      child: Text(
                        'Sign up',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: const Color(0xFF072A40),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Register as vendor?",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => Get.toNamed('/vendorsignup'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF072A40),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.person_add_alt_1,
                                size: 18, color: Colors.white),
                            const SizedBox(width: 6),
                            Text(
                              'Sign up',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}