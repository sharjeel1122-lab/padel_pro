import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class UserClubDetailScreen extends StatelessWidget {
  final Map<String, dynamic> playground;

  const UserClubDetailScreen({super.key, required this.playground});

  @override
  Widget build(BuildContext context) {
    final courts = playground['courts'] ?? [];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            iconTheme: IconThemeData(color: Colors.white),
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                playground['image'] ?? 'https://www.shutterstock.com/image-illustration/indoor-padel-paddle-tennis-court-260nw-2486054935.jpg',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.image, size: 50, color: Colors.grey),
                ),
              ),

            ),
            actions: [
              IconButton(icon: const Icon(Icons.share), onPressed: () {}),
              IconButton(
                icon: Icon(
                  playground['isFavorite'] ?? false
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: playground['isFavorite'] ?? false
                      ? Colors.red
                      : Colors.white,
                ),
                onPressed: () {},
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    playground['name'] ?? 'Playground Name',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(LucideIcons.mapPin, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          playground['location'] ?? 'Playground Location',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildInfoChip(
                        icon: Icons.star,
                        value: playground['rating']?.toString() ?? '4.5',
                        label: 'Rating',
                      ),
                      const SizedBox(width: 8),
                      _buildInfoChip(
                        icon: LucideIcons.layoutPanelTop,
                        value: courts.length.toString(),
                        label: 'Courts',
                      ),
                      const SizedBox(width: 8),
                      _buildInfoChip(
                        icon: Icons.money,
                        value: '\Rs.${playground['minPrice'] ?? '15'}',
                        label: 'From',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Description',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    playground['description'] ?? 'No description available',
                    style: const TextStyle(color: Colors.black87),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Available Courts',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final court = courts[index];
              return _buildCourtCard(court);
            }, childCount: courts.length),
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0C1E2C),
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Book Now',
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: const Color(0xFF0C1E2C)),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF0C1E2C),
              ),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourtCard(Map<String, dynamic> court) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            court['name'] ?? 'Court Name',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildCourtFeature(
                Icons.square_foot,
                '${court['size'] ?? '20x10'} m',
              ),
              const SizedBox(width: 16),
              _buildCourtFeature(
                Icons.construction,
                court['surface'] ?? 'Synthetic',
              ),
              const SizedBox(width: 16),
              _buildCourtFeature(
                Icons.people,
                '${court['players'] ?? '4'} players',
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Available Time Slots',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['09:00', '11:00', '13:00', '15:00', '17:00', '19:00']
                .map((time) {
                  return Chip(
                    label: Text(time),
                    backgroundColor: Colors.green[50],
                    labelStyle: const TextStyle(color: Colors.green),
                  );
                })
                .toList(),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '\$${court['price'] ?? '15'}/hour',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0C1E2C),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourtFeature(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}
