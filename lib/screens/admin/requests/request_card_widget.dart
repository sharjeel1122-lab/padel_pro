// request_card_widget.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:padel_pro/screens/admin/requests/request_model.dart';


class RequestCardWidget extends StatelessWidget {
  final RequestModel request;
  final VoidCallback onApprove;
  final VoidCallback onDecline;

  const RequestCardWidget({
    super.key,
    required this.request,
    required this.onApprove,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF0A3B5C),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(request.name,
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600, color: Colors.white)),
            const SizedBox(height: 6),
            Text(request.details, style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 8),
            Chip(
              label: Text(
                request.type == RequestType.venue ? "Venue Request" : "Vendor Request",
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.white10,
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.check_circle, color: Colors.greenAccent),
                  onPressed: onApprove,
                ),
                IconButton(
                  icon: const Icon(Icons.cancel, color: Colors.redAccent),
                  onPressed: onDecline,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
