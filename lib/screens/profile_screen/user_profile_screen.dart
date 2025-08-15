// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:padel_pro/screens/profile_screen/controller/profile_controller.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final ProfileController _controller = Get.put(ProfileController());
  final Color primaryColor = const Color(0xFF0C1E2C);
  final Color accentColor = const Color(0xFF0C1E2C);
  final Color backgroundColor = const Color(0xFFF6F7FB);

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
            // Stylish Gradient Header
            _buildHeaderBackground(),

            // Content
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  SizedBox(height: MediaQuery.of(context).padding.top + 60),

                  // Profile Header (avatar + name + role + email)
                  _buildProfileHeader(context),

                  const SizedBox(height: 18),

                  // Highlight Data Cards (Quick glance)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildHighlightCards(context),
                  ),

                  const SizedBox(height: 18),

                  // Main Cards
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        _buildProfileCompletionCard(),
                        const SizedBox(height: 16),
                        _buildProfileDetailsSection(), // includes Town now
                        if (_controller.isVendor) ...[
                          const SizedBox(height: 16),
                          _buildVendorDetailsSection(),
                        ],
                        // const SizedBox(height: 24),
                        // _buildActionButtonsSection(),
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

  // =========================
  // HEADER & LOADING/ERROR
  // =========================

  Widget _buildHeaderBackground() {
    return Container(
      height: 333,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primaryColor.withOpacity(0.98),
            primaryColor.withOpacity(0.80),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            top: -30,
            right: -30,
            child: _bubble(120, Colors.white.withOpacity(0.06)),
          ),
          Positioned(
            top: 40,
            left: -20,
            child: _bubble(80, Colors.white.withOpacity(0.05)),
          ),
        ],
      ),
    );
  }

  Widget _bubble(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
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
              child: const Text('Try Again', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  // =========================
  // PROFILE HEADER
  // =========================

  Widget _buildProfileHeader(BuildContext context) {
    return Column(
      children: [
        // Avatar with subtle glass card
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.35), width: 1),
          ),
          child: Container(
            width: 116,
            height: 116,
            decoration: const BoxDecoration(shape: BoxShape.circle),
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
        ),

        const SizedBox(height: 14),

        // Name
        Text(
          _controller.fullName,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 6),

        // Role Chip
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.14),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.25)),
          ),
          child: Text(
            (_controller.profileData['role']?.toString().toUpperCase() ?? 'USER'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Email
        Text(
          _controller.profileData['email'] ?? '',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(0.92),
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: Colors.grey[200],
      child: const Icon(Icons.person, size: 50, color: Colors.grey),
    );
  }

  // =========================
  // HIGHLIGHT CARDS (Quick info)
  // =========================

  Widget _buildHighlightCards(BuildContext context) {
    final isVendor = _controller.isVendor;
    final city = _controller.profileData['city']?.toString() ?? '—';
    final town = _controller.profileData['town']?.toString() ?? '—';
    final phone = _controller.profileData['phone']?.toString() ?? '—';
    final emailVerified = _controller.profileData['isEmailVerified'] == true;

    // Responsive grid-like wrap
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 720;
        final crossAxisCount = isWide ? 4 : 2;

        final items = <Widget>[
          _miniStatCard(
            title: 'City',
            value: city,
            icon: Icons.location_city_rounded,
          ),
          _miniStatCard(
            title: 'Town',
            value: town,
            icon: Icons.place_rounded,
          ),
          _miniStatCard(
            title: 'Phone',
            value: phone,
            icon: Icons.phone_rounded,
          ),
          _miniStatCard(
            title: 'Email',
            value: emailVerified ? 'Verified' : 'Not Verified',
            icon: emailVerified ? Icons.verified_rounded : Icons.mark_email_unread_rounded,
            accent: emailVerified ? const Color(0xFF2E7D32) : const Color(0xFFD84315),
          ),
          if (isVendor)
            _miniStatCard(
              title: 'Account',
              value: (_controller.profileData['status']?.toString().toUpperCase() ?? 'UNKNOWN'),
              icon: Icons.verified_user_rounded,
              accent: _getStatusColor(_controller.profileData['status']),
            ),
        ];

        return _gridWrap(items, crossAxisCount);
      },
    );
  }

  Widget _gridWrap(List<Widget> children, int columns) {
    // Simple responsive grid using Wrap + fixed item width
    return LayoutBuilder(
      builder: (context, constraints) {
        final spacing = 12.0;
        final totalSpacing = spacing * (columns - 1);
        final itemWidth = (constraints.maxWidth - totalSpacing) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: children
              .map((w) => SizedBox(width: itemWidth, child: w))
              .toList(),
        );
      },
    );
  }

  Widget _miniStatCard({
    required String title,
    required String value,
    required IconData icon,
    Color? accent,
  }) {
    final Color borderC = (accent ?? primaryColor).withOpacity(0.20);
    final Color iconC = (accent ?? primaryColor);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderC, width: 1),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconC.withOpacity(0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconC, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    )),
                const SizedBox(height: 4),
                Text(
                  value.isNotEmpty ? value : '—',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // MAIN CARDS
  // =========================

  Widget _buildProfileCompletionCard() {
    final completionPercentage = _calculateProfileCompletion();

    return _elevatedCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _cardHeader(
              icon: Icons.track_changes_rounded,
              title: 'Profile Strength',
              trailing: Text(
                '${completionPercentage.round()}%',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _getCompletionColor(completionPercentage),
                ),
              ),
            ),
            const SizedBox(height: 12),
            LayoutBuilder(builder: (context, constraints) {
              return Stack(
                children: [
                  Container(
                    height: 10,
                    width: constraints.maxWidth,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeInOut,
                    height: 10,
                    width: constraints.maxWidth * (completionPercentage / 100),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _getCompletionColor(completionPercentage),
                          _getCompletionColor(completionPercentage).withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ],
              );
            }),
            const SizedBox(height: 10),
            Text(
              _getCompletionMessage(completionPercentage),
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileDetailsSection() {
    return _elevatedCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _cardHeader(icon: Icons.person_rounded, title: 'Personal Information'),
            const SizedBox(height: 6),
            const Divider(height: 24, thickness: 0.6),

            _buildDetailItem(
              icon: Icons.phone_rounded,
              title: 'Phone Number',
              value: _controller.profileData['phone'] ?? 'Not provided',
              isVerified: true,
            ),
            const Divider(height: 24, thickness: 0.5),

            _buildDetailItem(
              icon: Icons.location_on_rounded,
              title: 'City',
              value: _controller.profileData['city'] ?? 'Not provided',
            ),
            const Divider(height: 24, thickness: 0.5),

            // >>> New: Town shown in profile
            _buildDetailItem(
              icon: Icons.place_rounded,
              title: 'Town',
              value: _controller.profileData['town'] ?? 'Not provided',
            ),
            const Divider(height: 24, thickness: 0.5),

            _buildDetailItem(
              icon: Icons.email_rounded,
              title: 'Email Verification',
              value: _controller.profileData['isEmailVerified'] == true ? 'Verified' : 'Not Verified',
              isVerified: _controller.profileData['isEmailVerified'] == true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVendorDetailsSection() {
    return _elevatedCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _cardHeader(icon: Icons.store_rounded, title: 'User Details'),
            const SizedBox(height: 6),
            const Divider(height: 24, thickness: 0.6),

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
    );
  }

  Widget _elevatedCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withOpacity(0.04)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _cardHeader({required IconData icon, required String title, Widget? trailing}) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: primaryColor, size: 20),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              color: primaryColor,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
            ),
          ),
        ),
        if (trailing != null) trailing,
      ],
    );
  }

  // =========================
  // DETAIL ROW ITEM
  // =========================

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
            color: primaryColor.withOpacity(0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: primaryColor, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: primaryColor,
                ),
              ),
            ],
          ),
        ),
        if (customTrailing != null)
          customTrailing
        else if (isVerified)
          const Icon(Icons.verified, color: Color(0xFF0C1E2C), size: 20),
      ],
    );
  }

  // =========================
  // ACTION BUTTONS
  // =========================

  Widget _buildActionButtonsSection() {
    return Column(
      children: [
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.event_available_rounded),
                label: const Text("Current Bookings"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                ),
                onPressed: () {},
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.history_rounded),
                label: const Text("History"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: primaryColor,
                  side: BorderSide(color: primaryColor.withOpacity(0.35)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {},
              ),
            ),
          ],
        ),
      ],
    );
  }

  // =========================
  // COMPLETION + STATUS HELPERS
  // =========================

  double _calculateProfileCompletion() {
    final fields = [
      _controller.profileData['firstName'],
      _controller.profileData['lastName'],
      _controller.profileData['email'],
      _controller.profileData['phone'],
      _controller.profileData['city'],
      _controller.profileData['town'], // include town in completion
      _controller.profileData['photo'],
    ];

    int filledFields =
        fields.where((field) => field != null && field.toString().isNotEmpty).length;
    return (filledFields / fields.length) * 100;
  }

  Color _getCompletionColor(double percentage) {
    if (percentage >= 80) return const Color(0xFF0C1E2C);
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

  // =========================
  // EDIT PROFILE DIALOG
  // =========================

  void _navigateToEditProfile() {
    final formKey = GlobalKey<FormState>();

    final firstNameController =
    TextEditingController(text: _controller.profileData['firstName'] ?? '');
    final lastNameController =
    TextEditingController(text: _controller.profileData['lastName'] ?? '');
    final phoneController =
    TextEditingController(text: _controller.profileData['phone'] ?? '');
    final cityController =
    TextEditingController(text: _controller.profileData['city'] ?? '');
    final townController =
    TextEditingController(text: _controller.profileData['town'] ?? '');

    File? selectedImageFile;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            Future<void> pickImage(ImageSource source) async {
              final picker = ImagePicker();
              final xFile = await picker.pickImage(source: source, imageQuality: 85);
              if (xFile != null) {
                setState(() {
                  selectedImageFile = File(xFile.path);
                });
              }
            }

            Future<void> submit() async {
              if (!formKey.currentState!.validate()) return;

              final Map<String, dynamic> payload = {};
              void maybeSet(String key, String? newVal) {
                final oldVal = _controller.profileData[key]?.toString() ?? '';
                if (newVal != null && newVal.trim().isNotEmpty && newVal.trim() != oldVal) {
                  payload[key] = newVal.trim();
                }
              }

              maybeSet('firstName', firstNameController.text);
              maybeSet('lastName', lastNameController.text);
              maybeSet('phone', phoneController.text);
              maybeSet('city', cityController.text);
              maybeSet('town', townController.text);

              final hasFile = selectedImageFile != null;
              final hasAnyField = payload.isNotEmpty || hasFile;

              if (!hasAnyField) {
                Get.snackbar('No changes', 'Update at least one field or photo',
                    snackPosition: SnackPosition.BOTTOM);
                return;
              }

              try {
                Get.back(); // close dialog immediately for snappy UX
                await _controller.updateProfile(
                  firstName: payload['firstName'],
                  lastName: payload['lastName'],
                  phone: payload['phone'],
                  city: payload['city'],
                  town: payload['town'],
                  imageFile: selectedImageFile,
                );
              } catch (e) {
                Get.snackbar('Update failed', e.toString(),
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.red.withOpacity(0.1));
              }
            }

            final size = MediaQuery.of(context).size;
            final isWide = size.width >= 480;

            return Dialog(
              insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.08),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: SafeArea(
                    top: false,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Header
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [primaryColor, primaryColor.withOpacity(0.92)],
                            ),
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.edit, color: Colors.white, size: 20),
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                'Edit Profile',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                tooltip: 'Close',
                                onPressed: () => Get.back(),
                                icon: const Icon(Icons.close, color: Colors.white),
                              ),
                            ],
                          ),
                        ),

                        // Body
                        Flexible(
                          child: SingleChildScrollView(
                            padding: EdgeInsets.only(
                              left: isWide ? 24 : 16,
                              right: isWide ? 24 : 16,
                              top: 16,
                              bottom: 8,
                            ),
                            child: Form(
                              key: formKey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Avatar + Actions
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(60),
                                        child: SizedBox(
                                          width: 72,
                                          height: 72,
                                          child: selectedImageFile != null
                                              ? Image.file(selectedImageFile!, fit: BoxFit.cover)
                                              : (_controller.profileData['photo'] != null &&
                                              _controller.profileData['photo'].toString().isNotEmpty
                                              ? Image.network(
                                            _controller.profileData['photo'],
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => _buildDefaultAvatar(),
                                          )
                                              : _buildDefaultAvatar()),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Wrap(
                                          spacing: 10,
                                          runSpacing: 10,
                                          children: [
                                            _actionChip(
                                              icon: Icons.photo_library_rounded,
                                              label: 'Choose photo',
                                              onTap: () => pickImage(ImageSource.gallery),
                                            ),
                                            _actionChip(
                                              icon: Icons.photo_camera_rounded,
                                              label: 'Take photo',
                                              onTap: () => pickImage(ImageSource.camera),
                                            ),
                                            if (selectedImageFile != null)
                                              _actionChip(
                                                icon: Icons.delete_outline_rounded,
                                                label: 'Remove',
                                                isDanger: true,
                                                onTap: () => setState(() => selectedImageFile = null),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 18),
                                  _sectionLabel('Basic details'),

                                  Row(
                                    children: [
                                      Expanded(
                                        child: _textField(
                                          controller: firstNameController,
                                          label: 'First name',
                                          icon: Icons.badge_rounded,
                                          textInputAction: TextInputAction.next,
                                          validator: (v) => (v == null || v.trim().isEmpty)
                                              ? 'First name is required'
                                              : null,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: _textField(
                                          controller: lastNameController,
                                          label: 'Last name',
                                          icon: Icons.badge_outlined,
                                          textInputAction: TextInputAction.next,
                                          validator: (v) => (v == null || v.trim().isEmpty)
                                              ? 'Last name is required'
                                              : null,
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 12),
                                  _textField(
                                    controller: phoneController,
                                    label: 'Phone',
                                    icon: Icons.phone_rounded,
                                    keyboardType: TextInputType.phone,
                                    textInputAction: TextInputAction.next,
                                    validator: (v) {
                                      if (v == null || v.trim().isEmpty) return 'Phone is required';
                                      if (v.trim().length < 7) return 'Enter a valid phone';
                                      return null;
                                    },
                                  ),

                                  const SizedBox(height: 18),
                                  _sectionLabel('Location'),

                                  Row(
                                    children: [
                                      Expanded(
                                        child: _textField(
                                          controller: cityController,
                                          label: 'City',
                                          icon: Icons.location_city_rounded,
                                          textInputAction: TextInputAction.next,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: _textField(
                                          controller: townController,
                                          label: 'Town',
                                          icon: Icons.place_rounded,
                                          textInputAction: TextInputAction.done,
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 8),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Email is not editable here.',
                                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Sticky Actions
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.only(
                            left: isWide ? 24 : 16,
                            right: isWide ? 24 : 16,
                            top: 12,
                            bottom: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 8,
                                offset: const Offset(0, -2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => Get.back(),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    side: BorderSide(color: primaryColor.withOpacity(0.25)),
                                    foregroundColor: primaryColor,
                                  ),
                                  child: const Text('Cancel'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: submit,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryColor,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: const Text('Save changes'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // =========================
  // INPUT + UI HELPERS
  // =========================

  Widget _textField({
    required TextEditingController controller,
    required String label,
    IconData? icon,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null
            ? Icon(icon, color: primaryColor.withOpacity(0.9), size: 20)
            : null,
        filled: true,
        fillColor: Colors.grey[100],
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 1.2),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: primaryColor,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }

  Widget _actionChip({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDanger = false,
  }) {
    final bg = isDanger ? Colors.red.withOpacity(0.06) : primaryColor.withOpacity(0.06);
    final fg = isDanger ? Colors.red[700]! : primaryColor;
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: (isDanger ? Colors.red[200]! : primaryColor.withOpacity(0.18))),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: fg),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: fg,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showLogoutConfirmation(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Text('Confirmation !', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(context);
              // Add your logout logic here
            },
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
