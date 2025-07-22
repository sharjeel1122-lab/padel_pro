import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:padel_pro/screens/admin/total_vendors/edit_vendor_screen.dart';
import '../../../model/vendor_model.dart';

class VendorCardWidget extends StatelessWidget {
  final VendorModel vendor;
  final VoidCallback onEdit;
  final VoidCallback onDeleteConfirmed;
  final int index;


  const VendorCardWidget({
    super.key,
    required this.vendor,
    required this.onEdit,
    required this.index,
    required this.onDeleteConfirmed,
  });

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF0A3B5C),
        title: const Text("Confirm Delete", style: TextStyle(color: Colors.white)),
        content: const Text(
          "Are you sure you want to delete this vendor?",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onDeleteConfirmed();
            },
            child: const Text("Delete", style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 170),
      child: Card(
        color: const Color(0xFF0A3B5C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                vendor.name,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              Text("Email: ${vendor.email}", style: const TextStyle(color: Colors.white70)),
              Text("Phone: ${vendor.phone}", style: const TextStyle(color: Colors.white70)),
              Text("Location: ${vendor.location}", style: const TextStyle(color: Colors.white70)),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: () {
                      Get.to(() => EditVendorScreen(vendor: vendor, index: index,));
                    },
                    icon: const Icon(Icons.edit, color: Colors.orangeAccent, size: 20),
                  ),
                  IconButton(
                    onPressed: () => _showDeleteDialog(context),
                    icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
