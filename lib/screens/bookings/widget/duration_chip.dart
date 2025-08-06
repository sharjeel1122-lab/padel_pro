// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class DurationChip extends StatelessWidget {
  final String duration;
  final bool selected;
  final VoidCallback onSelected;

  const DurationChip({
    super.key,
    required this.duration,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(duration),
      selected: selected,
      onSelected: (_) => onSelected(),
      selectedColor: Colors.blue.withOpacity(0.2),
      labelStyle: TextStyle(
        color: selected ? Colors.blue : Colors.black,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: selected ? Colors.blue : Colors.grey,
        ),
      ),
    );
  }
}