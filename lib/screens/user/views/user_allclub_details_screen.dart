// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:confetti/confetti.dart';


class UserClubDetailScreen extends StatefulWidget {
  final Map<String, dynamic> playground;

  const UserClubDetailScreen({super.key, required this.playground});

  @override
  State<UserClubDetailScreen> createState() => _UserClubDetailScreenState();
}

class _UserClubDetailScreenState extends State<UserClubDetailScreen> {
  late ConfettiController _confettiController;

  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 1),
    );
    _isFavorite = widget.playground['isFavorite'] ?? false;
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final courts = widget.playground['courts'] as List? ?? [];
    Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                iconTheme: const IconThemeData(color: Colors.white),
                expandedHeight: size.height * 0.3,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        widget.playground['image']?.toString() ??
                            'https://images.unsplash.com/photo-1595526114035-0c45a16a0d79',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: const Color(0xFF0C1E2C),
                          child: const Icon(
                            Icons.image,
                            size: 50,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              const Color(0xFF0C1E2C).withOpacity(0.7),
                              Colors.transparent,
                              const Color(0xFF0C1E2C).withOpacity(0.1),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.share, color: Colors.white),
                    onPressed: _sharePlayground,
                  ),
                  IconButton(
                    icon: Icon(
                      _isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: _isFavorite ? Colors.red : Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        _isFavorite = !_isFavorite;
                        if (_isFavorite) _confettiController.play();
                      });
                    },
                  ),
                ],
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              widget.playground['name']?.toString() ??
                                  'Padel Club',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0C1E2C),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0C1E2C).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.star,
                                  size: 16,
                                  color: Colors.amber,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  widget.playground['rating']?.toString() ??
                                      '4.5',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      Row(
                        children: [
                          const Icon(
                            LucideIcons.mapPin,
                            size: 16,
                            color: Color(0xFF0C1E2C),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              widget.playground['location']?.toString() ??
                                  'Location not specified',
                              style: const TextStyle(color: Color(0xFF0C1E2C)),
                            ),
                          ),
                          const Icon(
                            Icons.directions,
                            size: 20,
                            color: Color(0xFF0C1E2C),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      Row(
                        children: [
                          const Icon(
                            LucideIcons.clock,
                            size: 16,
                            color: Color(0xFF0C1E2C),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${widget.playground['openingTime']?.toString() ?? '08:00'} - ${widget.playground['closingTime']?.toString() ?? '22:00'}',
                            style: const TextStyle(color: Color(0xFF0C1E2C)),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      const Text(
                        'About',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0C1E2C),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.playground['description']?.toString() ??
                            'No description available',
                        style: const TextStyle(color: Colors.black87),
                      ),

                      const SizedBox(height: 20),

                      const Text(
                        'Facilities',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0C1E2C),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children:
                            (widget.playground['facilities'] as List? ?? [])
                                .map(
                                  (facility) => Chip(
                                    label: Text(facility.toString()),
                                    backgroundColor: const Color(
                                      0xFF0C1E2C,
                                    ).withOpacity(0.1),
                                    labelStyle: const TextStyle(
                                      color: Color(0xFF0C1E2C),
                                    ),
                                  ),
                                )
                                .toList(),
                      ),

                      const SizedBox(height: 24),

                      const Text(
                        'Available Courts',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0C1E2C),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),

              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    child: _buildCourtCard(courts[index]),
                  ),
                  childCount: courts.length,
                ),
              ),
              const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
            ],
          ),

          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Color(0xFF0C1E2C),
                Colors.blue,
                Colors.green,
                Colors.orange,
              ],
            ),
          ),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () => _showBookingOptions(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0C1E2C),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Book Now'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourtCard(Map<String, dynamic> court) {
    final peakHours = court['peakHours'] as List? ?? [];
    final pricing = court['pricing'] as List? ?? [];
    final courtTypes = court['courtType'] as List? ?? [];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF0C1E2C).withOpacity(0.05),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Text(
                  'Court ${court['courtName']?.toString() ?? '1'}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0C1E2C),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0C1E2C).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    courtTypes.isNotEmpty
                        ? courtTypes.first.toString()
                        : 'Standard',
                    style: const TextStyle(color: Color(0xFF0C1E2C)),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Standard Pricing',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0C1E2C),
                  ),
                ),
                const SizedBox(height: 8),
                if (pricing.isEmpty)
                  const Text(
                    'No pricing available',
                    style: TextStyle(color: Colors.grey),
                  )
                else
                  Column(
                    children: pricing.map<Widget>((price) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Container(
                              width: 80,
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0C1E2C).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Center(
                                child: Text(
                                  '${price['duration']?.toString() ?? '0'} min',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0C1E2C),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Rs. ${price['price']?.toString() ?? '0'}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),

                const SizedBox(height: 16),

                const Text(
                  'Peak Hours',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0C1E2C),
                  ),
                ),
                const SizedBox(height: 8),
                if (peakHours.isEmpty)
                  const Text(
                    'No peak hours defined',
                    style: TextStyle(color: Colors.grey),
                  )
                else
                  Column(
                    children: peakHours.map<Widget>((peak) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Container(
                              width: 120,
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Center(
                                child: Text(
                                  '${peak['startTime']?.toString() ?? ''} - ${peak['endTime']?.toString() ?? ''}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Rs. ${peak['price']?.toString() ?? '0'}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),

                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _showBookingDialog(court),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0C1E2C),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Book This Court',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sharePlayground() {
    // Implement share functionality
  }

  void _showBookingOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select a Court to Book',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0C1E2C),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: (widget.playground['courts'] as List).length,
                  itemBuilder: (context, index) {
                    final court = widget.playground['courts'][index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildCourtCard(court),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showBookingDialog(Map<String, dynamic> court) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Book Court ${court['courtName']?.toString() ?? ''}',
          style: const TextStyle(color: Color(0xFF0C1E2C)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select booking duration:'),
            const SizedBox(height: 16),
            ...(court['pricing'] as List).map<Widget>((price) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(
                    '${price['duration']?.toString() ?? '0'} minutes',
                  ),
                  trailing: Text('Rs. ${price['price']?.toString() ?? '0'}'),
                  tileColor: const Color(0xFF0C1E2C).withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _showBookingConfirmation(court, price);
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showBookingConfirmation(
    Map<String, dynamic> court,
    Map<String, dynamic> price,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, size: 60, color: Colors.green),
            const SizedBox(height: 20),
            Text(
              'Court ${court['courtName']?.toString() ?? ''} Booked!',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              '${price['duration']?.toString() ?? '0'} minutes for Rs. ${price['price']?.toString() ?? '0'}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0C1E2C),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }
}
