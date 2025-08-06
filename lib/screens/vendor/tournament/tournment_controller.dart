import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class CreateTournamentController extends GetxController {
  final tournamentName = ''.obs;
  final description = ''.obs;
  final registrationLink = ''.obs;
  final location = ''.obs;
  final startDate = Rxn<DateTime>();
  final startTime = Rxn<TimeOfDay>();
  final coverPhoto = Rxn<File>();


  RxBool isLoading = false.obs;



  // Add tournament type
  final tournamentType = 'Men\'s'.obs;
  final List<String> tournamentTypes = ['Men\'s', 'Women\'s', 'Mixed'];

  Future<void> pickCoverPhoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      coverPhoto.value = File(image.path);
    }
  }

  void createTournament() {
    // Implement API call to create tournament
    Get.snackbar('Success', 'Tournament created successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white);
  }









  void removeCoverPhoto() {
    coverPhoto.value = null;
  }
}



