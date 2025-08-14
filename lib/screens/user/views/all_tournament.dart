import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:padel_pro/screens/user/user_controller/all_tournament_controller.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:padel_pro/utils/image_helper.dart';

class AllTournamentsScreen extends StatefulWidget {
  const AllTournamentsScreen({super.key});

  @override
  State<AllTournamentsScreen> createState() => _AllTournamentsScreenState();
}

class _AllTournamentsScreenState extends State<AllTournamentsScreen> {
  late final AllTournamentController controller;
  final RefreshController _refreshController = RefreshController();

  // Theme
  final Color pageBg = Colors.white;
  final Color cardColor = const Color(0xFF1E3354);
  final Color surfaceColor = const Color(0xFF233A61);
  final Color accentColor = const Color(0xFF4A80F0);
  final Color textOnDark = Colors.white;

  // Fallback asset
  final String fallbackAsset = '#';

  Timer? _autoTimer;

  @override
  void initState() {
    super.initState();
    controller = Get.put(AllTournamentController());

    controller.fetchAllTournaments();

    _autoTimer = Timer.periodic(const Duration(seconds: 10), (_) async {
      try {
        await controller.fetchAllTournaments();
      } catch (_) {}
    });
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    try {
      await controller.fetchAllTournaments();
      _refreshController.refreshCompleted();
    } catch (_) {
      _refreshController.refreshFailed();
      Get.snackbar(
        'Error',
        'Failed to refresh tournaments',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // ---------------- Helpers: images ----------------

  String _normalizeDynamicUrl(dynamic v) {
    if (v == null) return '';
    if (v is String) return _normalizeUrl(v);
    if (v is Map) {
      for (final k in const ['url', 'secure_url', 'uri', 'path', 'src', 'image']) {
        final val = v[k];
        if (val is String && val.trim().isNotEmpty) return _normalizeUrl(val);
      }
    }
    return '';
  }

  String _normalizeUrl(String raw) {
    var s = raw.trim();
    if (s.isEmpty) return '';
    s = Uri.encodeFull(s);
    if (!s.startsWith('http://') && !s.startsWith('https://')) {
      s = ImageHelper.getFullUrl(s);
    }
    return s;
  }

  // 👇 FIX: add `{BoxFit fit = BoxFit.cover}` so its type matches `Widget Function(String, {BoxFit fit})`
  Widget _coverImage(String urlOrPath, {BoxFit fit = BoxFit.cover}) {
    final safe = _normalizeUrl(urlOrPath);
    if (safe.isEmpty) {
      return Image.asset(fallbackAsset, fit: fit);
    }
    return FadeInImage(
      placeholder: AssetImage(fallbackAsset),
      image: NetworkImage(safe),
      fit: fit,
      imageErrorBuilder: (_, __, ___) => Image.asset(fallbackAsset, fit: fit),
      placeholderErrorBuilder: (_, __, ___) =>
          Container(color: Colors.white.withOpacity(0.05)),
    );
  }

  // ---------------- Helpers: date/time ----------------

  /// Fixes malformed ISO like `2025-0815T...` -> `2025-08-15T...`
  String _fixIsoDateString(String s) {
    final re = RegExp(r'^(\d{4})-(\d{2})(\d{2})T');
    final m = re.firstMatch(s);
    if (m != null) return s.replaceFirst(re, '${m.group(1)}-${m.group(2)}-${m.group(3)}T');
    return s;
  }

  DateTime? _parseDateTime(dynamic d, dynamic t) {
    final dateStrRaw = (d ?? '').toString().trim();
    final timeStr = (t ?? '').toString().trim();
    if (dateStrRaw.isEmpty && timeStr.isEmpty) return null;

    DateTime? date;
    try {
      if (dateStrRaw.isNotEmpty) {
        final fixed = _fixIsoDateString(dateStrRaw);
        date = DateTime.parse(fixed); // supports YYYY-MM-DD or ISO
      }
    } catch (_) {}

    if (date != null && timeStr.isNotEmpty) {
      try {
        final parts = timeStr.split(' ');
        final hm = parts.first;
        final ap = parts.length > 1 ? parts[1].toUpperCase() : null;
        final hmp = hm.split(':');
        int hh = int.tryParse(hmp[0]) ?? 0;
        final mm = (hmp.length > 1) ? int.tryParse(hmp[1]) ?? 0 : 0;

        if (ap == 'PM' && hh < 12) hh += 12;
        if (ap == 'AM' && hh == 12) hh = 0;

        date = DateTime(date.year, date.month, date.day, hh, mm);
      } catch (_) {}
    }
    return date;
  }

  String _fmtDate(DateTime dt) => DateFormat('MMM d, yyyy').format(dt.toLocal());
  String _fmtTime(DateTime dt) => DateFormat('HH:mm').format(dt.toLocal());

  String _humanReadableDateTime(String d, String t) {
    final dt = _parseDateTime(d, t);
    if (dt != null) {
      final includeTime = t.trim().isNotEmpty || d.contains('T');
      return includeTime ? '${_fmtDate(dt)} • ${_fmtTime(dt)}' : _fmtDate(dt);
    }
    if (d.contains('T')) return d.split('T').first;
    final s = [d, t].where((e) => e.trim().isNotEmpty).join(' • ');
    return s.isEmpty ? '—' : s;
  }

  String _buildDateRange({
    required String startDate,
    required String startTime,
    required String endDate,
    required String endTime,
  }) {
    final sdt = _parseDateTime(startDate, startTime);
    final edt = _parseDateTime(endDate, endTime);

    String fmt(DateTime? dt, String d, String t) {
      if (dt == null) return _humanReadableDateTime(d, t);
      final includeTime = t.trim().isNotEmpty || d.contains('T');
      return includeTime ? '${_fmtDate(dt)} • ${_fmtTime(dt)}' : _fmtDate(dt);
    }

    if (sdt == null && edt == null) return 'Date/Time TBA';
    if (sdt != null && edt != null) return '${fmt(sdt, startDate, startTime)}  →  ${fmt(edt, endDate, endTime)}';
    if (sdt != null) return fmt(sdt, startDate, startTime);
    return fmt(edt, endDate, endTime);
  }

  // ---------------- Helpers: open link ----------------

  Future<void> _launchUrl(String url) async {
    final trimmed = url.trim();
    if (trimmed.isEmpty) return;
    final uri = Uri.tryParse(trimmed.startsWith('http') ? trimmed : 'https://$trimmed');
    if (uri == null) {
      Get.snackbar('Invalid link', 'Could not parse registration link.',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok) {
      Get.snackbar('Unable to open', 'Could not open the registration link.',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  // ---------------- Build ----------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBg,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('All Tournaments', style: TextStyle(color: Colors.white)),
        backgroundColor: cardColor,
        elevation: 0,
        centerTitle: true,
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
              ? _emptyState()
              : ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            itemCount: controller.tournaments.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final t = controller.tournaments[index];

              final String name = (t['name'] ?? 'Untitled Tournament').toString();
              final String location = (t['location'] ?? 'No location').toString();
              final String type = (t['tournamentType'] ?? 'Type N/A').toString();

              // Supports string or map; relative paths resolved
              final String cover = _normalizeDynamicUrl(t['photo'] ?? t['coverPhoto']);

              final String startDate = (t['startDate'] ?? '').toString();
              final String startTime = (t['startTime'] ?? '').toString();
              final String endDate = (t['endDate'] ?? '').toString();
              final String endTime = (t['endTime'] ?? '').toString();
              final String registrationLink = (t['registrationLink'] ?? '').toString();

              final statusMeta = _derivedStatus(t);
              final displayDate = _buildDateRange(
                startDate: startDate,
                startTime: startTime,
                endDate: endDate,
                endTime: endTime,
              );

              return _TournamentPostCard(
                index: index,
                coverUrl: cover,
                title: name,
                location: location,
                dateTime: displayDate,
                type: type,
                registrationLink: registrationLink,
                statusMeta: statusMeta,
                cardColor: cardColor,
                surfaceColor: surfaceColor,
                textOnDark: textOnDark,
                onTap: () => _showDetailsDialog(context, t, statusMeta),
                onRegisterTap: () => _launchUrl(registrationLink),
                coverBuilder: _coverImage, // now matches the expected type
              );
            },
          ),
        );
      }),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.emoji_events, size: 60, color: Colors.black.withOpacity(0.25)),
          const SizedBox(height: 16),
          Text(
            'No tournaments found',
            style: TextStyle(
              color: Colors.black.withOpacity(0.6),
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Status helper ----------

  _StatusMeta _derivedStatus(Map t) {
    final raw = (t['status'] ?? '').toString().trim().toLowerCase();
    if (raw == 'cancelled') return _StatusMeta('Cancelled', const Color(0xFFEF4444));

    final start = _parseDateTime(t['startDate'], t['startTime']);
    final end = _parseDateTime(t['endDate'], t['endTime']);
    final now = DateTime.now();

    if (start == null) {
      switch (raw) {
        case 'active':
          return _StatusMeta('Active', const Color(0xFF22C55E));
        case 'completed':
          return _StatusMeta('Completed', const Color(0xFF3B82F6));
        case 'upcoming':
          return _StatusMeta('Upcoming', const Color(0xFFF59E0B));
        default:
          return const _StatusMeta('Unknown', Colors.grey);
      }
    }

    if (now.isBefore(start)) return _StatusMeta('Upcoming', const Color(0xFFF59E0B));
    if (end != null) {
      if (now.isAfter(end)) return _StatusMeta('Completed', const Color(0xFF3B82F6));
      return _StatusMeta('Active', const Color(0xFF22C55E));
    } else {
      final sameDay = now.year == start.year && now.month == start.month && now.day == start.day;
      return sameDay
          ? _StatusMeta('Active', const Color(0xFF22C55E))
          : (now.isAfter(start) ? _StatusMeta('Completed', const Color(0xFF3B82F6)) : _StatusMeta('Upcoming', const Color(0xFFF59E0B)));
    }
  }

  // ---------- Details dialog ----------

  void _showDetailsDialog(BuildContext context, Map t, _StatusMeta statusMeta) {
    final size = MediaQuery.of(context).size;
    double dialogW = size.width * 0.92;
    double dialogH = size.height * 0.9;
    if (dialogW > 900) dialogW = 900;

    final String title = (t['name'] ?? 'Untitled Tournament').toString();
    final String cover = _normalizeDynamicUrl(t['photo'] ?? t['coverPhoto']);
    final String location = (t['location'] ?? 'No location').toString();
    final String description = (t['description'] ?? 'No description provided.').toString();
    final String type = (t['tournamentType'] ?? 'Type N/A').toString();
    final String startDate = (t['startDate'] ?? '').toString();
    final String startTime = (t['startTime'] ?? '').toString();
    final String endDate = (t['endDate'] ?? '').toString();
    final String endTime = (t['endTime'] ?? '').toString();
    final String registrationLink = (t['registrationLink'] ?? '').toString();

    final dateRange = _buildDateRange(
      startDate: startDate,
      startTime: startTime,
      endDate: endDate,
      endTime: endTime,
    );

    final scroll = ScrollController();

    Get.dialog(
      Dialog(
        backgroundColor: cardColor,
        insetPadding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: SizedBox(
          width: dialogW,
          height: dialogH,
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 8, 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    _statusChip(statusMeta.label, statusMeta.color),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.close, color: Colors.white70),
                    ),
                  ],
                ),
              ),

              // Body
              Expanded(
                child: Scrollbar(
                  controller: scroll,
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    controller: scroll,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Cover
                        ClipRRect(
                          borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                          child: Stack(
                            children: [
                              AspectRatio(aspectRatio: 16 / 9, child: _coverImage(cover)),
                              Positioned.fill(
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [Colors.transparent, Colors.black.withOpacity(0.55)],
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 16,
                                bottom: 12,
                                child: Row(
                                  children: [
                                    const Icon(Icons.calendar_today_rounded, size: 16, color: Colors.white),
                                    const SizedBox(width: 8),
                                    Text(dateRange, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Info grid
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                          child: Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              _infoTile(icon: Icons.place, label: 'Location', value: location),
                              _infoTile(icon: Icons.category, label: 'Type', value: type),
                              _infoTile(icon: Icons.access_time, label: 'Start', value: _humanReadableDateTime(startDate, startTime)),
                              if (endDate.trim().isNotEmpty || endTime.trim().isNotEmpty)
                                _infoTile(icon: Icons.timelapse, label: 'End', value: _humanReadableDateTime(endDate, endTime)),
                              _infoTile(
                                icon: Icons.link,
                                label: 'Fill Form / Registration',
                                value: registrationLink.trim().isEmpty ? '—' : registrationLink.trim(),
                              ),
                            ],
                          ),
                        ),

                        // Description
                        if (description.trim().isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text('About',
                                style: TextStyle(color: Colors.white.withOpacity(0.95), fontSize: 16, fontWeight: FontWeight.w700)),
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(description, style: const TextStyle(color: Colors.white70, height: 1.45, fontSize: 14.5)),
                          ),
                        ],

                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),

              // Footer actions (Register + Close)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
                child: Row(
                  children: [
                    if (registrationLink.trim().isNotEmpty)
                      ElevatedButton.icon(
                        onPressed: () => _launchUrl(registrationLink),
                        icon: const Icon(Icons.open_in_new),
                        label: const Text('Register'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                    const Spacer(),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('Close'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      barrierColor: Colors.black.withOpacity(0.55),
    );
  }

  // ---------- UI bits ----------

  Widget _statusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.92),
        borderRadius: BorderRadius.circular(999),
        boxShadow: [BoxShadow(color: color.withOpacity(0.35), blurRadius: 10, offset: const Offset(0, 6))],
      ),
      child: Row(
        children: [
          const Icon(Icons.circle, size: 8, color: Colors.white),
          const SizedBox(width: 6),
          Text(label.toUpperCase(),
              style: const TextStyle(color: Colors.white, fontSize: 11.5, letterSpacing: 0.4, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  Widget _infoTile({required IconData icon, required String label, required String value}) {
    return Container(
      constraints: const BoxConstraints(minWidth: 160),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: Colors.white70),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label.toUpperCase(), style: const TextStyle(color: Colors.white54, fontSize: 11, letterSpacing: 0.4)),
              const SizedBox(height: 2),
              Text(value.isEmpty ? '—' : value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _coverFallback() {
    return Container(
      color: Colors.white.withOpacity(0.08),
      child: Center(child: Icon(Icons.emoji_events, size: 48, color: Colors.white.withOpacity(0.8))),
    );
  }
}

// ---------- Card widget (social post) ----------

class _TournamentPostCard extends StatelessWidget {
  const _TournamentPostCard({
    required this.index,
    required this.coverUrl,
    required this.title,
    required this.location,
    required this.dateTime,
    required this.type,
    required this.registrationLink,
    required this.statusMeta,
    required this.cardColor,
    required this.surfaceColor,
    required this.textOnDark,
    required this.coverBuilder,
    this.onTap,
    this.onRegisterTap,
  });

  final int index;
  final String coverUrl;
  final String title;
  final String location;
  final String dateTime;
  final String type;
  final String registrationLink;
  final _StatusMeta statusMeta;
  final Color cardColor;
  final Color surfaceColor;
  final Color textOnDark;
  final Widget Function(String url, {BoxFit fit}) coverBuilder; // expects named fit
  final VoidCallback? onTap;
  final VoidCallback? onRegisterTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 14, offset: const Offset(0, 10))],
        border: Border.all(color: Colors.black.withOpacity(0.04)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cover + gradient + status + title
                Hero(
                  tag: 'tournament-image-$index',
                  child: Stack(
                    children: [
                      AspectRatio(aspectRatio: 16 / 9, child: coverBuilder(coverUrl, fit: BoxFit.cover)),
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.05),
                                Colors.black.withOpacity(0.35),
                                Colors.black.withOpacity(0.6),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(left: 12, top: 12, child: _statusChip(statusMeta.label, statusMeta.color)),
                      Positioned(
                        left: 16,
                        right: 16,
                        bottom: 14,
                        child: Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: textOnDark, fontSize: 20, fontWeight: FontWeight.w800, height: 1.2),
                        ),
                      ),
                    ],
                  ),
                ),

                // Details
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _infoRow(Icons.location_on, location),
                      const SizedBox(height: 8),
                      _infoRow(Icons.calendar_today_rounded, dateTime),
                      const SizedBox(height: 8),
                      if (registrationLink.trim().isNotEmpty)
                        _infoRow(Icons.link, 'Fill Form / Registration: ${registrationLink.trim()}'),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _pillChip(icon: Icons.category, label: type),
                          _pillChip(icon: Icons.sports_tennis, label: 'Tournament'),
                        ],
                      ),
                    ],
                  ),
                ),

                // Footer (Register + View)
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
                  child: Row(
                    children: [
                      if (registrationLink.trim().isNotEmpty)
                        ElevatedButton.icon(
                          onPressed: onRegisterTap,
                          icon: const Icon(Icons.open_in_new, size: 16),
                          label: const Text('Register', style: TextStyle(fontSize: 13)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: surfaceColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withOpacity(0.06)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.visibility, size: 16, color: Colors.white70),
                            SizedBox(width: 6),
                            Text('View details', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                          ],
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
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.white.withOpacity(0.85)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14.5,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }

  Widget _pillChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.14)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white.withOpacity(0.95)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.92),
        borderRadius: BorderRadius.circular(999),
        boxShadow: [BoxShadow(color: color.withOpacity(0.35), blurRadius: 10, offset: Offset(0, 6))],
      ),
      child: Row(
        children: [
          const Icon(Icons.circle, size: 8, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11.5,
              letterSpacing: 0.4,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusMeta {
  final String label;
  final Color color;
  const _StatusMeta(this.label, this.color);
}
