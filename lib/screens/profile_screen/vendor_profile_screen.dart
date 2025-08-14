// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:padel_pro/screens/profile_screen/controller/profile_controller.dart';

class VendorProfileScreen extends StatefulWidget {
  const VendorProfileScreen({super.key});

  @override
  State<VendorProfileScreen> createState() => _VendorProfileScreenState();
}

class _VendorProfileScreenState extends State<VendorProfileScreen> {
  final ProfileController _controller = Get.put(ProfileController());

  // Theme
  final Color primaryColor = const Color(0xFF0C1E2C);
  final Color secondaryColor = const Color(0xFF1A3A53);
  final Color accentColor = const Color(0xFF0C1E2C);
  final Color backgroundColor = const Color(0xFFF6F7FB);

  // Scroll-based header text color (same logic as UserProfileScreen)
  final ScrollController _scrollController = ScrollController();
  static const double _headerHeight = 332.0;
  double _colorMix = 0.0; // 0 => white text, 1 => primary text

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScrollChange);
  }

  void _onScrollChange() {
    final double start = _headerHeight * 0.35;
    final double end = _headerHeight * 0.75;
    final double offset = _scrollController.offset;

    double t;
    if (offset <= start) {
      t = 0.0;
    } else if (offset >= end) {
      t = 1.0;
    } else {
      t = (offset - start) / (end - start);
    }

    t = t.clamp(0.0, 1.0);

    if (t != _colorMix) {
      setState(() => _colorMix = t);
    }
  }

  Color get _headerTextColor => Color.lerp(Colors.white, primaryColor, _colorMix)!;
  bool get _isOnLightBackground => _colorMix >= 0.5;

  @override
  void dispose() {
    _scrollController.removeListener(_onScrollChange);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            tooltip: 'Edit Profile',
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: _navigateToEditProfile,
          ),
        ],
      ),
      body: Obx(() {
        if (_controller.isLoading.value) {
          return _buildLoading();
        }
        if (_controller.errorMessage.value.isNotEmpty) {
          return _buildError();
        }

        return Stack(
          children: [
            _buildHeaderBackground(),
            SingleChildScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  SizedBox(height: MediaQuery.of(context).padding.top + 60),
                  _buildProfileHeader(),
                  const SizedBox(height: 18),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildHighlightCards(),
                  ),
                  const SizedBox(height: 18),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        _buildProfileCompletionCard(),
                        const SizedBox(height: 16),
                        _buildPersonalInfoCard(),
                        const SizedBox(height: 16),
                        _buildVendorInfoCard(),
                        const SizedBox(height: 24),
                        _buildLogoutButton(),
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

  // ---------------------------
  // Header background (gradient)
  // ---------------------------
  Widget _buildHeaderBackground() {
    return Container(
      height: _headerHeight,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primaryColor.withOpacity(0.98),
            secondaryColor.withOpacity(0.95),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
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

  Widget _bubble(double size, Color color) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );

  // ---------------------------
  // Loading & Error
  // ---------------------------
  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
          ),
          const SizedBox(height: 20),
          Text('Loading Profile...', style: TextStyle(color: primaryColor)),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red[400], size: 56),
            const SizedBox(height: 16),
            Text(_controller.errorMessage.value,
                textAlign: TextAlign.center,
                style: TextStyle(color: primaryColor)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _controller.fetchProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              ),
              child: const Text('Try Again', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------
  // Profile header (avatar + name/role/email with color transition)
  // ---------------------------
  Widget _buildProfileHeader() {
    final Color titleColor = _headerTextColor;
    final bool onLight = _isOnLightBackground;

    final Color roleBg = onLight
        ? primaryColor.withOpacity(0.10)
        : Colors.white.withOpacity(0.14);
    final Color roleBorder = onLight
        ? primaryColor.withOpacity(0.25)
        : Colors.white.withOpacity(0.25);
    final Color roleText = onLight ? primaryColor : Colors.white;

    return Column(
      children: [
        // Avatar
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.35), width: 1),
          ),
          child: ClipOval(
            child: SizedBox(
              width: 116,
              height: 116,
              child: _controller.profileData['photo'] != null &&
                  _controller.profileData['photo'].toString().isNotEmpty
                  ? Image.network(
                _controller.profileData['photo'],
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _defaultAvatar(),
              )
                  : _defaultAvatar(),
            ),
          ),
        ),

        const SizedBox(height: 14),

        // Name
        Text(
          _controller.fullName,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: titleColor,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 6),

        // Role
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: roleBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: roleBorder),
          ),
          child: Text(
            (_controller.profileData['role']?.toString().toUpperCase() ?? 'VENDOR'),
            style: TextStyle(
              color: roleText,
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
            color: Color.lerp(
              Colors.white.withOpacity(0.92),
              primaryColor.withOpacity(0.92),
              _colorMix,
            ),
          ),
        ),
      ],
    );
  }

  Widget _defaultAvatar() =>
      Container(color: Colors.grey[200], child: const Icon(Icons.person, size: 50, color: Colors.grey));

  // ---------------------------
  // Highlight quick cards (City, Town, Phone, Email status, Vendor status)
  // ---------------------------
  Widget _buildHighlightCards() {
    final isVendor = _controller.isVendor;
    final city = _controller.profileData['city']?.toString() ?? '—';
    final town = _controller.profileData['town']?.toString() ?? '—';
    final phone = _controller.profileData['phone']?.toString() ?? '—';
    final emailVerified = _controller.profileData['isEmailVerified'] == true;

    final items = <Widget>[
      _miniStatCard(title: 'City', value: city, icon: LucideIcons.building2),
      _miniStatCard(title: 'Town', value: town, icon: LucideIcons.mapPin),
      _miniStatCard(title: 'Phone', value: phone, icon: LucideIcons.phone),
      _miniStatCard(
        title: 'Email',
        value: emailVerified ? 'Verified' : 'Not Verified',
        icon: emailVerified ? LucideIcons.badgeCheck : LucideIcons.mailQuestion,
        accent: emailVerified ? const Color(0xFF2E7D32) : const Color(0xFFD84315),
      ),
      if (isVendor)
        _miniStatCard(
          title: 'Account',
          value: (_controller.profileData['status']?.toString().toUpperCase() ?? 'UNKNOWN'),
          icon: LucideIcons.shieldCheck,
          accent: _statusColor(_controller.profileData['status']),
        ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 720;
        final columns = isWide ? 4 : 2;
        return _gridWrap(items, columns);
      },
    );
  }

  Widget _gridWrap(List<Widget> children, int columns) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 12.0;
        final totalSpacing = spacing * (columns - 1);
        final itemWidth = (constraints.maxWidth - totalSpacing) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: children.map((w) => SizedBox(width: itemWidth, child: w)).toList(),
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
    final Color iconC = (accent ?? primaryColor);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: iconC.withOpacity(0.18)),
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
                Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                const SizedBox(height: 4),
                Text(
                  value.isNotEmpty ? value : '—',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: primaryColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------
  // Cards
  // ---------------------------
  Widget _elevatedCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withOpacity(0.04)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, 8)),
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
            style: TextStyle(fontSize: 16, color: primaryColor, fontWeight: FontWeight.w800, letterSpacing: 0.2),
          ),
        ),
        if (trailing != null) trailing,
      ],
    );
  }

  Widget _buildProfileCompletionCard() {
    final completion = _profileCompletion();
    return _elevatedCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _cardHeader(icon: LucideIcons.gauge, title: 'Profile Strength', trailing: Text(
            '${completion.round()}%',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _completionColor(completion),
            ),
          )),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) => Stack(
              children: [
                Container(
                  height: 10,
                  width: constraints.maxWidth,
                  decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(6)),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeInOut,
                  height: 10,
                  width: constraints.maxWidth * (completion / 100),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      _completionColor(completion),
                      _completionColor(completion).withOpacity(0.8),
                    ]),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(_completionMessage(completion), style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ]),
      ),
    );
  }

  Widget _buildPersonalInfoCard() {
    return _elevatedCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _cardHeader(icon: LucideIcons.user, title: 'Personal Information'),
            const SizedBox(height: 6),
            const Divider(height: 24, thickness: 0.6),
            _detailRow(icon: LucideIcons.phone, title: 'Phone', value: _controller.profileData['phone'] ?? 'Not provided'),
            const Divider(height: 24, thickness: 0.5),
            _detailRow(icon: LucideIcons.mapPin, title: 'City', value: _controller.profileData['city'] ?? 'Not provided'),
            const Divider(height: 24, thickness: 0.5),
            // Town included
            _detailRow(icon: LucideIcons.map, title: 'Town', value: _controller.profileData['town'] ?? 'Not provided'),
            const Divider(height: 24, thickness: 0.5),
            _detailRow(
              icon: LucideIcons.mailCheck,
              title: 'Email Verification',
              value: _controller.profileData['isEmailVerified'] == true ? 'Verified' : 'Not Verified',
              trailingVerified: _controller.profileData['isEmailVerified'] == true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVendorInfoCard() {
    return _elevatedCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _cardHeader(icon: LucideIcons.store, title: 'Vendor Information'),
            const SizedBox(height: 6),
            const Divider(height: 24, thickness: 0.6),
            _detailRow(icon: LucideIcons.creditCard, title: 'CNIC', value: _controller.profileData['cnic'] ?? 'Not provided'),
            const Divider(height: 24, thickness: 0.5),
            _detailRow(icon: LucideIcons.badgeDollarSign, title: 'NTN', value: _controller.profileData['ntn'] ?? 'Not provided'),
            const Divider(height: 24, thickness: 0.5),
            _detailRow(
              icon: LucideIcons.shieldCheck,
              title: 'Status',
              value: _controller.profileData['status']?.toString().toUpperCase() ?? 'UNKNOWN',
              trailingStatus: _controller.profileData['status'],
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow({
    required IconData icon,
    required String title,
    required String value,
    bool trailingVerified = false,
    String? trailingStatus,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(color: primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: primaryColor, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: primaryColor)),
          ]),
        ),
        if (trailingStatus != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: _statusColor(trailingStatus), borderRadius: BorderRadius.circular(12)),
            child: Text(trailingStatus.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          )
        else if (trailingVerified)
          Icon(Icons.verified, color: accentColor, size: 22),
      ],
    );
  }

  // ---------------------------
  // Logout button
  // ---------------------------
  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red,
          side: BorderSide(color: Colors.red.withOpacity(0.3)),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: () {
          // TODO: Hook your logout logic here
        },
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.logOut, size: 20),
            SizedBox(width: 8),
            Text('Logout', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  // ---------------------------
  // Edit Dialog (with Town)
  // ---------------------------
  void _navigateToEditProfile() {
    final formKey = GlobalKey<FormState>();

    final firstNameController = TextEditingController(text: _controller.profileData['firstName'] ?? '');
    final lastNameController  = TextEditingController(text: _controller.profileData['lastName'] ?? '');
    final phoneController     = TextEditingController(text: _controller.profileData['phone'] ?? '');
    final cityController      = TextEditingController(text: _controller.profileData['city'] ?? '');
    final townController      = TextEditingController(text: _controller.profileData['town'] ?? '');

    File? selectedImageFile;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) {
          Future<void> pickImage(ImageSource source) async {
            final picker = ImagePicker();
            final xFile = await picker.pickImage(source: source, imageQuality: 85);
            if (xFile != null) setState(() => selectedImageFile = File(xFile.path));
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
            maybeSet('lastName',  lastNameController.text);
            maybeSet('phone',     phoneController.text);
            maybeSet('city',      cityController.text);
            maybeSet('town',      townController.text);

            final hasFile = selectedImageFile != null;
            final hasAnyField = payload.isNotEmpty || hasFile;

            if (!hasAnyField) {
              Get.snackbar('No changes', 'Update at least one field or photo', snackPosition: SnackPosition.BOTTOM);
              return;
            }

            try {
              Get.back();
              await _controller.updateProfile(
                firstName: payload['firstName'],
                lastName:  payload['lastName'],
                phone:     payload['phone'],
                city:      payload['city'],
                town:      payload['town'],
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
          BoxShadow(color: primaryColor.withOpacity(0.08), blurRadius: 24, offset: const Offset(0, 12)),
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
          const Text('Edit Profile',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
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
          errorBuilder: (_, __, ___) => _defaultAvatar(),
          )
              : _defaultAvatar()),
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
          validator: (v) => (v == null || v.trim().isEmpty) ? 'First name is required' : null,
          ),
          ),
          const SizedBox(width: 12),
          Expanded(
          child: _textField(
          controller: lastNameController,
          label: 'Last name',
          icon: Icons.badge_outlined,
          textInputAction: TextInputAction.next,
          validator: (v) => (v == null || v.trim().isEmpty) ? 'Last name is required' : null,
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

          // Sticky actions
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
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, -2)),
          ],
          ),
          child: Row(
          children: [
          Expanded(
          child: OutlinedButton(
          onPressed: () => Get.back(),
          style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
          ));
        },
      ),
    );
  }

  // ---------------------------
  // Small helpers (inputs, labels, chips)
  // ---------------------------
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
        prefixIcon: icon != null ? Icon(icon, color: primaryColor.withOpacity(0.9), size: 20) : null,
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
          style: TextStyle(fontSize: 14, color: primaryColor, fontWeight: FontWeight.w700, letterSpacing: 0.2),
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
          border: Border.all(color: isDanger ? Colors.red[200]! : primaryColor.withOpacity(0.18)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: fg),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: fg, fontWeight: FontWeight.w600, letterSpacing: 0.2)),
          ],
        ),
      ),
    );
  }

  // ---------------------------
  // Completion / status helpers
  // ---------------------------
  double _profileCompletion() {
    final fields = [
      _controller.profileData['firstName'],
      _controller.profileData['lastName'],
      _controller.profileData['email'],
      _controller.profileData['phone'],
      _controller.profileData['city'],
      _controller.profileData['town'], // include town for vendor too
      _controller.profileData['photo'],
    ];
    final filled = fields.where((f) => f != null && f.toString().isNotEmpty).length;
    return (filled / fields.length) * 100;
  }

  Color _completionColor(double p) {
    if (p >= 80) return accentColor;
    if (p >= 50) return Colors.orange;
    return Colors.red;
  }

  String _completionMessage(double p) {
    if (p >= 80) return 'Great! Your profile is almost complete';
    if (p >= 50) return 'Good, but you can add more details';
    return 'Please complete your profile for better experience';
  }

  Color _statusColor(String? status) {
    switch ((status ?? '').toLowerCase()) {
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
}
