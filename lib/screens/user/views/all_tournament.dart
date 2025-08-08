import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:padel_pro/screens/user/user_controller/all_tournament_controller.dart';

import 'package:pull_to_refresh/pull_to_refresh.dart';


class AllTournamentsScreen extends StatelessWidget {
  final controller = Get.put(AllTournamentController());
  final RefreshController _refreshController = RefreshController();
  final Color primaryColor = Colors.white;
  // final Color primaryColor = const Color(0xFF0C1E2C);
  final Color cardColor = const Color(0xFF1E3354);
  final Color accentColor = const Color(0xFF4A80F0);

  Future<void> _onRefresh() async {
    try {
      await controller.fetchAllTournaments();
      _refreshController.refreshCompleted();
    } catch (e) {
      _refreshController.refreshFailed();
      Get.snackbar(
        'Error',
        'Failed to refresh tournaments',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('All Tournaments', style: TextStyle(color: Colors.white)),
        backgroundColor:  Color(0xFF1E3354),
        elevation: 0,
        centerTitle: true,
        actions: [
          // IconButton(
          //   icon: const Icon(Icons.add, color: Colors.white),
          //   onPressed: () {
          //     Get.to(() => CreateTournamentScreen());
          //   },
          // ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.tournaments.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF1E3354),
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1E3354)),
            ),
          );
        }

        return SmartRefresher(
          controller: _refreshController,
          onRefresh: _onRefresh,
          enablePullDown: true,
          enablePullUp: false,
          header: WaterDropMaterialHeader(
            backgroundColor: accentColor,
            color: Colors.white,
          ),
          child: controller.tournaments.isEmpty
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.emoji_events, size: 60, color: Colors.white.withOpacity(0.5)),
                const SizedBox(height: 16),
                Text(
                  'No tournaments found',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),

              ],
            ),
          )
              : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.tournaments.length,
            itemBuilder: (context, index) {
              final tournament = controller.tournaments[index];
              final startDate = tournament['startDate'] ?? '';
              final startTime = tournament['startTime'] ?? '';

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Material(
                    color: cardColor,
                    child: InkWell(
                      onTap: () {
                        // Handle tournament tap
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Hero(
                              tag: 'tournament-image-$index',
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: primaryColor.withOpacity(0.3),
                                ),
                                child: tournament['coverPhoto'] != null
                                    ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    tournament['coverPhoto'],
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Center(
                                      child: Icon(
                                        Icons.emoji_events,
                                        size: 40,
                                        color: Colors.white.withOpacity(0.5),
                                      ),
                                    ),
                                  ),
                                )
                                    : Center(
                                  child: Icon(
                                    Icons.emoji_events,
                                    size: 40,
                                    color: Colors.white.withOpacity(0.5),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    tournament['name'] ?? 'Untitled Tournament',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  _buildInfoRow(Icons.location_on, tournament['location'] ?? 'No location'),
                                  const SizedBox(height: 4),
                                  _buildInfoRow(Icons.calendar_today, '$startDate at $startTime'),
                                  const SizedBox(height: 4),
                                  _buildInfoRow(Icons.category, tournament['tournamentType'] ?? 'No type specified'),
                                  if (tournament['status'] != null) ...[
                                    const SizedBox(height: 4),
                                    _buildStatusIndicator(tournament['status']),
                                  ],
                                ],
                              ),
                            ),
                            Icon(
                              Icons.chevron_right,
                              color: Colors.white.withOpacity(0.5),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.white.withOpacity(0.7)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusIndicator(String status) {
    Color statusColor;
    switch (status.toLowerCase()) {
      case 'active':
        statusColor = Colors.green;
        break;
      case 'upcoming':
        statusColor = Colors.orange;
        break;
      case 'completed':
        statusColor = Colors.blue;
        break;
      case 'cancelled':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: statusColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          status.toUpperCase(),
          style: TextStyle(
            color: statusColor,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}