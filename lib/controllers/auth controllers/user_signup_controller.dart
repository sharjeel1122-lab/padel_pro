import 'package:get/get.dart';
import 'package:padel_pro/services/user_signup_api.dart';
import 'auth_base_controller.dart';

class UserSignUpController extends BaseController {
  final UserSignUpApi userSignUpApi = Get.put(UserSignUpApi());
  final obscureText = true.obs; // Observable for password visibility

  void togglePasswordVisibility() {
    obscureText.toggle();
  }

  Future<void> signupUser({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String mpin,
    required String city,
    required String phone,
    String photoPath = '', // Default empty string instead of nullable
  }) async {
    try {
      isLoading(true);

      final response = await userSignUpApi.signupUser(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        mpin: mpin,
        city: city,
        phone: phone,
        photoPath: photoPath,
      );

      showSnackbar(
        'Signup Successful',
        response['message'] ?? 'Account created. Check your email for OTP.',
      );

      Get.offAllNamed('/verify-your-email', arguments: email);
    } catch (e) {
      showSnackbar(
        'Signup Failed',
        e.toString().replaceAll('Exception: ', ''),
        isError: true,
      );
    } finally {
      isLoading(false);
    }
  }
}