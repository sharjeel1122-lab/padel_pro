import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:padel_pro/screens/admin/custom_admin_widgets/user_card_widget.dart';
import 'package:padel_pro/screens/admin/total users/total_users_controller.dart';

class TotalUsersScreen extends StatelessWidget {
  TotalUsersScreen({super.key});
  final controller = Get.put(TotalUsersController());

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 700;

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
                      crossAxisCount: isWide ? 2 : 1,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 2.1,
                    ),
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final user = list[index];
                      return UserCardWidget(
                        user: user,
                        onDeleteConfirmed: () {
                          // controller.deleteUser(index)
                        },
                      );
                    },
                  );
                }),
              ),
            ],
          ),
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
