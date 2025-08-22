// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:confetti/confetti.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:padel_pro/screens/user/views/booking_sheet.dart';
import 'package:padel_pro/screens/user/user_controller/user_allclub_screen_controller.dart';

// Admin theme colors
const Color kPrimary = Color(0xFF0A3B5C);
const Color kBg = Color(0xFF072A40);
const Color kCardBg = Color(0xFF0A3B5C);
const Color kAccent = Color(0xFF1E88E5);

class AdminClubDetailScreen extends StatefulWidget {
  final Map<String, dynamic> playground;

  const AdminClubDetailScreen({super.key, required this.playground});

  @override
  State<AdminClubDetailScreen> createState() => _AdminClubDetailScreenState();
}

class _AdminClubDetailScreenState extends State<AdminClubDetailScreen> {
  late ConfettiController _confettiController;
  bool _isFavorite = false;

  // Carousel
  late final PageController _pageController;
  int _currentPage = 0;
  late final List<String> _gallery; // absolute URLs

  // --- CONFIG (fallback only if controller not registered) ---
  static const String kBaseImageUrl = 'https://padel-backend-git-main-invosegs-projects.vercel.app';

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 1));
    _isFavorite = widget.playground['isFavorite'] ?? false;

    _gallery = _resolveGalleryUrls(widget.playground);
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  // ---------------- IMAGE HELPERS ----------------

  /// Prefer controller's base/headers if present
  Map<String, String>? _resolveHeaders() {
    if (Get.isRegistered<UserClubScreenController>()) {
      final ctrl = Get.find<UserClubScreenController>();
      return ctrl.imageHeaders;
    }
    return null;
  }

  /// Build a gallery (unique absolute URLs) from multiple fields
  List<String> _resolveGalleryUrls(Map<String, dynamic> pg) {
    // If controller offers a single resolver, still build multi by scanning keys,
    // but use the same base normalization as controller when possible.
    final urls = <String>{};

    String normalize(String raw) {
      // Use controller's normalization via imageUrlFor if available for single items
      if (Get.isRegistered<UserClubScreenController>()) {
        final ctrl = Get.find<UserClubScreenController>();
        // ctrl.imageUrlFor returns single; for consistency, still normalize here
        // but we can attempt to use it when raw equals best candidate.
        // For simplicity we apply our local normalize, which matches earlier logic.
      }
      return _normalizeToAbsoluteUrl(raw);
    }

    void addIfValid(dynamic v) {
      if (v is String && v.trim().isNotEmpty) {
        urls.add(normalize(v.trim()));
      } else if (v is Map && v['url'] is String && (v['url'] as String).trim().isNotEmpty) {
        urls.add(normalize((v['url'] as String).trim()));
      }
    }

    // Singles
    for (final k in ['image', 'imageUrl', 'photo', 'thumbnail', 'cover', 'logo', 'coverImage']) {
      addIfValid(pg[k]);
    }

    // Arrays on playground
    for (final k in ['photos', 'images', 'gallery']) {
      final v = pg[k];
      if (v is List && v.isNotEmpty) {
        for (final e in v) addIfValid(e);
      }
    }

    // From courts
    final courts = pg['courts'];
    if (courts is List && courts.isNotEmpty) {
      for (final c in courts) {
        if (c is Map) {
          for (final k in ['image', 'imageUrl', 'photo', 'thumbnail', 'cover']) {
            addIfValid(c[k]);
          }
          for (final k in ['photos', 'images', 'gallery']) {
            final v = c[k];
            if (v is List && v.isNotEmpty) {
              for (final e in v) addIfValid(e);
            }
          }
        }
      }
    }

    final list = urls.toList();
    if (list.isEmpty) {
      // fallback placeholder
      list.add('https://images.unsplash.com/photo-1595526114035-0c45a16a0d79');
    }
    return list;
  }

  String _normalizeToAbsoluteUrl(String raw) {
    String u = raw.replaceAll('\\', '/');
    final parsed = Uri.tryParse(u);

    if (u.startsWith('data:image')) return u;
    if (parsed != null && parsed.hasScheme) return u;
    if (u.startsWith('//')) return 'https:$u';

    // If controller has a BASE_URL, we don't have direct access — use local base
    return _joinUrl(kBaseImageUrl, u.startsWith('/') ? u : '/$u');
  }

  String _joinUrl(String base, String path) {
    final b = base.endsWith('/') ? base.substring(0, base.length - 1) : base;
    final p = path.startsWith('/') ? path.substring(1) : path;
    return '$b/$p';
  }

  Widget _coverFallback() {
    return Container(
      color: const Color(0xFF0C1E2C),
      alignment: Alignment.center,
      child: const Icon(Icons.image, size: 50, color: Colors.white),
    );
  }


  // Open full screen gallery
  void _openGallery(int initialIndex) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _FullScreenGallery(
          gallery: _gallery,
          initialIndex: initialIndex,
          headers: _resolveHeaders(),
        ),
      ),
    );
  }

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    final courts = (widget.playground['courts'] as List?) ?? [];
    final size = MediaQuery.of(context).size;

    final String pgId = (widget.playground['_id'] ??
        widget.playground['playgroundId'] ??
        '')
        .toString();

    final headers = _resolveHeaders();

    return Scaffold(
      backgroundColor: kBg,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                elevation: 0,
                backgroundColor: kPrimary,
                iconTheme: const IconThemeData(color: Colors.white),
                expandedHeight: size.height * 0.34,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsetsDirectional.only(start: 16, bottom: 16, end: 16),
                  title: _HeaderTitle(name: widget.playground['name']?.toString() ?? 'Padel Club'),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // --- Swipeable Carousel ---
                      PageView.builder(
                        controller: _pageController,
                        onPageChanged: (i) => setState(() => _currentPage = i),
                        itemCount: _gallery.length,
                        itemBuilder: (_, i) {
                          final url = _gallery[i];
                          return GestureDetector(
                            onTap: () => _openGallery(_currentPage),
                            child: Image.network(
                              url,
                              headers: headers,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return _coverFallback();
                              },
                              errorBuilder: (_, __, ___) => _coverFallback(),
                            ),
                          );
                        },
                      ),

                      // Gradient overlay (top/bottom)
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              kPrimary.withOpacity(0.8),
                              kPrimary.withOpacity(0.4),
                              kPrimary.withOpacity(0.2),
                              kPrimary.withOpacity(0.6),
                            ],
                          ),
                        ),
                      ),

                      // Navigation arrows for carousel
                      if (_gallery.length > 1)
                        Positioned.fill(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Left arrow
                              if (_currentPage > 0)
                                GestureDetector(
                                  onTap: () {
                                    _pageController.previousPage(
                                      duration: const Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                    );
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(left: 10),
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.3),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                                  ),
                                )
                              else
                                const SizedBox(width: 40),

                              // Right arrow
                              if (_currentPage < _gallery.length - 1)
                                GestureDetector(
                                  onTap: () {
                                    _pageController.nextPage(
                                      duration: const Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                    );
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(right: 10),
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.3),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 20),
                                  ),
                                )
                              else
                                const SizedBox(width: 40),
                            ],
                          ),
                        ),

                      // Dots indicator
                      Positioned(
                        bottom: 12,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: _DotsIndicator(
                            count: _gallery.length,
                            index: _currentPage,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  // View gallery button
                  if (_gallery.length > 1)
                    IconButton(
                      icon: const Icon(Icons.photo_library_outlined),
                      onPressed: () => _openGallery(0),
                      tooltip: 'View all images',
                    ),
                ],
              ),

              // Info section
              SliverToBoxAdapter(
                child: Container(
                  decoration: const BoxDecoration(
                    color: kBg,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _InfoChipRow(
                          rating: widget.playground['rating']?.toString() ?? '4.5',
                          opening: widget.playground['openingTime']?.toString() ?? '08:00',
                          closing: widget.playground['closingTime']?.toString() ?? '22:00',
                        ),
                        const SizedBox(height: 16),
                        _LocationRow(
                          location: widget.playground['location']?.toString() ?? 'Location not specified',
                        ),
                        const SizedBox(height: 20),
                        if ((widget.playground['description']?.toString() ?? '').isNotEmpty) ...[
                          const SectionTitle('About'),
                          const SizedBox(height: 12),
                          Text(
                            widget.playground['description']?.toString() ?? 'No description available',
                            style: GoogleFonts.poppins(
                              color: Colors.white.withOpacity(0.9),
                              height: 1.5,
                              fontSize: 15,
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                        if ((widget.playground['facilities'] as List?)?.isNotEmpty ?? false) ...[
                          const SectionTitle('Facilities'),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: ((widget.playground['facilities'] as List?) ?? [])
                                .map((f) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: kAccent.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: kAccent.withOpacity(0.3)),
                              ),
                              child: Text(
                                f.toString(),
                                style: GoogleFonts.poppins(
                                  color: kAccent,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ))
                                .toList(),
                          ),
                        ],
                        const SizedBox(height: 28),
                        const SectionTitle('Available Courts'),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),

              // Courts list
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _CourtCard(
                        court: (widget.playground['courts'] as List)[index] as Map<String, dynamic>,
                        onTap: () {
                          final pgId = (widget.playground['_id'] ??
                              widget.playground['playgroundId'] ??
                              '')
                              .toString();
                          if (pgId.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Invalid playground id',
                                  style: GoogleFonts.poppins(),
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }
                          // showModalBottomSheet(
                          //   context: context,
                          //   isScrollControlled: true,
                          //   backgroundColor: Colors.transparent,
                          //   builder: (_) => BookingSheet(
                          //     playgroundId: pgId,
                          //     courts: [(widget.playground['courts'] as List)[index]],
                          //   ),
                          // );
                        },
                      ),
                    ),
                    childCount: (widget.playground['courts'] as List?)?.length ?? 0,
                  ),
                ),
              ),
            ],
          ),

          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              numberOfParticles: 20,
              colors: const [Color(0xFF0C1E2C), Colors.blue, Colors.green, Colors.orange],
            ),
          ),

          // Global Book Now
          // Positioned(
          //   bottom: 0,
          //   left: 0,
          //   right: 0,
          //   child: _BottomCTA(
          //     onPressed: () {
          //       final pgId = (widget.playground['_id'] ??
          //           widget.playground['playgroundId'] ??
          //           '')
          //           .toString();
          //       if (pgId.isEmpty) {
          //         ScaffoldMessenger.of(context).showSnackBar(
          //           const SnackBar(content: Text('Invalid playground id')),
          //         );
          //         return;
          //       }
          //       showModalBottomSheet(
          //         context: context,
          //         isScrollControlled: true,
          //         backgroundColor: Colors.transparent,
          //         builder: (_) => BookingSheet(
          //           playgroundId: pgId,
          //           courts: (widget.playground['courts'] as List?) ?? [],
          //         ),
          //       );
          //     },
          //   ),
          // ),
        ],
      ),
    );
  }

  void _sharePlayground() {
    // TODO: implement share_plus or platform share
  }
}

// Full screen gallery view
class _FullScreenGallery extends StatefulWidget {
  final List<String> gallery;
  final int initialIndex;
  final Map<String, String>? headers;

  const _FullScreenGallery({
    required this.gallery,
    required this.initialIndex,
    this.headers,
  });

  @override
  State<_FullScreenGallery> createState() => _FullScreenGalleryState();
}

class _FullScreenGalleryState extends State<_FullScreenGallery> {
  late PageController _pageController;
  late int _currentIndex;
  bool _isZoomed = false;
  final TransformationController _transformationController = TransformationController();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  void _resetZoom() {
    _transformationController.value = Matrix4.identity();
    setState(() {
      _isZoomed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Gallery ${_currentIndex + 1}/${widget.gallery.length}',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        actions: [
          // Reset zoom button
          if (_isZoomed)
            IconButton(
              icon: const Icon(Icons.zoom_out_map),
              onPressed: _resetZoom,
              tooltip: 'Reset zoom',
            ),
        ],
      ),
      body: Stack(
        children: [
          // Main gallery
          PageView.builder(
            controller: _pageController,
            physics: _isZoomed ? const NeverScrollableScrollPhysics() : const BouncingScrollPhysics(),
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
                _resetZoom(); // Reset zoom when changing images
              });
            },
            itemCount: widget.gallery.length,
            itemBuilder: (context, index) {
              return InteractiveViewer(
                transformationController: _transformationController,
                minScale: 0.5,
                maxScale: 4.0,
                onInteractionStart: (details) {
                  // When user starts pinch-zoom
                  if (details.pointerCount > 1) {
                    setState(() {
                      _isZoomed = true;
                    });
                  }
                },
                onInteractionEnd: (details) {
                  // Check if we're still zoomed in
                  final scale = _transformationController.value.getMaxScaleOnAxis();
                  setState(() {
                    _isZoomed = scale > 1.0;
                  });
                },
                child: Center(
                  child: Image.network(
                    widget.gallery[index],
                    headers: widget.headers,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                              (loadingProgress.expectedTotalBytes ?? 1)
                              : null,
                          color: kAccent,
                        ),
                      );
                    },
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey[900],
                      child: const Center(
                        child: Icon(Icons.broken_image, color: Colors.white, size: 50),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          // Navigation arrows - only show when not zoomed
          if (!_isZoomed)
            Positioned(
              left: 0,
              right: 0,
              bottom: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_currentIndex > 0)
                    _navButton(
                      icon: Icons.arrow_back_ios,
                      onTap: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                    ),
                  const SizedBox(width: 20),
                  if (_currentIndex < widget.gallery.length - 1)
                    _navButton(
                      icon: Icons.arrow_forward_ios,
                      onTap: () {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                    ),
                ],
              ),
            ),

          // Thumbnail strip at bottom - only show when not zoomed
          if (!_isZoomed && widget.gallery.length > 1)
            Positioned(
              left: 0,
              right: 0,
              bottom: 80,
              height: 60,
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.gallery.length,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  itemBuilder: (context, index) {
                    final isSelected = index == _currentIndex;
                    return GestureDetector(
                      onTap: () {
                        _pageController.animateToPage(
                          index,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: Container(
                        width: 60,
                        height: 60,
                        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isSelected ? Colors.white : Colors.transparent,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.network(
                            widget.gallery[index],
                            headers: widget.headers,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: Colors.grey[800],
                              child: const Icon(Icons.image, color: Colors.white54),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _navButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }
}

// ===== Small UI pieces =====

class _DotsIndicator extends StatelessWidget {
  const _DotsIndicator({required this.count, required this.index});
  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    if (count <= 1) return const SizedBox.shrink();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (i) {
        final selected = i == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          height: 6,
          width: selected ? 16 : 6,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(selected ? 0.95 : 0.55),
            borderRadius: BorderRadius.circular(999),
          ),
        );
      }),
    );
  }
}

class _HeaderTitle extends StatelessWidget {
  const _HeaderTitle({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, __) => Row(
        children: [
          Expanded(
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 20,
                letterSpacing: 0.2,
                shadows: [Shadow(color: Colors.black38, blurRadius: 6)],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChipRow extends StatelessWidget {
  const _InfoChipRow({
    required this.rating,
    required this.opening,
    required this.closing,
  });

  final String rating;
  final String opening;
  final String closing;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _glassChip(
          icon: Icons.star_rounded,
          label: rating,
          color: Colors.amber,
          textColor: const Color(0xFF0C1E2C),
        ),
        _glassChip(
          icon: LucideIcons.clock,
          label: '$opening - $closing',
        ),
      ],
    );
  }

  Widget _glassChip({required IconData icon, required String label, Color? color, Color? textColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: (color ?? kAccent).withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: (color ?? kAccent).withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: textColor ?? kAccent),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: textColor ?? kAccent,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationRow extends StatelessWidget {
  const _LocationRow({required this.location});
  final String location;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(LucideIcons.mapPin, size: 16, color: Colors.white70),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            location,
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontWeight: FontWeight.w600,
              height: 1.2,
              fontSize: 15,
            ),
          ),
        ),
        const Icon(Icons.directions, size: 20, color: Colors.white70),
      ],
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, {super.key});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: Colors.white,
        letterSpacing: 0.2,
      ),
    );
  }
}

class _CourtCard extends StatelessWidget {
  const _CourtCard({required this.court, this.onTap});
  final Map<String, dynamic> court;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final List pricing = (court['pricing'] as List?) ?? [];
    final List peakHours = (court['peakHours'] as List?) ?? [];
    final List courtTypes = (court['courtType'] as List?) ?? [];

    final String courtNumber = (court['courtNumber'] ?? court['courtName'] ?? '').toString();

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 5))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
              child: Row(
                children: [
                  _courtBadge('Court ${courtNumber.isEmpty ? '—' : courtNumber}'),
                  const Spacer(),
                  if (courtTypes.isNotEmpty)
                    _typeBadge(courtTypes.first.toString())
                  else
                    _typeBadge('Standard'),
                ],
              ),
            ),

            // Pricing quick glance
            if (pricing.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Row(
                  children: [
                    const Icon(LucideIcons.wallet, size: 18, color: Colors.white70),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _priceSummary(pricing),
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.white70),
                  ],
                ),
              ),
            ] else
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Text(
                  'No pricing available',
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ),

            // Peak hours
            if (peakHours.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(LucideIcons.trendingUp, size: 18, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: peakHours.map<Widget>((p) {
                          final start = (p['startTime'] ?? '').toString();
                          final end = (p['endTime'] ?? '').toString();
                          final price = (p['price'] ?? '').toString();
                          return _peakChip('$start - $end', 'Rs. $price');
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  String _priceSummary(List pricing) {
    final parts = pricing.take(3).map((p) {
      final d = (p['duration'] ?? '').toString();
      final pr = (p['price'] ?? '').toString();
      return '${d}m: Rs. $pr';
    }).toList();
    return parts.join(' • ');
  }

  Widget _courtBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(LucideIcons.badgeCheck, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _typeBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(LucideIcons.layers, size: 14, color: Colors.white70),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _peakChip(String time, String price) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.red.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(time, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w700)),
          const SizedBox(width: 8),
          const Text('•', style: TextStyle(color: Colors.red)),
          const SizedBox(width: 8),
          Text(price, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}