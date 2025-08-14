import 'package:flutter/material.dart';
import 'package:padel_pro/model/users%20model/user_model.dart';


class UserCardWidget extends StatelessWidget {
  final UserModel user;
  final VoidCallback onDeleteConfirmed;

  const UserCardWidget({
    super.key,
    required this.user,
    required this.onDeleteConfirmed,
  });

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF0A3B5C),
        title: const Text("Confirm Delete", style: TextStyle(color: Colors.white)),
        content: const Text(
          "Are you sure you want to delete this user?",
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
    return Card(
      color: const Color(0xFF0A3B5C),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("${user.firstName} ${user.lastName}",
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 6),
            Text("Email: ${user.email}", style: const TextStyle(color: Colors.white70)),
            Text("Phone: ${user.phone ?? '—'}", style: const TextStyle(color: Colors.white70)),
            Text("City: ${user.city ?? '—'}", style: const TextStyle(color: Colors.white70)),
            Text("Role: ${user.role}", style: const TextStyle(color: Colors.white70)),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // IconButton(
                //   onPressed: () => _showDeleteDialog(context),
                //   icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20),
                // ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
