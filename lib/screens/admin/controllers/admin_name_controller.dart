import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminNameController extends GetxController {
  final RxString adminName = ''.obs;
  final TextEditingController nameController = TextEditingController();
  
  static const String _adminNameKey = 'admin_name';

  @override
  void onInit() {
    super.onInit();
    loadAdminName();
  }

  @override
  void onClose() {
    nameController.dispose();
    super.onClose();
  }

  Future<void> loadAdminName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedName = prefs.getString(_adminNameKey) ?? '';
      adminName.value = savedName;
      nameController.text = savedName;
      update();
    } catch (e) {
      print('Error loading admin name: $e');
    }
  }

  Future<void> saveAdminName(String name) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_adminNameKey, name);
      adminName.value = name;
      nameController.text = name;
      update();
    } catch (e) {
      print('Error saving admin name: $e');
    }
  }

  void updateAdminName(String newName) {
    if (newName.trim().isNotEmpty) {
      saveAdminName(newName.trim());
    }
  }
}
