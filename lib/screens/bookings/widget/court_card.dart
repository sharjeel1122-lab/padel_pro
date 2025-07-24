import 'package:flutter/material.dart';

class CourtCard extends StatelessWidget {
  final String title;
  final List<String> features;
  final bool isSelected;
  final VoidCallback onTap;

  const CourtCard({
    super.key,
    required this.title,
    required this.features,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.withOpacity(0.2) : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.blue : Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: features.map((feature) => Text(
                '• $feature',
                style: TextStyle(
                  color: isSelected ? Colors.blue : Colors.grey[700],
                ),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }
}