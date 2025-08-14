import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'reset_controller.dart';

class ResetPasswordRequestScreen extends StatelessWidget {
  ResetPasswordRequestScreen({super.key});
  final c = Get.put(ResetController());
  final _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(iconTheme: const IconThemeData(color: Colors.black)),
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Text('Reset Password',
                  style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w600, color: const Color(0xFF072A40))),
              const SizedBox(height: 8),
              Text('Enter your email to receive a reset link',
                  style: GoogleFonts.poppins(color: Colors.grey[600])),
              const SizedBox(height: 40),
              Image.asset('assets/logo.png', height: 100),
              const SizedBox(height: 40),

              Obx(() => TextField(
                controller: _emailController,
                enabled: !c.loading.value,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              )),
              const SizedBox(height: 30),

              Obx(() => SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: c.loading.value
                      ? null
                      : () async {
                    FocusScope.of(context).unfocus();
                    c.email.value = _emailController.text.trim();
                    await c.sendReset(); // success -> Sign In
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF072A40),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: c.loading.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text('Send Link', style: GoogleFonts.poppins(color: Colors.white, fontSize: 16)),
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }
}
