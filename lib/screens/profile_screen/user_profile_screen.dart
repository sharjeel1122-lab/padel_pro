  // ignore_for_file: deprecated_member_use

  import 'package:flutter/material.dart';
  import 'package:get/get.dart';
  import 'package:padel_pro/screens/profile_screen/controller/profile_controller.dart';

  class UserProfileScreen extends StatelessWidget {
    final ProfileController _controller = Get.put(ProfileController());
    final Color primaryColor = const Color(0xFF0C1E2C);
    final Color accentColor = const  Color(0xFF0C1E2C);
    final Color backgroundColor = const Color(0xFFF8F9FA);

    UserProfileScreen({super.key});

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        backgroundColor: backgroundColor,
        extendBodyBehindAppBar: true,
        appBar: AppBar(

          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.white),
            onPressed: () => _showLogoutConfirmation(context),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.white),
              onPressed: _navigateToEditProfile,
            ),

          ],
        ),
        body: Obx(() {
          if (_controller.isLoading.value) {
            return _buildLoadingIndicator();
          }

          if (_controller.errorMessage.value.isNotEmpty) {
            return _buildErrorView();
          }

          return Stack(
            children: [
              // Background Gradient
              Container(
                height: MediaQuery.of(context).size.height * 0.4,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      primaryColor.withOpacity(0.9),
                      primaryColor.withOpacity(0.7),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
              ),

              // Content
              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    SizedBox(height: MediaQuery.of(context).padding.top + 60),

                    // Profile Header
                    _buildProfileHeader(context),

                    const SizedBox(height: 24),

                    // Main Content
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          // Profile Completion
                          _buildProfileCompletionCard(),

                          const SizedBox(height: 20),

                          // Profile Details
                          _buildProfileDetailsSection(),

                          if (_controller.isVendor) ...[
                            const SizedBox(height: 20),
                            _buildVendorDetailsSection(),
                          ],

                          const SizedBox(height: 30),

                          // Action Buttons
                          _buildActionButtonsSection(),

                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
      );
    }

    Widget _buildLoadingIndicator() {
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
              'Loading your profile...',
              style: TextStyle(
                color: primaryColor,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    Widget _buildErrorView() {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.red[400],
                size: 50,
              ),
              const SizedBox(height: 20),
              Text(
                _controller.errorMessage.value,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _controller.fetchProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
                child: const Text(
                  'Try Again',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    }

    Widget _buildProfileHeader(BuildContext context) {
      return Column(
        children: [
          // Profile Picture
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.5),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: ClipOval(
              child: _controller.profileData['photo'] != null &&
                  _controller.profileData['photo'].toString().isNotEmpty
                  ? Image.network(
                _controller.profileData['photo'],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildDefaultAvatar(),
              )
                  : _buildDefaultAvatar(),
            ),
          ),

          const SizedBox(height: 20),

          // Name and Role
          Column(
            children: [
              Row( mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      _controller.fullName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),

                ],
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: _controller.isVendor ? Colors.deepOrange : accentColor,
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

          const SizedBox(height: 10),

          // Email
          Text(
            _controller.profileData['email'] ?? '',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      );
    }

    Widget _buildDefaultAvatar() {
      return Container(
        color: Colors.grey[200],
        child: const Icon(
          Icons.person,
          size: 50,
          color: Colors.grey,
        ),
      );
    }

    Widget _buildProfileCompletionCard() {
      final completionPercentage = _calculateProfileCompletion();

      return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        shadowColor: primaryColor.withOpacity(0.2),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Profile Strength',
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

              // Animated Progress Bar
              LayoutBuilder(
                builder: (context, constraints) {
                  return Stack(
                    children: [
                      Container(
                        height: 8,
                        width: constraints.maxWidth,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.easeInOut,
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
                      ),
                    ],
                  );
                },
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
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
          ),

          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildDetailItem(
                    icon: Icons.phone_rounded,
                    title: 'Phone Number',
                    value: _controller.profileData['phone'] ?? 'Not provided',
                    isVerified: true,
                  ),

                  const Divider(height: 24, thickness: 0.5),

                  _buildDetailItem(
                    icon: Icons.location_on_rounded,
                    title: 'Location',
                    value: _controller.profileData['city'] ?? 'Not provided',
                  ),

                  const Divider(height: 24, thickness: 0.5),

                  _buildDetailItem(
                    icon: Icons.email_rounded,
                    title: 'Email Verification',
                    value: _controller.profileData['isEmailVerified'] == true
                        ? 'Verified'
                        : 'Not Verified',
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
              'User Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
          ),

          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildDetailItem(
                    icon: Icons.credit_card_rounded,
                    title: 'CNIC Number',
                    value: _controller.profileData['cnic'] ?? 'Not provided',
                  ),

                  const Divider(height: 24, thickness: 0.5),

                  _buildDetailItem(
                    icon: Icons.business_rounded,
                    title: 'NTN Number',
                    value: _controller.profileData['ntn'] ?? 'Not provided',
                  ),

                  const Divider(height: 24, thickness: 0.5),

                  _buildDetailItem(
                    icon: Icons.verified_user_rounded,
                    title: 'Account Status',
                    value: _controller.profileData['status']?.toString().toUpperCase() ?? 'UNKNOWN',
                    customTrailing: Container(
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
          ),
        ],
      );
    }

    Widget _buildDetailItem({
      required IconData icon,
      required String title,
      required String value,
      bool isVerified = false,
      Widget? customTrailing,
    }) {
      return Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: primaryColor,
              size: 20,
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
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

          if (customTrailing != null)
            customTrailing
          else if (isVerified)
            const Icon(Icons.verified, color:  Color(0xFF0C1E2C), size: 20)
        ],
      );
    }

    Widget _buildActionButtonsSection() {
      return Column(
        children: [
          const SizedBox(height: 16),

          // Booking Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),

                  ),
                  onPressed: () {},
                  child: const Text("Current Bookings"),
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: primaryColor),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),

                  ),
                  onPressed: () {},
                  child: const Text("History"),
                ),
              ),
            ],
          ),
        ],
      );
    }

    double _calculateProfileCompletion() {
      final fields = [
        _controller.profileData['firstName'],
        _controller.profileData['lastName'],
        _controller.profileData['email'],
        _controller.profileData['phone'],
        _controller.profileData['city'],
        _controller.profileData['photo'],
      ];

      int filledFields = fields.where((field) => field != null && field.toString().isNotEmpty).length;
      return (filledFields / fields.length) * 100;
    }

    Color _getCompletionColor(double percentage) {
      if (percentage >= 80) return const  Color(0xFF0C1E2C);
      if (percentage >= 50) return const Color(0xFFFF9800);
      return const Color(0xFFF44336);
    }

    String _getCompletionMessage(double percentage) {
      if (percentage >= 90) return 'Excellent! Your profile is almost complete';
      if (percentage >= 70) return 'Good job! Just a few more details needed';
      if (percentage >= 50) return 'Halfway there! Complete your profile for better experience';
      return 'Complete your profile to unlock all features';
    }

    Color _getStatusColor(String? status) {
      switch (status?.toLowerCase()) {
        case 'approved':
          return const Color(0xFF4CAF50);
        case 'pending':
          return const Color(0xFFFF9800);
        case 'rejected':
          return const Color(0xFFF44336);
        default:
          return Colors.grey;
      }
    }

    void _navigateToEditProfile() {
      // Implement navigation to edit profile screen
    }

    Future<void> _showLogoutConfirmation(BuildContext context) async {
      return showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              const Text('Confirmation !',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel',
                  style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
                // Add your logout logic here
              },
              child: const Text('Logout',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

  }