import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:padel_pro/services/vendors%20api/create_tournament_api.dart';


class CreateTournamentController extends GetxController {

  final tournamentName = ''.obs;
  final description = ''.obs;
  final registrationLink = ''.obs;
  final location = ''.obs;
  final startDate = Rxn<DateTime>();
  final startTime = Rxn<TimeOfDay>();
  final coverPhoto = Rxn<File>();


  final tournamentType = 'Mens'.obs;
  final List<String> tournamentTypes = ['Mens', 'Womens', 'Mix'];


  RxBool isLoading = false.obs;


  Future<void> pickCoverPhoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      coverPhoto.value = File(image.path);
    }
  }


  void removeCoverPhoto() {
    coverPhoto.value = null;
  }


  Future<void> createTournament() async {
    if (tournamentName.isEmpty ||
        description.isEmpty ||
        registrationLink.isEmpty ||
        location.isEmpty ||
        startDate.value == null ||
        startTime.value == null) {
      Get.snackbar('Validation Error', 'All fields are required',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    isLoading.value = true;

    try {

      final formattedDate =
          "${startDate.value!.year}-${startDate.value!.month.toString().padLeft(2, '0')}-${startDate.value!.day.toString().padLeft(2, '0')}";

      final formattedTime =
          "${startTime.value!.hour.toString().padLeft(2, '0')}:${startTime.value!.minute.toString().padLeft(2, '0')}";

      await CreateTournamentApi().createTournament(
        name: tournamentName.value,
        registrationLink: registrationLink.value,
        tournamentType: tournamentType.value,
        location: location.value,
        startDate: formattedDate,
        startTime: formattedTime,
        description: description.value,
        photo: coverPhoto.value,
      );
    } catch (e) {
      print('❌ Tournament create error: $e');
      Get.snackbar('Error', 'Failed to create tournament',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }
}
