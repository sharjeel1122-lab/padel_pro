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
    onDeleteConfirmed();
  }

  @override
  Widget build(BuildContext context) {
    final fullName = "${vendor.firstName} ${vendor.lastName}".trim();
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive font sizes
    final double nameFontSize = screenWidth < 360 ? 14.0 : 16.0;
    final double infoFontSize = screenWidth < 360 ? 12.0 : 14.0;

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(
        minHeight: 180,
      ),
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
                        fontSize: nameFontSize,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  if (vendor.isEmailVerified)
                    const Icon(Icons.verified, color: Colors.green, size: 18),
                ],
              ),
              const SizedBox(height: 6),

              // Info section with responsive text
              LayoutBuilder(
                builder: (context, constraints) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          "Email: ${vendor.email}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.white70, fontSize: infoFontSize)
                      ),
                      Text(
                          "Phone: ${vendor.phone ?? '—'}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.white70, fontSize: infoFontSize)
                      ),
                      Text(
                          "City: ${vendor.city ?? '—'}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.white70, fontSize: infoFontSize)
                      ),
                      Text(
                          "NTN: ${vendor.ntn ?? '—'}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.white70, fontSize: infoFontSize)
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 8),

              // Action buttons row
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Edit button
                  // TextButton.icon(
                  //   onPressed: onEdit,
                  //   icon: const Icon(Icons.edit, color: Colors.white70, size: 16),
                  //   label: Text(
                  //     "Edit",
                  //     style: TextStyle(
                  //       color: Colors.white70,
                  //       fontSize: infoFontSize,
                  //     ),
                  //   ),
                  //   style: TextButton.styleFrom(
                  //     padding: const EdgeInsets.symmetric(horizontal: 8),
                  //     minimumSize: const Size(60, 36),
                  //   ),
                  // ),

                  // Delete button - now properly connected to the dialog
                  TextButton.icon(
                    onPressed: () => _showDeleteDialog(context),
                    icon: const Icon(Icons.delete, color: Colors.redAccent, size: 16),
                    label: Text(
                      "Delete",
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontSize: infoFontSize,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: const Size(60, 36),
                    ),
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