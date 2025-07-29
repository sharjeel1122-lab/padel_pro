import 'package:flutter/material.dart';

class CourtListView extends StatelessWidget {
  final List<dynamic> courts;

  const CourtListView({super.key, required this.courts});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Courts")),
      body: ListView.builder(
        itemCount: courts.length,
        itemBuilder: (context, index) {
          final court = courts[index];
          return ListTile(
            leading: const Icon(Icons.sports_tennis),
            title: Text(court['name'] ?? 'Unnamed Court'),
            subtitle: Text("Price: ${court['price']}"),
          );
        },
      ),
    );
  }
}
