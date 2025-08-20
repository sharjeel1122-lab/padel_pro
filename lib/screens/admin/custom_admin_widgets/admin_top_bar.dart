import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:padel_pro/controllers/auth%20controllers/auth_rolebase_controller.dart';
import 'package:padel_pro/screens/admin/controllers/admin_name_controller.dart';

import 'add_dialog.dart';

class AdminTopBar extends StatelessWidget {
  final bool isWide;
  AdminTopBar({super.key, required this.isWide});
  
  final authController = Get.find<AuthController>();
  final adminNameController = Get.put(AdminNameController());

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF0A3B5C),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GetBuilder<AdminNameController>(
              builder: (nameController) {
                return Row(
                  children: [
                    Icon(Icons.person,size: 22,color: Colors.white,),
                    Expanded(
                      child:

                      Text(
                        nameController.adminName.value.isEmpty 
                            ? "Admin Name" 
                            : nameController.adminName.value,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: isWide ? 18 : 16,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        _showEditNameDialog(context, nameController);
                      },
                      icon: const Icon(Icons.edit, color: Colors.white, size: 15),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        const SizedBox(width: 16),
        Container(
          height: 50,
          width: 50,
          decoration: BoxDecoration(
            color: const Color(0xFF0A3B5C),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            onPressed: () {
              authController.logout();
            },
            icon: const Icon(Icons.logout_rounded, color: Colors.white),
          ),
        ),
        if (isWide)
          Container(
            height: 50,
            width: 50,
            margin: const EdgeInsets.only(left: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF0A3B5C),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.tune, color: Colors.white),
          ),
        const SizedBox(width: 16),
        ElevatedButton.icon(
          onPressed: () {
            showDialog(context: context, builder: (_) => const AddDialog());
          },
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text("Add New", style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0A3B5C),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  void _showEditNameDialog(BuildContext context, AdminNameController nameController) {
    final TextEditingController dialogController = TextEditingController(
      text: nameController.adminName.value,
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0A3B5C),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Edit Admin Name',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: TextField(
            controller: dialogController,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              hintText: 'Enter admin name',
              hintStyle: GoogleFonts.poppins(
                color: Colors.white.withOpacity(0.7),
                fontSize: 16,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Colors.white,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
            ),
            cursorColor: Colors.white,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 16,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final newName = dialogController.text.trim();
                if (newName.isNotEmpty) {
                  nameController.updateAdminName(newName);
                  Navigator.of(context).pop();
                  Get.snackbar(
                    'Success',
                    'Admin name updated successfully',
                    snackPosition: SnackPosition.TOP,
                    backgroundColor: const Color(0xFF0A3B5C),
                    colorText: Colors.white,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF0A3B5C),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Save',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
