import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'total_vendors_controller.dart';
import 'vendor_card_widget.dart';

class TotalVendorsScreen extends StatelessWidget {
  TotalVendorsScreen({super.key});
  final controller = Get.put(TotalVendorsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF072A40),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF0A3B5C),
        title: const Text("All Vendors", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () => controller.fetchAllVendors(),
            icon: const Icon(Icons.refresh, color: Colors.white),
          ),
        ],
      ),
      body: Stack(
        children: [
          Obx(() {
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
                      const SizedBox(height: 10),
                      Obx(() {
                        final total = controller.vendors.length;
                        final filtered = controller.filteredVendors.length;
                        return Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0A3B5C),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: Colors.white24),
                            ),
                            child: Text(
                              "Showing $filtered of $total vendors",
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 12),
                      Expanded(
                        child: Obx(() {
                          final list = controller.filteredVendors;
                          if (list.isEmpty) {
                            return RefreshIndicator(
                              onRefresh: () => controller.fetchAllVendors(),
                              child: ListView(
                                physics:
                                const AlwaysScrollableScrollPhysics(),
                                children: const [
                                  SizedBox(height: 120),
                                  Icon(Icons.store_mall_directory_outlined,
                                      size: 56, color: Colors.white38),
                                  SizedBox(height: 8),
                                  Center(
                                      child: Text("No vendors found",
                                          style: TextStyle(
                                              color: Colors.white70))),
                                ],
                              ),
                            );
                          }
                          return RefreshIndicator(
                            onRefresh: () => controller.fetchAllVendors(),
                            child: GridView.builder(
                              physics:
                              const AlwaysScrollableScrollPhysics(),
                              gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 2.1,
                              ),
                              itemCount: list.length,
                              itemBuilder: (context, index) {
                                final vendor = list[index];
                                return VendorCardWidget(
                                  vendor: vendor,
                                  index: index,
                                  onEdit: () {},
                                  onDeleteConfirmed: () async {
                                    // ✅ Confirmation dialog before delete
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        backgroundColor: const Color(0xFF0A3B5C),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius.circular(16)),
                                        title: const Text(
                                          "Confirm Delete",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        content: const Text(
                                          "Are you sure you want to delete this vendor?",
                                          style: TextStyle(
                                              color: Colors.white70),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(ctx).pop(false),
                                            child: const Text(
                                              "Cancel",
                                              style: TextStyle(
                                                  color: Colors.white70),
                                            ),
                                          ),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                              const Color(0xFFBF2C2C),
                                              foregroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                  BorderRadius.circular(10)),
                                            ),
                                            onPressed: () =>
                                                Navigator.of(ctx).pop(true),
                                            child: const Text("Delete"),
                                          ),
                                        ],
                                      ),
                                    );

                                    if (confirm != true) return;

                                    // ✅ Show deleting overlay
                                    controller.isDeleting.value = true;

                                    final original =
                                    controller.vendors.toList();
                                    controller.vendors.removeWhere(
                                            (v) => v.id == vendor.id);

                                    final success = await controller
                                        .deleteVendorById(vendor.id);

                                    controller.isDeleting.value = false;

                                    if (!success) {
                                      controller.vendors.assignAll(original);
                                      Get.snackbar(
                                          'Error', 'Failed to delete vendor');
                                    } else {
                                      // ✅ Refresh after delete
                                      await controller.fetchAllVendors();
                                      Get.snackbar(
                                        backgroundColor:
                                        const Color(0xFF0A3B5C),
                                        colorText: Colors.white,
                                        'Deleted',
                                        'Vendor and playgrounds deleted successfully',
                                      );
                                    }
                                  },
                                );
                              },
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                );
              },
            );
          }),

          // ✅ Overlay loader for delete
          Obx(() {
            if (controller.isDeleting.value) {
              return const _DeleteOverlayLoader();
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
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
        hintText: "Search by name, phone, email, city or NTN",
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
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 12),
            Text("Loading…", style: TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}

class _DeleteOverlayLoader extends StatelessWidget {
  const _DeleteOverlayLoader();
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 12),
            Text("Deleting…", style: TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}
