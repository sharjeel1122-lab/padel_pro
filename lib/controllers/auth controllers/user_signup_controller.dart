import 'package:get/get.dart';
import 'package:padel_pro/services/user_signup_api.dart';
import 'auth_base_controller.dart';

class UserSignUpController extends BaseController {
  // Ensure a single instance exists
  final UserSignUpApi userSignUpApi = Get.put(UserSignUpApi());
  final obscureText = true.obs;

  void togglePasswordVisibility() => obscureText.toggle();

  Future<void> signupUser({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String mpin,
    required String city,
    required String town, // REQUIRED now
    required String phone,
    String role = 'user', // default role
    String photoPath = '',
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
        town: town,
        phone: phone,
        role: role,
        photoPath: photoPath,
      );

      showSnackbar(
        'Signup Successful',
        response['message'] ?? 'Account created. Check your email for OTP.',
      );

      Get.offAllNamed('/verify-your-email', arguments: email);
    } catch (e) {
      showSnackbar('Signup Failed', e.toString().replaceAll('Exception: ', ''), isError: true);
    } finally {
      isLoading(false);
    }
  }
}
