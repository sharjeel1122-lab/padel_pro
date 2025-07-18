import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:padel_pro/screens/vendor/controllers/court_controller.dart';

void showCourtDialog(
  BuildContext context, {
  bool isEdit = false,
  String? courtId,
}) {
  final controller = Get.find<VendorCourtController>();

  showDialog(
    context: context,
    builder: (_) => Dialog(
      backgroundColor: Colors.grey.shade200,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEdit ? "Edit Court" : "Add New Court",
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF072A40),
                ),
              ),
              const SizedBox(height: 16),
              Obx(() {
                final images = controller.selectedImages;
                return Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    ...images.map(
                      (file) => Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              file,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: GestureDetector(
                              onTap: () => controller.removeImage(file),
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.black.withOpacity(0.5),
                                ),
                                child: const Icon(
                                  Icons.close,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: controller.pickMultipleImages,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey.shade200,
                        ),
                        child: const Icon(
                          Icons.add_a_photo,
                          color: Color(0xFF072A40),
                        ),
                      ),
                    ),
                  ],
                );
              }),
              const SizedBox(height: 16),
              _buildTextField(controller.nameCtrl, 'Court Name'),
              const SizedBox(height: 10),
              _buildTextField(controller.locationCtrl, 'Location'),
              const SizedBox(height: 10),
              _buildTextField(
                controller.priceCtrl,
                'Price/hr',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              _buildTimeField(context, controller.startTimeCtrl, 'Start Time'),
              const SizedBox(height: 10),
              _buildTimeField(context, controller.endTimeCtrl, 'End Time'),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      final valid = controller.validateFields();
                      if (!valid) return;
                      controller.addOrUpdateCourt(id: courtId);
                      Get.back();
                      Get.dialog(
                        AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          title: Text(
                            "Request Submitted",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          content: Text(
                            "Please wait for approval.\nFor queries, contact: 0301-4530509",
                            style: GoogleFonts.poppins(),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Get.back(),
                              child: const Text(
                                "OK",
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF072A40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      "Submit",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget _buildTextField(
  TextEditingController controller,
  String label, {
  TextInputType keyboardType = TextInputType.text,
}) {
  return TextField(
    controller: controller,
    keyboardType: keyboardType,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.poppins(),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
    ),
  );
}

Widget _buildTimeField(
  BuildContext context,
  TextEditingController controller,
  String label,
) {
  return TextField(
    controller: controller,
    readOnly: true,
    onTap: () async {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (time != null) controller.text = time.format(context);
    },
    decoration: InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.poppins(),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
    ),
  );
}
