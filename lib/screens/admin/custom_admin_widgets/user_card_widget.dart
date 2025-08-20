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

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF0A3B5C),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${user.firstName} ${user.lastName}",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 6),
            Text("Email: ${user.email}", maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70)),
            Text("Phone: ${user.phone ?? '—'}", maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70)),
            Text("City: ${user.city ?? '—'}", maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70)),
            Text("Role: ${user.role}", maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                tooltip: 'Delete user',
                onPressed: onDeleteConfirmed,
                icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
