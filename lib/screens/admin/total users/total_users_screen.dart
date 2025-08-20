import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:padel_pro/screens/admin/custom_admin_widgets/user_card_widget.dart';
import 'package:padel_pro/screens/admin/total users/total_users_controller.dart';

class TotalUsersScreen extends StatelessWidget {
  TotalUsersScreen({super.key});
  final controller = Get.put(TotalUsersController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF072A40),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF0A3B5C),
        title: const Text("All Users", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const _FullScreenLoader();
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final crossAxisCount = w >= 1100 ? 3 : (w >= 700 ? 2 : 1);

            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildSearchBar(),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Obx(() {
                      final list = controller.filteredUsers;
                      if (list.isEmpty) {
                        return const Center(
                          child: Text("No users found",
                              style: TextStyle(color: Colors.white70)),
                        );
                      }
                      return GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 2.1,
                        ),
                        itemCount: list.length,
                        itemBuilder: (context, index) {
                          final user = list[index];
                          return UserCardWidget(
                            user: user,
                            onDeleteConfirmed: () async {
                              final ok = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => const _ConfirmDialog(
                                  title: 'Delete User',
                                  message: 'Are you sure you want to delete this user?',
                                ),
                              );
                              if (ok != true) return;

                              final original = controller.users.toList();
                              controller.users.removeWhere((u) => u.id == user.id);

                              final success = await controller.deleteUserById(user.id);
                              if (!success) {
                                controller.users.assignAll(original);
                                Get.snackbar('Error', 'Failed to delete user');
                              } else {
                                Get.snackbar(
                                    backgroundColor: Color(0xFF0A3B5C),
                                    colorText: Colors.white,
                                    'Deleted', 'User deleted successfully');
                              }
                            },
                          );
                        },
                      );
                    }),
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      cursorColor: Colors.white,
      onChanged: controller.search,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white38),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white, width: 2),
        ),
        hintText: "Search by name, phone, or email",
        hintStyle: const TextStyle(color: Colors.white54),
        prefixIcon: const Icon(Icons.search, color: Colors.white54),
        filled: true,
        fillColor: const Color(0xFF0A3B5C),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class _FullScreenLoader extends StatelessWidget {
  const _FullScreenLoader();
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF072A40),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              color: Colors.white,
            ),
            SizedBox(height: 12),
            Text(
              "Loading…",
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  const _ConfirmDialog({required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF0A3B5C),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      content: Text(message, style: const TextStyle(color: Colors.white70)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFBF2C2C),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Delete'),
        ),
      ],
    );
  }
}
