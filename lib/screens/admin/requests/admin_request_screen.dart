import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:padel_pro/screens/admin/requests/request_model.dart';
import 'request_controller.dart';

class AdminRequestScreen extends StatelessWidget {
  AdminRequestScreen({super.key});

  final controller = Get.put(RequestController());

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 700;

    return Scaffold(
      backgroundColor: const Color(0xFF072A40),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text("Requests",
            style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFF0A3B5C),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🔍 Search Bar
            TextField(
              cursorColor: Colors.white,
              onChanged: controller.search,
              style: GoogleFonts.poppins(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Search by name, location or price",
                hintStyle: GoogleFonts.poppins(color: Colors.white54),
                prefixIcon: const Icon(Icons.search, color: Colors.white),
                filled: true,
                fillColor: const Color(0xFF0A3B5C),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.white38),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.white, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Requests Grid/List
            Expanded(
              child: Obx(() {
                if (controller.requests.isEmpty) {
                  return Center(
                    child: Text(
                      "No pending requests",
                      style: GoogleFonts.poppins(color: Colors.white70),
                    ),
                  );
                }

                return GridView.builder(
                  itemCount: controller.requests.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isWide ? 2 : 1,
                    childAspectRatio: isWide ? 3 : 2.2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                  ),
                  itemBuilder: (_, index) {
                    final req = controller.requests[index];
                    return _buildRequestCard(req, index);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestCard(RequestModel req, int index) {
    return Card(
      color: const Color(0xFF0A3B5C),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(req.name,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                )),
            const SizedBox(height: 4),
            Text(req.details,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.white70,
                )),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _confirmAction(
                    index: index,
                    title: "Approve Request",
                    message: "Are you sure you want to approve this request?",
                    onConfirm: () {
                      controller.approveRequest(index);
                      Get.back();
                      Get.snackbar(
                        "Approved",
                        "Request has been approved",
                        backgroundColor: Colors.green,
                        colorText: Colors.white,
                        snackPosition: SnackPosition.TOP,
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      );
                    },
                  ),
                  icon: const Icon(Icons.check_circle_outline, color: Colors.green),
                  label: Text("Approve",
                      style: GoogleFonts.poppins(
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                      )),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => _confirmAction(
                    index: index,
                    title: "Decline Request",
                    message: "Are you sure you want to decline this request?",
                    onConfirm: () {
                      controller.declineRequest(index);
                      Get.back();
                      Get.snackbar(
                        "Declined",
                        "Request has been declined",
                        backgroundColor: Colors.redAccent,
                        colorText: Colors.white,
                        snackPosition: SnackPosition.TOP,
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      );
                    },
                  ),
                  icon: const Icon(Icons.cancel_outlined, color: Colors.redAccent),
                  label: Text("Decline",
                      style: GoogleFonts.poppins(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.w500,
                      )),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmAction({
    required int index,
    required String title,
    required String message,
    required VoidCallback onConfirm,
  }) {
    Get.defaultDialog(
      title: title,
      titleStyle: GoogleFonts.poppins(
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      middleText: message,
      middleTextStyle: GoogleFonts.poppins(color: Colors.white70),
      backgroundColor: const Color(0xFF0A3B5C),
      radius: 12,
      confirm: TextButton(
        onPressed: onConfirm,
        child: Text("Yes", style: GoogleFonts.poppins(color: Colors.greenAccent)),
      ),
      cancel: TextButton(
        onPressed: () => Get.back(),
        child: Text("No", style: GoogleFonts.poppins(color: Colors.redAccent)),
      ),
    );
  }
}
