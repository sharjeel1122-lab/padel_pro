import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CourtsView extends StatelessWidget {
  const CourtsView({super.key});

  @override
  Widget build(BuildContext context) {
    final club = Get.arguments as Map<String, dynamic>;
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          club['name'],
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, size: 28),
            onPressed: () => _addNewCourt(club['_id']),
            tooltip: 'Add New Court',
          ),
        ],
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Available Courts',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.white70 : Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: club['courts']?.length ?? 0,
                itemBuilder: (context, index) {
                  final court = club['courts'][index];
                  return _buildCourtCard(context, court, club['_id'], isDarkMode);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourtCard(BuildContext context, Map<String, dynamic> court, String playgroundId, bool isDarkMode) {
    final theme = Theme.of(context);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.sports_tennis,
                      size: 28,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Court ${court['courtNumber']}',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getCourtTypeColor(court['courtType'], isDarkMode),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    court['courtType'] ?? 'Standard',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Text(
              'Pricing Options',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ...court['pricing'].map<Widget>((price) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${price['duration']} minutes',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const Spacer(),
                  Text(
                    '\$${price['price']}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            )).toList(),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () => _editCourt(playgroundId, court),
                icon: const Icon(Icons.edit, size: 18),
                label: const Text('Edit Court'),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCourtTypeColor(String? courtType, bool isDarkMode) {
    switch (courtType?.toLowerCase()) {
      case 'indoor':
        return Colors.blue.shade700;
      case 'crystal':
        return Colors.purple.shade600;
      default:
        return isDarkMode ? Colors.grey.shade700 : Colors.grey.shade600;
    }
  }

  void _addNewCourt(String playgroundId) {
    Get.dialog(
      AlertDialog(
        title: const Text('Add New Court'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Court Number',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Court Type',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'Standard', child: Text('Standard')),
                  DropdownMenuItem(value: 'Indoor', child: Text('Indoor')),
                  DropdownMenuItem(value: 'Crystal', child: Text('Crystal')),
                ],
                onChanged: (value) {},
              ),
              const SizedBox(height: 16),
              const Text('Add pricing options here...'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Save logic here
              Get.back();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _editCourt(String playgroundId, Map<String, dynamic> court) {
    Get.dialog(
      AlertDialog(
        title: const Text('Edit Court'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: court['courtNumber'].toString(),
                decoration: const InputDecoration(
                  labelText: 'Court Number',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: court['courtType'] ?? 'Standard',
                decoration: const InputDecoration(
                  labelText: 'Court Type',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'Standard', child: Text('Standard')),
                  DropdownMenuItem(value: 'Indoor', child: Text('Indoor')),
                  DropdownMenuItem(value: 'Crystal', child: Text('Crystal')),
                ],
                onChanged: (value) {},
              ),
              const SizedBox(height: 16),
              ...court['pricing'].map<Widget>((price) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: price['duration'].toString(),
                        decoration: const InputDecoration(
                          labelText: 'Duration (mins)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        initialValue: price['price'].toString(),
                        decoration: const InputDecoration(
                          labelText: 'Price',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
              )).toList(),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {},
                tooltip: 'Add Pricing Option',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Update logic here
              Get.back();
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}