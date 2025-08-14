import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:padel_pro/screens/user/user_controller/user_fetch_booking_controller.dart';
import 'package:padel_pro/screens/user/views/edit_booking_sheet.dart';

class UserBookingsScreen extends StatelessWidget {
  const UserBookingsScreen({super.key});

  Color get kBrand => const Color(0xFF0C1E2C);

  @override
  Widget build(BuildContext context) {
    final c = Get.put(UserBookingController());

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: kBrand,
        foregroundColor: Colors.white,
        title: const Text('My Bookings'),
      ),
      body: Obx(() {
        if (c.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (c.bookings.isEmpty) {
          return _EmptyState(brand: kBrand);
        }

        return RefreshIndicator(
          color: kBrand,
          onRefresh: () => c.fetch(), // manual pull-to-refresh (silent)
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemBuilder: (_, i) {
              final b = c.bookings[i];
              return _BookingCard(
                brand: kBrand,
                title: b.playgroundName,
                subtitle: b.playgroundLocation,
                date: b.date,
                time: b.startTime,
                court: b.courtNumber,
                duration: '${b.duration} min',
                price: b.totalPrice == null ? null : 'Rs. ${b.totalPrice}',
                onEdit: () {
                  c.startEdit(b);
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => EditBookingSheet(controller: c),
                  );
                },
              );
            },
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemCount: c.bookings.length,
          ),
        );
      }),
    );
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({
    required this.brand,
    required this.title,
    required this.subtitle,
    required this.date,
    required this.time,
    required this.court,
    required this.duration,
    required this.onEdit,
    this.price,
  });

  final Color brand;
  final String title;
  final String subtitle;
  final String date;
  final String time;
  final String court;
  final String duration;
  final String? price;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(.06), blurRadius: 10, spreadRadius: 2)],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // top line
            Row(
              children: [
                Icon(LucideIcons.trophy, color: brand),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(title,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                ),
                // If you want an inline edit button, uncomment:
                // IconButton(
                //   onPressed: onEdit,
                //   icon: Icon(LucideIcons.pencil, color: brand),
                //   tooltip: 'Edit',
                // ),
              ],
            ),
            if (subtitle.trim().isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(subtitle, style: const TextStyle(color: Colors.black54)),
            ],
            const SizedBox(height: 12),

            // info row
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _chip(icon: LucideIcons.calendar, label: date),
                _chip(icon: LucideIcons.clock, label: time),
                _chip(icon: LucideIcons.doorOpen, label: 'Court $court'),
                _chip(icon: LucideIcons.timer, label: duration),
                if (price != null) _chip(icon: LucideIcons.badgeDollarSign, label: price!),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: brand.withOpacity(.06),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: brand),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: brand, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.brand});
  final Color brand;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.bookOpen, size: 64, color: brand),
            const SizedBox(height: 10),
            const Text('No bookings yet',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
            const SizedBox(height: 6),
            const Text('When you book a court, it will appear here.',
                textAlign: TextAlign.center, style: TextStyle(color: Colors.black54)),
          ],
        ),
      ),
    );
  }
}
