import 'dart:io';

import 'package:get/get.dart';
import 'package:padel_pro/services/profile%20api/profile_update_api.dart';

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

  String get fullName {
    final first = profileData['firstName'] ?? '';
    final last = profileData['lastName'] ?? '';
    return '$first $last'.trim();
  }

  bool get isVendor => profileData['role'] == 'vendor';

  Future<void> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
    String? city,
    String? town,
    File? imageFile,
  }) async {
    try {
      isLoading.value = true;
      final api = ProfileUpdateApi();
      final updated = await api.updateProfile(
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        city: city,
        town: town,
        photoFile: imageFile,
      );

      // Refresh local state
      await fetchProfile();

      final msg = (updated['_message'] as String?) ??
          'Profile updated successfully';
      Get.snackbar('Success', msg, snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Update failed', e.toString(),
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }






















}