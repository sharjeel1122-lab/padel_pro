// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:padel_pro/screens/vendor/tournament/tournament_create_screen.dart';

class Tournament {
  final String id;
  final String name;
  final String description;
  final DateTime startDate;
  final String location;
  final String status; // upcoming, ongoing, completed
  final int participants;
  final String type; // Men's, Women's, Mixed

  Tournament({
    required this.id,
    required this.name,
    required this.description,
    required this.startDate,
    required this.location,
    required this.status,
    required this.participants,
    required this.type,
  });
}

class TournamentController extends GetxController {
  final tournaments = <Tournament>[].obs;

  @override
  void onInit() {
    super.onInit();
    // Mock data - replace with API call
    tournaments.assignAll([
      Tournament(
        id: '1',
        name: 'Summer Padel Championship',
        description: 'Annual summer tournament for all skill levels',
        startDate: DateTime.now().add(const Duration(days: 7)),
        location: 'Padel Club, Lahore',
        status: 'upcoming',
        participants: 32,
        type: 'Men\'s',
      ),
      Tournament(
        id: '2',
        name: 'Winter Padel League',
        description: 'Competitive league matches throughout winter',
        startDate: DateTime.now().add(const Duration(days: 30)),
        location: 'Sports Complex, Islamabad',
        status: 'upcoming',
        participants: 24,
        type: 'Mixed',
      ),
      Tournament(
        id: '3',
        name: 'Spring Padel Open',
        description: 'Open tournament for beginners and intermediates',
        startDate: DateTime.now().subtract(const Duration(days: 10)),
        location: 'Padel Arena, Karachi',
        status: 'completed',
        participants: 48,
        type: 'Women\'s',
      ),
    ]);
  }

  void editTournament(String id) {
    // Navigate to edit screen
    Get.toNamed('/edit-tournament/$id');
  }

  void deleteTournament(String id) {
    tournaments.removeWhere((tournament) => tournament.id == id);
    Get.snackbar('Success', 'Tournament deleted',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white);
  }
}

class ViewTournamentsScreen extends StatelessWidget {
  final controller = Get.put(TournamentController());

  ViewTournamentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C1E2C),
      appBar: AppBar(
        title: const Text('My Tournaments', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF0C1E2C),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Get.to(CreateTournamentScreen()),
            tooltip: 'Create New Tournament',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Obx(() {
          if (controller.tournaments.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.tour, size: 50, color: Colors.white70),
                  const SizedBox(height: 20),
                  const Text(
                    'No Tournaments Yet',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Create your first tournament to get started',
                    style: TextStyle(color: Colors.white.withOpacity(0.7)),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Get.to(CreateTournamentScreen()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                    ),
                    child: const Text('Create Tournament'),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            itemCount: controller.tournaments.length,
            itemBuilder: (context, index) {
              final tournament = controller.tournaments[index];
              return _buildTournamentCard(tournament);
            },
          );
        }),
      ),
    );
  }

  Widget _buildTournamentCard(Tournament tournament) {
    final isUpcoming = tournament.status == 'upcoming';
    final isCompleted = tournament.status == 'completed';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E3354),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        tournament.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: isUpcoming
                            ? Colors.blue.withOpacity(0.2)
                            : isCompleted
                            ? Colors.green.withOpacity(0.2)
                            : Colors.orange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        tournament.status.toUpperCase(),
                        style: TextStyle(
                          color: isUpcoming
                              ? Colors.white
                              : isCompleted
                              ? Colors.greenAccent
                              : Colors.orangeAccent,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  tournament.description,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    const Icon(Icons.category, size: 16, color: Colors.white70),
                    const SizedBox(width: 5),
                    Text(
                      tournament.type,
                      style: TextStyle(color: Colors.white.withOpacity(0.8)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.white70),
                    const SizedBox(width: 5),
                    Text(
                      tournament.location,
                      style: TextStyle(color: Colors.white.withOpacity(0.8)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16, color: Colors.white70),
                    const SizedBox(width: 5),
                    Text(
                      DateFormat('MMM dd, yyyy - hh:mm a').format(tournament.startDate),
                      style: TextStyle(color: Colors.white.withOpacity(0.8)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.people, size: 16, color: Colors.white70),
                    const SizedBox(width: 5),
                    Text(
                      '${tournament.participants} participants',
                      style: TextStyle(color: Colors.white.withOpacity(0.8)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (isUpcoming) _buildCardFooter(tournament.id),
        ],
      ),
    );
  }

  Widget _buildCardFooter(String tournamentId) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(15),
          bottomRight: Radius.circular(15),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          TextButton(
            onPressed: () => controller.editTournament(tournamentId),
            style: TextButton.styleFrom(
              foregroundColor: Colors.blueAccent,
              padding: const EdgeInsets.symmetric(horizontal: 15),
            ),
            child: const Row(
              children: [
                Icon(Icons.image_outlined, size: 18,color: Colors.white,),
                SizedBox(width: 5),
                Text('View Post',style: TextStyle(color:Colors.white),),
              ],
            ),
          ),

          Expanded(child: Row(    mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => controller.editTournament(tournamentId),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.edit, size: 18,color: Colors.white,),
                    SizedBox(width: 5),
                    Text('Edit',style: TextStyle(color:Colors.white),),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              TextButton(
                onPressed: () => controller.deleteTournament(tournamentId),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.delete, size: 18),
                    SizedBox(width: 5),
                    Text('Delete'),
                  ],
                ),
              ),
            ],
          ))

        ],
      ),
    );
  }
}