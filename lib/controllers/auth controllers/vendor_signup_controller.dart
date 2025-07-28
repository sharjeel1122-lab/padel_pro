import 'dart:io';
import 'package:get/get.dart';
import 'package:padel_pro/screens/verification/email_verification_screen.dart';
import 'package:padel_pro/screens/verification/verify_your_email.dart';
import 'package:padel_pro/services/vendor_signup_api.dart';
import '../../app routes/app_routes.dart';
import 'auth_base_controller.dart';

class VendorSignUpController extends BaseController {
  final obscureText = true.obs; // For password visibility toggle
  final vendorSignup = VendorSignupApi();

  void togglePasswordVisibility() {
    obscureText.toggle();
  }

  Future<void> signupVendor(Map<String, dynamic> data, File? photo) async {
    try {
      isLoading(true);

      final response = await vendorSignup.signupVendor(data, photo);

      if (response['status'] == 'success' && response['data'] != null) {
        final email = response['data']['email'];

        showSnackbar(
          'Signup Successful',
          'An OTP has been sent to $email. Please verify your email to continue.',
        );

        Get.offAllNamed('/verify-your-email', arguments: email);
      } else {
        final message = response['message'] ?? 'Signup failed. Please try again.';
        showSnackbar('Signup Failed', message, isError: true);
      }
    } catch (e) {
      showSnackbar(
          'Error',
          e.toString().replaceAll('Exception: ', ''),
          isError: true
      );
    } finally {
      isLoading(false);
    }
  }
}