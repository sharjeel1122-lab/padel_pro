import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SearchResultScreen extends StatelessWidget {
  final String query;

  const SearchResultScreen({super.key, required this.query});

  @override
  Widget build(BuildContext context) {
    // Replace this list with your actual recent venues
    final recentVenues = [
      "Ali Sports Ground",
      "Elite Arena",
      "Lahore Court",
      "Islamabad Padel Hub",
    ];

    final filtered = recentVenues
        .where((venue) => venue.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFF072A40),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A3B5C),
        title: Text("Search: \"$query\"",
            style: GoogleFonts.poppins(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: filtered.isEmpty
            ? Center(
          child: Text("No venues found.",
              style: GoogleFonts.poppins(color: Colors.white70)),
        )
            : ListView.separated(
          itemCount: filtered.length,
          separatorBuilder: (_, __) => const Divider(color: Colors.white30),
          itemBuilder: (_, index) {
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0A3B5C),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                filtered[index],
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
