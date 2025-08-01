import 'package:get/get.dart';

import '../../../services/profile api/user_profile_api.dart';

class ProfileController extends GetxController {
  final ProfileApi _profileApi = ProfileApi();

  var isLoading = true.obs;
  var profileData = {}.obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    fetchProfile();
    super.onInit();
  }

  Future<void> fetchProfile() async {
    try {
      isLoading(true);
      final data = await _profileApi.getProfile();

      if (data != null) {
        profileData.value = data;
        errorMessage.value = '';
      } else {
        errorMessage.value = 'Failed to load profile data';
      }
    } catch (e) {
      errorMessage.value = 'Error: ${e.toString()}';
    } finally {
      isLoading(false);
    }
  }

  String get fullName => '${profileData['firstName']} ${profileData['lastName']}';
  bool get isVendor => profileData['role'] == 'vendor';
}