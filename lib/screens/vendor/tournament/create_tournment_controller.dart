import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:padel_pro/services/vendors%20api/create_tournament_api.dart';
import 'package:padel_pro/services/vendors%20api/delete_vendor_tournament_api.dart';
import 'package:padel_pro/screens/vendor/tournament/vendor_view_tournament_screen.dart';


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

      // Success: reset form and show themed dialog, then navigate
      _resetForm();
      Get.dialog(
        AlertDialog(
          backgroundColor: const Color(0xFF0C1E2C),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: const [
              Icon(Icons.check_circle, color: Colors.greenAccent),
              SizedBox(width: 8),
              Text('Success', style: TextStyle(color: Colors.white)),
            ],
          ),
          content: const Text(
            'Tournament created successfully.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
                Get.off(() => const VendorTournamentsScreen());
              },
              child: const Text('OK', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
        barrierDismissible: false,
      );
    } catch (e) {
      print('❌ Tournament create error: $e');
      Get.snackbar('Error', 'Failed to create tournament',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  void _resetForm() {
    tournamentName.value = '';
    description.value = '';
    registrationLink.value = '';
    location.value = '';
    startDate.value = null;
    startTime.value = null;
    coverPhoto.value = null;
    tournamentType.value = 'Mens';
  }

  //DELETE

  final deletingIds = <String>{}.obs; // to show per-row loader/disable
  final tournaments = <Map<String, dynamic>>[].obs; // adapt to your model type

  final _api = DeleteVendorTournamentApi();

  Future<void> cancelTournament(String id) async {
    if (deletingIds.contains(id)) return;
    deletingIds.add(id);
    try {
      final ok = await _api.deleteTournament(id);
      if (!ok) throw Exception('Failed to delete tournament');

      // remove from local list (adjust key if your item is a model)
      tournaments.removeWhere((t) => (t['_id'] ?? t['id']) == id);
      // or await fetch() to refresh from server
    } finally {
      deletingIds.remove(id);
    }
  }



}
