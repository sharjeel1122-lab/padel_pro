import 'package:get/get.dart';
import 'package:padel_pro/services/reset%20password/auth_reset_service.dart';

class ResetController extends GetxController {
  final AuthResetService api = AuthResetService();

  final email = ''.obs;
  final loading = false.obs;

  Future<void> sendReset() async {
    try {
      loading.value = true;
      await api.requestReset(email: email.value.trim());
      Get.snackbar('Email sent', 'Reset link sent. Please check your inbox/spam.');
      Get.offAllNamed('/login');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      loading.value = false;
    }
  }
}
