// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:confetti/confetti.dart';
import 'package:get/get.dart';

import 'package:padel_pro/screens/user/views/booking_sheet.dart';
import 'package:padel_pro/screens/user/user_controller/user_allclub_screen_controller.dart';

class UserClubDetailScreen extends StatefulWidget {
  final Map<String, dynamic> playground;

  const UserClubDetailScreen({super.key, required this.playground});

  @override
  State<UserClubDetailScreen> createState() => _UserClubDetailScreenState();
}

class _UserClubDetailScreenState extends State<UserClubDetailScreen> {
  late ConfettiController _confettiController;
  bool _isFavorite = false;

  // Carousel
  late final PageController _pageController;
  int _currentPage = 0;
  late final List<String> _gallery; // absolute URLs

  static const String kBaseImageUrl = 'https://padel-backend-git-main-invosegs-projects.vercel.app'; // TODO: set your API/CDN base

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
    final urls = <String>{};

    String normalize(String raw) {
      return _normalizeToAbsoluteUrl(raw);
    }

    void addIfValid(dynamic v) {
      if (v is String && v.trim().isNotEmpty) {
        urls.add(normalize(v.trim()));
      } else if (v is Map && v['url'] is String && (v['url'] as String).trim().isNotEmpty) {
        urls.add(normalize((v['url'] as String).trim()));
      }
    }

    for (final k in ['image', 'imageUrl', 'photo', 'thumbnail', 'cover', 'logo', 'coverImage']) {
      addIfValid(pg[k]);
    }

    for (final k in ['photos', 'images', 'gallery']) {
      final v = pg[k];
      if (v is List && v.isNotEmpty) {
        for (final e in v) addIfValid(e);
      }
    }

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
      backgroundColor: const Color(0xFFF5F7FA),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                elevation: 0,
                backgroundColor: const Color(0xFF0C1E2C),
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
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0xCC0C1E2C),
                              Color(0x660C1E2C),
                              Color(0x330C1E2C),
                              Color(0x990C1E2C),
                            ],
                          ),
                        ),
                      ),

                      // Navigation arrows (only show if multiple images)
                      if (_gallery.length > 1) ...[
                        // Left arrow
                        Positioned(
                          left: 10,
                          top: 0,
                          bottom: 0,
                          child: Center(
                            child: AnimatedOpacity(
                              opacity: _currentPage > 0 ? 1.0 : 0.0,
                              duration: const Duration(milliseconds: 300),
                              child: IconButton(
                                icon: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.4),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.arrow_back_ios,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                onPressed: _currentPage > 0
                                    ? () {
                                  _pageController.previousPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                }
                                    : null,
                              ),
                            ),
                          ),
                        ),

                        // Right arrow
                        Positioned(
                          right: 10,
                          top: 0,
                          bottom: 0,
                          child: Center(
                            child: AnimatedOpacity(
                              opacity: _currentPage < _gallery.length - 1 ? 1.0 : 0.0,
                              duration: const Duration(milliseconds: 300),
                              child: IconButton(
                                icon: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.4),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.arrow_forward_ios,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                onPressed: _currentPage < _gallery.length - 1
                                    ? () {
                                  _pageController.nextPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                }
                                    : null,
                              ),
                            ),
                          ),
                        ),
                      ],

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
                  if (_gallery.length > 1)
                    IconButton(
                      icon: const Icon(Icons.photo_library_outlined),
                      onPressed: () => _openGallery(0),
                      tooltip: 'View all images',
                    ),
                  // IconButton(
                  //   icon: const Icon(Icons.share, color: Colors.white),
                  //   onPressed: _sharePlayground,
                  // ),
                  IconButton(
                    icon: Icon(
                      _isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: _isFavorite ? Colors.redAccent : Colors.white,
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

              // Info section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _InfoChipRow(
                        rating: widget.playground['rating']?.toString() ?? '4.5',
                        opening: widget.playground['openingTime']?.toString() ?? '08:00',
                        closing: widget.playground['closingTime']?.toString() ?? '22:00',
                      ),
                      const SizedBox(height: 12),
                      _LocationRow(
                        location: widget.playground['location']?.toString() ?? 'Location not specified',
                      ),
                      const SizedBox(height: 16),
                      if ((widget.playground['description']?.toString() ?? '').isNotEmpty) ...[
                        const SectionTitle('About'),
                        const SizedBox(height: 12),
                        Text(
                          widget.playground['description']?.toString() ?? 'No description available',
                          style: const TextStyle(
                            color: Color(0xFF0C1E2C),
                            height: 1.5,
                            fontSize: 15,
                          ),
                        ),
                      ],
                      const SizedBox(height: 18),
                      if ((widget.playground['facilities'] as List?)?.isNotEmpty ?? false) ...[
                        const SectionTitle('Facilities'),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: ((widget.playground['facilities'] as List?) ?? [])
                              .map((f) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0C1E2C).withOpacity(0.06),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.black12.withOpacity(0.06)),
                            ),
                            child: Text(
                              f.toString(),
                              style: const TextStyle(
                                color: Color(0xFF0C1E2C),
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ))
                              .toList(),
                        ),
                      ],
                      const SizedBox(height: 10),
                      const SectionTitle('Available Courts'),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),

              // Courts list
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _CourtCard(
                        court: (widget.playground['courts'] as List)[index] as Map<String, dynamic>,
                        onTap: () {
                          final pgId = (widget.playground['_id'] ??
                              widget.playground['playgroundId'] ??
                              '')
                              .toString();
                          if (pgId.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Invalid playground id')),
                            );
                            return;
                          }
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => BookingSheet(
                              playgroundId: pgId,
                              courts: [(widget.playground['courts'] as List)[index]],
                            ),
                          );
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
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _BottomCTA(
              onPressed: () {
                final pgId = (widget.playground['_id'] ??
                    widget.playground['playgroundId'] ??
                    '')
                    .toString();
                if (pgId.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Invalid playground id')),
                  );
                  return;
                }
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => BookingSheet(
                    playgroundId: pgId,
                    courts: (widget.playground['courts'] as List?) ?? [],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _sharePlayground() {
    // TODO: implement share_plus or platform share
  }
}

// ===== Full screen gallery for user =====
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
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
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
          PageView.builder(
            controller: _pageController,
            physics: _isZoomed ? const NeverScrollableScrollPhysics() : const BouncingScrollPhysics(),
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
                _resetZoom();
              });
            },
            itemCount: widget.gallery.length,
            itemBuilder: (context, index) {
              return InteractiveViewer(
                transformationController: _transformationController,
                minScale: 0.5,
                maxScale: 4.0,
                onInteractionStart: (details) {
                  if (details.pointerCount > 1) {
                    setState(() {
                      _isZoomed = true;
                    });
                  }
                },
                onInteractionEnd: (details) {
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
                          color: const Color(0xFF0C1E2C),
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
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 18,
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
        color: (color ?? const Color(0xFF0C1E2C)).withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12.withOpacity(0.06)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: textColor ?? const Color(0xFF0C1E2C)),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: textColor ?? const Color(0xFF0C1E2C),
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
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
        const Icon(LucideIcons.mapPin, size: 16, color: Color(0xFF0C1E2C)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            location,
            style: const TextStyle(
              color: Color(0xFF0C1E2C),
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
          ),
        ),
        const Icon(Icons.directions, size: 20, color: Color(0xFF0C1E2C)),
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
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: Color(0xFF0C1E2C),
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 6))],
          border: Border.all(color: Colors.black12.withOpacity(0.05)),
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
                    const Icon(LucideIcons.wallet, size: 18, color: Color(0xFF0C1E2C)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _priceSummary(pricing),
                        style: const TextStyle(
                          color: Color(0xFF0C1E2C),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.black45),
                  ],
                ),
              ),
            ] else
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Text('No pricing available', style: TextStyle(color: Colors.grey)),
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
        color: const Color(0xFF0C1E2C).withOpacity(0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(LucideIcons.badgeCheck, size: 16, color: Color(0xFF0C1E2C)),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Color(0xFF0C1E2C),
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
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
        color: Colors.black.withOpacity(0.04),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(LucideIcons.layers, size: 14, color: Colors.black87),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w700),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(time, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w700)),
              const SizedBox(width: 8),
              const Text('•', style: TextStyle(color: Colors.red)),
              const SizedBox(width: 8),
              Text(price, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 2),
          const Text(
            'Pro-rated for shorter durations',
            style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class _BottomCTA extends StatelessWidget {
  const _BottomCTA({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 16, offset: const Offset(0, -6))],
      ),
      child: SafeArea(
        top: false,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0C1E2C),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 54),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 0,
          ),
          child: const Text(
            'Book Now',
            style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.2, fontSize: 16),
          ),
        ),
      ),
    );
  }
}