import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:padel_pro/screens/profile_screen/controller/profile_controller.dart';

class ProfileScreen extends StatelessWidget {
  final ProfileController _controller = Get.put(ProfileController());
  final Color primaryColor = const Color(0xFF0C1E2C);
  final Color backgroundColor = Colors.white;

  ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('My Profile',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () => _navigateToEditProfile(),
            tooltip: 'Edit Profile',
          ),
        ],
      ),
      body: Obx(() {
        if (_controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
            ),
          );
        }

        if (_controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(_controller.errorMessage.value,
                    style: TextStyle(color: primaryColor)),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _controller.fetchProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Retry', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildProfileHeader(),
              const SizedBox(height: 24),
              _buildProfileCompletionBar(),
              const SizedBox(height: 32),
              _buildProfileDetailsCard(),
              if (_controller.isVendor) ...[
                const SizedBox(height: 16),
                _buildVendorDetailsCard(),
              ],
              const SizedBox(height: 24),
              _buildLogoutButton(),
              const SizedBox(height: 16),
              _buildActionButtons(),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildProfileHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Profile Image
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: primaryColor.withOpacity(0.2), width: 3),
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
        const SizedBox(width: 16),
        // Profile Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              Chip(
                label: Text(
                  _controller.profileData['role']?.toString().toUpperCase() ?? 'USER',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                backgroundColor: _controller.isVendor
                    ? Colors.deepOrange
                    : primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileCompletionBar() {
    final completionPercentage = _calculateProfileCompletion();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Profile Completion',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            Text(
              '${completionPercentage.round()}%',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: completionPercentage / 100,
          minHeight: 8,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(
            completionPercentage >= 80
                ? Colors.green
                : completionPercentage >= 50
                ? Colors.orange
                : Colors.red,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
      ],
    );
  }

  Widget _buildProfileDetailsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: backgroundColor,
      shadowColor: primaryColor.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildDetailRow(Icons.phone, 'Phone', _controller.profileData['phone'] ?? 'Not provided'),
            const Divider(height: 24),
            _buildDetailRow(Icons.location_city, 'City', _controller.profileData['city'] ?? 'Not provided'),
            const Divider(height: 24),
            _buildDetailRow(
              Icons.email,
              'Email Verification',
              _controller.profileData['isEmailVerified'] == true ? 'Verified' : 'Not Verified',
              trailing: Icon(
                _controller.profileData['isEmailVerified'] == true
                    ? Icons.verified
                    : Icons.warning,
                color: _controller.profileData['isEmailVerified'] == true
                    ? Colors.green
                    : Colors.orange,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVendorDetailsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: backgroundColor,
      shadowColor: primaryColor.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vendor Details',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 12),
            _buildDetailRow(Icons.credit_card, 'CNIC', _controller.profileData['cnic'] ?? 'Not provided'),
            const Divider(height: 24),
            _buildDetailRow(Icons.business, 'NTN', _controller.profileData['ntn'] ?? 'Not provided'),
            const Divider(height: 24),
            _buildDetailRow(
              Icons.verified_user,
              'Status',
              _controller.profileData['status']?.toString().toUpperCase() ?? 'UNKNOWN',
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(_controller.profileData['status']),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _controller.profileData['status']?.toString().toUpperCase() ?? 'UNKNOWN',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String title, String value, {Widget? trailing}) {
    return Row(
      children: [
        Icon(icon, color: primaryColor, size: 24),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: primaryColor.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: primaryColor,
                ),
              ),
            ],
          ),
        ),
        if (trailing != null) trailing,
      ],
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // Handle logout
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.red.shade200),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: const Text(
          'Logout',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: () {},
          child: const Text(
            "Current Bookings",
            style: TextStyle(color: Colors.white),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            foregroundColor: primaryColor,
            side: BorderSide(color: primaryColor),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: () {},
          child: const Text("Previous Bookings"),
        ),
      ],
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

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'approved':
        return Colors.green;
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