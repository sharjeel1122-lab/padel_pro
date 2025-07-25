import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:padel_pro/screens/verification/verification_controller.dart';


class EmailVerificationScreen extends StatelessWidget {
  const EmailVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(VerificationController());

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/logo.png',
                height: 100,
              ),
              const SizedBox(height: 30),

              Text(
                'Verify Your Email',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF072A40),
                ),
              ),

              const SizedBox(height: 10),

              Text(
                'We sent a 6-digit code to your email',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),

              const SizedBox(height: 5),

              Obx(() => Text(
                controller.email.value,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF072A40),
                ),
              )),

              const SizedBox(height: 40),

              // OTP Input Fields
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) => SizedBox(
                  width: 45,
                  child: TextField(
                    controller: controller.otpControllers[index],
                    focusNode: controller.focusNodes[index],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 1,
                    style: GoogleFonts.poppins(fontSize: 18),
                    decoration: InputDecoration(
                      counterText: '',
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Color(0xFF072A40),
                          width: 2,
                        ),
                      ),
                    ),
                    onChanged: (value) {
                      if (value.length == 1 && index < 5) {
                        controller.focusNodes[index + 1].requestFocus();
                      }
                    },
                  ),
                )),
              ),

              const SizedBox(height: 30),

              // Verify Button
              Obx(() => SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.isLoading.value ? null : controller.verifyOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF072A40),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: controller.isLoading.value
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : Text(
                    'VERIFY',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              )),

              const SizedBox(height: 30),

              // Resend Code
              Obx(() => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Didn't receive code? ",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  controller.countdown.value > 0
                      ? Text(
                    'Resend in ${controller.countdown.value}',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: const Color(0xFF072A40),
                      fontWeight: FontWeight.w500,
                    ),
                  )
                      : TextButton(
                    onPressed: controller.resendCode,
                    child: Text(
                      'Resend Now',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: const Color(0xFF072A40),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              )),

              const SizedBox(height: 20),

              // Support Text
              TextButton(
                onPressed: () {
                  Get.toNamed('/support');
                },
                child: Text(
                  'Need help? Contact Support',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}