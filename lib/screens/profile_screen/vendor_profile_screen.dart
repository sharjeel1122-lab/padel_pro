// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:padel_pro/screens/profile_screen/controller/profile_controller.dart';
import 'package:lucide_icons/lucide_icons.dart';

class VendorProfileScreen extends StatelessWidget {
  final ProfileController _controller = Get.put(ProfileController());
  final Color primaryColor = const Color(0xFF0C1E2C);
  final Color secondaryColor = const Color(0xFF1A3A53);
  final Color accentColor = const Color(0xFF4CAF50);

  VendorProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Obx(() {
        if (_controller.isLoading.value) {
          return _buildLoadingScreen();
        }

        if (_controller.errorMessage.value.isNotEmpty) {
          return _buildErrorScreen();
        }

        return CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 220,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'My Profile',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                centerTitle: true,
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        primaryColor,
                        secondaryColor,
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.white),
                  onPressed: _navigateToEditProfile,
                  tooltip: 'Edit Profile',
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildProfileHeader(),
                    const SizedBox(height: 24),
                    _buildProfileCompletionCard(),
                    const SizedBox(height: 24),
                    _buildProfileDetailsSection(),
                    if (_controller.isVendor) ...[
                      const SizedBox(height: 16),
                      _buildVendorDetailsSection(),
                    ],
                    const SizedBox(height: 24),
                    // _buildActionButtons(),
                    const SizedBox(height: 16),
                    _buildLogoutButton(),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
          ),
          const SizedBox(height: 20),
          Text(
            'Loading Profile...',
            style: TextStyle(
              fontSize: 16,
              color: primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 60,
              color: Colors.red[400],
            ),
            const SizedBox(height: 20),
            Text(
              _controller.errorMessage.value,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _controller.fetchProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: const Text(
                'Try Again',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Container(
          height: 220,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const SizedBox(height: 60),
              Text(
                _controller.fullName,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _controller.profileData['email'] ?? '',
                style: TextStyle(
                  fontSize: 14,
                  color: primaryColor.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: _controller.isVendor ? accentColor : primaryColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _controller.profileData['role']?.toString().toUpperCase() ?? 'USER',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 10,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 4,
              ),
              boxShadow: [

                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 48,
              backgroundColor: Colors.grey[200],
              backgroundImage: _controller.profileData['photo'] != null &&
                  _controller.profileData['photo'].toString().isNotEmpty
                  ? NetworkImage(_controller.profileData['photo'])
                  : const AssetImage('assets/default_profile.png') as ImageProvider,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileCompletionCard() {
    final completionPercentage = _calculateProfileCompletion();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Profile Completion',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              Text(
                '${completionPercentage.round()}%',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _getCompletionColor(completionPercentage),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              LayoutBuilder(
                builder: (context, constraints) {
                  return Container(
                    height: 8,
                    width: constraints.maxWidth * (completionPercentage / 100),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _getCompletionColor(completionPercentage),
                          _getCompletionColor(completionPercentage).withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _getCompletionMessage(completionPercentage),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 12),
          child: Text(
            'Personal Information',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
        ),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: [
                _buildDetailTile(
                  icon: LucideIcons.phone,
                  title: 'Phone',
                  value: _controller.profileData['phone'] ?? 'Not provided',
                  isVerified: true,
                ),
                const Divider(height: 1, indent: 16),
                _buildDetailTile(
                  icon: LucideIcons.mapPin,
                  title: 'City',
                  value: _controller.profileData['city'] ?? 'Not provided',
                ),
                const Divider(height: 1, indent: 16),
                _buildDetailTile(
                  icon: LucideIcons.mail,
                  title: 'Email Verification',
                  value: _controller.profileData['isEmailVerified'] == true ? 'Verified' : 'Not Verified',
                  isVerified: _controller.profileData['isEmailVerified'] == true,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVendorDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 12),
          child: Text(
            'Vendor Information',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
        ),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: [
                _buildDetailTile(
                  icon: LucideIcons.creditCard,
                  title: 'CNIC',
                  value: _controller.profileData['cnic'] ?? 'Not provided',
                ),
                const Divider(height: 1, indent: 16),
                _buildDetailTile(
                  icon: LucideIcons.building2,
                  title: 'NTN',
                  value: _controller.profileData['ntn'] ?? 'Not provided',
                ),
                const Divider(height: 1, indent: 16),
                _buildDetailTile(
                  icon: LucideIcons.shield,
                  title: 'Status',
                  value: _controller.profileData['status']?.toString().toUpperCase() ?? 'UNKNOWN',
                  status: _controller.profileData['status'],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailTile({
    required IconData icon,
    required String title,
    required String value,
    bool isVerified = false,
    String? status,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: primaryColor, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
        ),
      ),
      subtitle: Text(
        value,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: primaryColor,
        ),
      ),
      trailing: status != null
          ? Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: _getStatusColor(status),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          status.toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      )
          : isVerified
          ? Icon(
        Icons.verified,
        color: accentColor,
        size: 24,
      )
          : null,
    );
  }

  // Widget _buildActionButtons() {
  //   return Row(
  //     children: [
  //       Expanded(
  //         child: _buildActionButton(
  //           icon: LucideIcons.calendar,
  //           label: 'Current Bookings',
  //           color: primaryColor,
  //           textColor: Colors.white,
  //           onPressed: () {},
  //         ),
  //       ),
  //       const SizedBox(width: 12),
  //       Expanded(
  //         child: _buildActionButton(
  //           icon: LucideIcons.history,
  //           label: 'History',
  //           color: Colors.white,
  //           textColor: primaryColor,
  //           onPressed: () {},
  //         ),
  //       ),
  //     ],
  //   );
  // }


  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red,
          side: BorderSide(color: Colors.red.withOpacity(0.3)),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () {
          // Handle logout
        },
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.logOut, size: 20),
            SizedBox(width: 8),
            Text(
              'Logout',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _calculateProfileCompletion() {
    int filledFields = 0;
    int totalFields = 6;

    if (_controller.profileData['firstName']?.isNotEmpty ?? false) filledFields++;
    if (_controller.profileData['lastName']?.isNotEmpty ?? false) filledFields++;
    if (_controller.profileData['email']?.isNotEmpty ?? false) filledFields++;
    if (_controller.profileData['phone']?.isNotEmpty ?? false) filledFields++;
    if (_controller.profileData['city']?.isNotEmpty ?? false) filledFields++;
    if (_controller.profileData['photo']?.isNotEmpty ?? false) filledFields++;

    return (filledFields / totalFields) * 100;
  }

  Color _getCompletionColor(double percentage) {
    if (percentage >= 80) return accentColor;
    if (percentage >= 50) return Colors.orange;
    return Colors.red;
  }

  String _getCompletionMessage(double percentage) {
    if (percentage >= 80) return 'Great! Your profile is almost complete';
    if (percentage >= 50) return 'Good, but you can add more details';
    return 'Please complete your profile for better experience';
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'approved':
        return accentColor;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _navigateToEditProfile() {
    // Implement navigation to edit profile screen
  }
}