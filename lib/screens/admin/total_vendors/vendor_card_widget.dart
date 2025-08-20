import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:padel_pro/model/vendors model/vendors_model.dart';
import 'package:padel_pro/screens/admin/total_vendors/edit_vendor_screen.dart';
// ❌ Remove this old type to avoid mismatch
// import '../../../model/vendor_model.dart';

class VendorCardWidget extends StatelessWidget {
  final VendorsModel vendor;
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
    final fullName = "${vendor.firstName} ${vendor.lastName}".trim();

    return SizedBox(
      child: Card(
        color: const Color(0xFF0A3B5C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(11),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name + verified
              Row(
                children: [
                  Expanded(
                    child: Text(
                      fullName.isEmpty ? '—' : fullName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  if (vendor.isEmailVerified)
                    const Icon(Icons.verified, color: Colors.green, size: 18),
                ],
              ),
              const SizedBox(height: 6),
              Text("Email: ${vendor.email}", maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70)),
              Text("Phone: ${vendor.phone ?? '—'}", maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70)),
              Text("City: ${vendor.city ?? '—'}", maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70)),
              Text("NTN: ${vendor.ntn ?? '—'}", maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  tooltip: 'Delete vendor',
                  onPressed: onDeleteConfirmed,
                  icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
