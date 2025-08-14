// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:padel_pro/screens/vendor/vendor%20data%20controller/vendor_bookings_controller.dart';
import 'package:padel_pro/services/vendors%20api/vendor_booking_api.dart';

const primaryColors = Color(0xFF0C1E2C);

class VendorBookingsScreen extends StatelessWidget {
  const VendorBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(
      VendorBookingsController(api: VendorBookingApi()),
      permanent: false,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: primaryColors,
        elevation: 0,
        title: const Text('Bookings', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          _TopBar(ctrl: ctrl),
          Expanded(
            child: Obx(() {
              if (ctrl.isLoading.value) {
                return const _LoadingList();
              }
              if (ctrl.errorText.value != null) {
                return _ErrorState(
                  message: ctrl.errorText.value!,
                  onRetry: ctrl.fetch,
                );
              }
              final list = ctrl.filtered;
              if (list.isEmpty) {
                return const _EmptyState();
              }

              return RefreshIndicator(
                onRefresh: ctrl.refreshNow,
                color: primaryColors,
                child: LayoutBuilder(
                  builder: (context, c) {
                    final w = c.maxWidth;
                    // responsive: grid on wide screens
                    if (w >= 900) {
                      final cross = (w ~/ 380).clamp(2, 4);
                      return GridView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: cross,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 1.25,
                        ),
                        itemCount: list.length,
                        itemBuilder: (_, i) => _BookingCard(item: list[i]),
                      );
                    }
                    // list on phones/tablets
                    return ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
                      itemCount: list.length,
                      itemBuilder: (_, i) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: _BookingCard(item: list[i]),
                      ),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.ctrl});
  final VendorBookingsController ctrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: primaryColors,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
      child: Column(
        children: [
          // Search
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: TextField(
              onChanged: ctrl.setSearch,
              decoration: const InputDecoration(
                hintText: 'Search by player, phone, court, playground…',
                prefixIcon: Icon(Icons.search, color: primaryColors),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Filters
          Obx(() {
            final current = ctrl.filter.value;
            ChoiceChip _chip(String label, BookingFilter f, IconData icon) {
              final selected = current == f;
              return ChoiceChip(

                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon,
                      size: 16,
                      color: selected ? Colors.white : primaryColors,
                    ),
                    const SizedBox(width: 6),
                    Text(label),
                  ],
                ),
                selected: selected,
                onSelected: (_) => ctrl.setFilter(f),
                selectedColor: Color(0xFF0C1E2C),
                labelStyle: TextStyle(
                  color: selected ? Colors.white : Color(0xFF0C1E2C),
                  fontWeight: FontWeight.w600,
                ),
                backgroundColor: Colors.white.withOpacity(0.08),
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.white.withOpacity(0.25)),
                  borderRadius: BorderRadius.circular(10),
                ),
              );
            }

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _chip('All', BookingFilter.all, LucideIcons.listChecks),
                  const SizedBox(width: 8),
                  _chip('Today', BookingFilter.today, LucideIcons.sun),
                  const SizedBox(width: 8),
                  _chip(
                    'Upcoming',
                    BookingFilter.upcoming,
                    LucideIcons.calendarDays,
                  ),
                  const SizedBox(width: 8),
                  _chip('Past', BookingFilter.past, LucideIcons.history),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({required this.item});
  final BookingItem item;

  String _fmt2(int v) => v < 10 ? '0$v' : '$v';

  @override
  Widget build(BuildContext context) {
    final date = DateTime.tryParse(item.date);
    final datePretty = date == null
        ? item.date
        : '${_fmt2(date.day)}/${_fmt2(date.month)}/${date.year}';

    final title = item.userFullName;
    final subtitle = item.playgroundName;
    final price = item.totalPrice == null ? '—' : 'Rs. ${item.totalPrice}';

    // Avatar initials
    final initials = title.trim().isEmpty
        ? 'U'
        : title.trim().split(RegExp(r'\s+')).map((e) => e[0]).take(2).join();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            // could push a detail screen later
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Player + Court badge + Price
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: primaryColors.withOpacity(0.12),
                      foregroundColor: primaryColors,
                      child: Text(
                        initials,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: primaryColors,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: primaryColors.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(LucideIcons.hash, size: 14, color: primaryColors),
                          const SizedBox(width: 6),
                          Text(
                            'Court ${item.courtNumber}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: primaryColors,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      price,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Info row
                Row(
                  children: [
                    _pill(icon: LucideIcons.calendar, label: datePretty),
                    const SizedBox(width: 8),
                    _pill(icon: LucideIcons.clock, label: item.startTime),
                    const SizedBox(width: 8),
                    _pill(
                      icon: LucideIcons.timer,
                      label: '${item.duration} min',
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Secondary info
                Row(
                  children: [
                    const Icon(LucideIcons.mapPin, size: 16, color: primaryColors),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        item.playgroundLocation.isEmpty
                            ? '—'
                            : item.playgroundLocation,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Player stats
                Row(
                  children: [
                    const Icon(LucideIcons.phone, size: 16, color: primaryColors),
                    const SizedBox(width: 6),
                    Text(
                      item.userPhone.isEmpty ? '—' : item.userPhone,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black87,
                      ),
                    ),
                    const Spacer(),
                    if (item.userAvgRating != null)
                      Row(
                        children: [
                          const Icon(Icons.star, size: 16, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            '${item.userAvgRating}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    if (item.userSkillLevel != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: primaryColors.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item.userSkillLevel!,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: primaryColors,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _pill({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: primaryColors.withOpacity(0.06),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: primaryColors),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: primaryColors,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingList extends StatelessWidget {
  const _LoadingList();

  @override
  Widget build(BuildContext context) {
    Widget shimmerBox({double h = 80}) => Container(
      height: h,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
    );

    return ListView.builder(
      itemCount: 6,
      padding: const EdgeInsets.only(top: 12),
      itemBuilder: (_, __) => shimmerBox(h: 110),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(LucideIcons.clipboardList, size: 56, color: primaryColors),
            SizedBox(height: 12),
            Text('No bookings yet',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            SizedBox(height: 6),
            Text(
              'New bookings will appear here as soon as players reserve your courts.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}


class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.alertTriangle, size: 56, color: Colors.red),
            const SizedBox(height: 12),
            const Text(
              'Failed to load',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(LucideIcons.refreshCcw),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColors,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
