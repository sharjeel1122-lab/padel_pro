import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:intl/intl.dart'; // <-- date formatting
import 'package:url_launcher/url_launcher.dart'; // <-- added

import 'package:padel_pro/screens/vendor/tournament/create_tournment_controller.dart';
import 'package:padel_pro/screens/vendor/tournament/tournament_create_screen.dart';
import 'package:padel_pro/screens/vendor/tournament/vendor_view_tournament_controller.dart';
import 'package:padel_pro/services/vendors api/delete_vendor_tournament_api.dart';
import 'package:padel_pro/services/vendors api/update_vendor_tournament_api.dart';
import 'package:padel_pro/utils/image_helper.dart';

class VendorTournamentsScreen extends StatefulWidget {
  const VendorTournamentsScreen({super.key});

  @override
  State<VendorTournamentsScreen> createState() => _VendorTournamentsScreenState();
}

class _VendorTournamentsScreenState extends State<VendorTournamentsScreen> {
  final controller = Get.put(VendorTournamentController(), permanent: true);
  final createController = Get.put(CreateTournamentController(), permanent: true);
  final RefreshController _refreshController = RefreshController();

  Timer? _autoRefreshTimer;
  bool _deleting = false;

  // Theme
  final Color primaryColor = const Color(0xFF0C1E2C);
  final Color cardColor = const Color(0xFF101c2b);
  final Color surfaceColor = const Color(0xFF152338);
  final Color accentColor = const Color(0xFF4A80F0);

  // Fallback asset
  final String fallbackAsset = 'assets/tournament_image.png';

  @override
  void initState() {
    super.initState();
    if (controller.tournaments.isEmpty) {
      // ignore: unawaited_futures
      controller.fetchVendorTournaments();
    }
    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 10), (_) async {
      if (_deleting) return;
      try {
        await controller.fetchVendorTournaments();
      } catch (_) {}
    });
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    try {
      await controller.fetchVendorTournaments();
      _refreshController.refreshCompleted();
    } catch (_) {
      _refreshController.refreshFailed();
      Get.snackbar('Error', 'Failed to refresh tournaments',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

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
          return _StatusMeta('Unknown', Colors.grey);
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
          : (now.isAfter(start)
          ? _StatusMeta('Completed', const Color(0xFF3B82F6))
          : _StatusMeta('Upcoming', const Color(0xFFF59E0B)));
    }
  }

  // --- Date/Time helpers & formatting ---

  /// Fixes malformed ISO like `2025-0815T...` -> `2025-08-15T...`
  String _fixIsoDateString(String s) {
    final re = RegExp(r'^(\d{4})-(\d{2})(\d{2})T');
    final m = re.firstMatch(s);
    if (m != null) {
      return s.replaceFirst(re, '${m.group(1)}-${m.group(2)}-${m.group(3)}T');
    }
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
        date = DateTime.parse(fixed);
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

  // ======================= IMAGE HELPERS (UPDATED) =======================

  String _getCoverUrlFromTournament(Map t) {
    final candidates = [t['photo'], t['coverPhoto'], t['image'], t['cover']];
    for (final c in candidates) {
      final u = _normalizeDynamicUrl(c);
      if (u.isNotEmpty) return u;
    }
    return '';
  }

  String _normalizeDynamicUrl(dynamic v) {
    if (v == null) return '';
    if (v is String) return _normalizeUrl(v);
    if (v is Map) {
      for (final k in ['url', 'uri', 'path']) {
        final val = v[k];
        if (val is String && val.trim().isNotEmpty) {
          return _normalizeUrl(val);
        }
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

  Widget _coverImage(String url, {BoxFit fit = BoxFit.cover}) {
    final safe = _normalizeUrl(url);
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

  // ======================================================================

  // Open external link (registration form)
  Future<void> _openExternalLink(String url) async {
    var link = url.trim();
    if (link.isEmpty) return;
    if (!link.startsWith('http://') && !link.startsWith('https://')) {
      link = 'https://$link';
    }
    final uri = Uri.parse(link);
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok) {
      Get.snackbar('Could not open link', link,
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> _confirmAndDeleteTournament(String tournamentId) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: cardColor,
        title: const Text('Delete Tournament?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to permanently delete this tournament? This action cannot be undone.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('No', style: TextStyle(color: Colors.white))),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Yes, delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      barrierDismissible: true,
    );

    if (confirmed != true) return;

    try {
      _deleting = true;

      final before = controller.tournaments.length;
      controller.tournaments.removeWhere((x) => (x['_id'] ?? '').toString() == tournamentId);
      controller.tournaments.refresh();
      final removedCount = before - controller.tournaments.length;

      final api = DeleteVendorTournamentApi();
      final ok = await api.deleteTournament(tournamentId);

      if (ok) {
        Get.snackbar('Deleted', 'Tournament deleted successfully',
            backgroundColor: Colors.green, colorText: Colors.white);
        // ignore: unawaited_futures
        controller.fetchVendorTournaments();
      } else {
        if (removedCount > 0) {
          await controller.fetchVendorTournaments();
        }
        Get.snackbar('Error', 'Delete failed on server.',
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      await controller.fetchVendorTournaments();
      Get.snackbar('Error', e.toString().replaceAll('Exception: ', ''),
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      _deleting = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('My Tournaments', style: TextStyle(color: Colors.white)),
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () => Get.to(() => CreateTournamentScreen()),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.tournaments.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
              final String cover = _getCoverUrlFromTournament(t);
              final String id = (t['_id'] ?? '').toString();
              final String name = (t['name'] ?? 'Untitled Tournament').toString();
              final String location = (t['location'] ?? 'No location').toString();
              final String tournamentType = (t['tournamentType'] ?? 'Type N/A').toString();
              final String startDate = (t['startDate'] ?? '').toString();
              final String startTime = (t['startTime'] ?? '').toString();
              final String endDate = (t['endDate'] ?? '').toString();
              final String endTime = (t['endTime'] ?? '').toString();
              final String registrationLink = (t['registrationLink'] ?? '').toString();

              final derived = _derivedStatus(t);
              final displayDate = _buildDateRange(
                startDate: startDate,
                startTime: startTime,
                endDate: endDate,
                endTime: endTime,
              );

              return _TournamentPostCard(
                key: ValueKey(id),
                index: index,
                coverUrl: cover,
                title: name,
                location: location,
                dateTime: displayDate,
                type: tournamentType,
                statusMeta: derived,
                primaryColor: primaryColor,
                cardColor: cardColor,
                surfaceColor: surfaceColor,
                accentColor: accentColor,
                registrationLink: registrationLink,
                onTap: () => _showDetailsDialog(context, t, derived),
                onEdit: () => _openEditDialog(context, t),
                onShare: () {},
                onDelete: () => _confirmAndDeleteTournament(id),
                coverBuilder: _coverImage,
              );
            },
          ),
        );
      }),
    );
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

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.emoji_events, size: 60, color: Colors.white.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text('No tournaments found',
              style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 18)),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Get.to(() => CreateTournamentScreen()),
            child: const Text('Create your first tournament'),
          ),
        ],
      ),
    );
  }

  void _showDetailsDialog(BuildContext context, Map t, _StatusMeta statusMeta) {
    final size = MediaQuery.of(context).size;
    double dialogW = size.width * 0.9;
    double dialogH = size.height * 0.9;
    if (dialogW > 900) dialogW = 900;

    final String title = (t['name'] ?? 'Untitled Tournament').toString();
    final String cover = _getCoverUrlFromTournament(t);
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
                    IconButton(onPressed: () => Get.back(), icon: const Icon(Icons.close, color: Colors.white70)),
                  ],
                ),
              ),
              Expanded(
                child: Scrollbar(
                  controller: scroll,
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    controller: scroll,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
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
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                          child: Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              _infoTile(icon: Icons.place, label: 'Location', value: location),
                              _infoTile(icon: Icons.category, label: 'Type', value: type),
                              _infoTile(
                                icon: Icons.access_time,
                                label: 'Start',
                                value: _humanReadableDateTime(startDate, startTime),
                              ),
                              if (endDate.trim().isNotEmpty || endTime.trim().isNotEmpty)
                                _infoTile(
                                  icon: Icons.timelapse,
                                  label: 'End',
                                  value: _humanReadableDateTime(endDate, endTime),
                                ),
                              // Clickable registration link tile
                              _infoTile(
                                icon: Icons.link,
                                label: 'Fill Form / Registration',
                                value: registrationLink.trim().isEmpty ? '—' : registrationLink.trim(),
                                onTap: registrationLink.trim().isEmpty
                                    ? null
                                    : () => _openExternalLink(registrationLink),
                                isLink: true,
                              ),
                            ],
                          ),
                        ),
                        if (description.trim().isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text('About',
                                style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 16, fontWeight: FontWeight.w700)),
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
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
                child: Row(
                  children: [
                    _footerButton(icon: Icons.edit_outlined, label: 'Manage', onTap: () {
                      Get.back();
                      _openEditDialog(context, t);
                    }),
                    const SizedBox(width: 8),
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
      barrierColor: Colors.black.withOpacity(0.65),
    );
  }

  // ====== EDIT DIALOG ======
  void _openEditDialog(BuildContext context, Map t) {
    final String id = (t['_id'] ?? '').toString();

    final nameC = TextEditingController(text: (t['name'] ?? '').toString());
    final regLinkC = TextEditingController(text: (t['registrationLink'] ?? '').toString());
    final typeC = TextEditingController(text: (t['tournamentType'] ?? '').toString());
    final locationC = TextEditingController(text: (t['location'] ?? '').toString());
    final startDateC = TextEditingController(text: (t['startDate'] ?? '').toString());
    final startTimeC = TextEditingController(text: (t['startTime'] ?? '').toString());
    final descC = TextEditingController(text: (t['description'] ?? '').toString());

    File? pickedPhoto;
    bool saving = false;

    String? _changed(String key, String newVal) {
      final oldVal = (t[key] ?? '').toString();
      return (newVal.trim() != oldVal.trim()) ? newVal.trim() : null;
    }

    Get.dialog(
      StatefulBuilder(
        builder: (ctx, setState) {
          Future<void> pickImage() async {
            try {
              final XFile? x =
              await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 80);
              if (x != null) {
                pickedPhoto = File(x.path);
                setState(() {});
              }
            } catch (_) {}
          }

          Future<void> pickDate() async {
            final base = DateTime.tryParse(_fixIsoDateString(startDateC.text));
            final initial = (base == null || base.isBefore(DateTime.now()))
                ? DateTime.now().add(const Duration(days: 1))
                : base;
            final d = await showDatePicker(
              context: ctx,
              initialDate: initial!,
              firstDate: DateTime.now().add(const Duration(days: 1)),
              lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
              builder: (c, child) => Theme(
                data: Theme.of(c).copyWith(
                  colorScheme: ColorScheme.dark(
                      primary: accentColor, surface: cardColor, onSurface: Colors.white),
                  dialogBackgroundColor: cardColor,
                ),
                child: child!,
              ),
            );
            if (d != null) {
              startDateC.text = d.toIso8601String().substring(0, 10); // YYYY-MM-DD
              setState(() {});
            }
          }

          Future<void> pickTime() async {
            final now = TimeOfDay.now();
            final tOfDay = await showTimePicker(
              context: ctx,
              initialTime: TimeOfDay(hour: now.hour, minute: now.minute),
              builder: (c, child) => Theme(
                data: Theme.of(c).copyWith(
                  colorScheme: ColorScheme.dark(
                      primary: accentColor, surface: cardColor, onSurface: Colors.white),
                  dialogBackgroundColor: cardColor,
                ),
                child: child!,
              ),
            );
            if (tOfDay != null) {
              final hh = tOfDay.hour.toString().padLeft(2, '0');
              final mm = tOfDay.minute.toString().padLeft(2, '0');
              startTimeC.text = "$hh:$mm"; // 24h as backend expects
              setState(() {});
            }
          }

          Future<void> doSave() async {
            if (saving) return;

            final name = _changed('name', nameC.text);
            final registrationLink = _changed('registrationLink', regLinkC.text);
            final tournamentType = _changed('tournamentType', typeC.text);
            final location = _changed('location', locationC.text);
            final startDate = _changed('startDate', startDateC.text);
            final startTime = _changed('startTime', startTimeC.text);
            final description = _changed('description', descC.text);

            final hasChanges = pickedPhoto != null ||
                [name, registrationLink, tournamentType, location, startDate, startTime, description]
                    .any((e) => e != null && e.isNotEmpty);

            if (!hasChanges) {
              Get.snackbar('No changes', 'You have not modified any field.');
              return;
            }

            try {
              setState(() => saving = true);
              final api = UpdateVendorTournamentApi();
              await api.updateTournament(
                id: id,
                name: name,
                registrationLink: registrationLink,
                tournamentType: tournamentType,
                location: location,
                startDate: startDate,
                startTime: startTime,
                description: description,
                photoFile: pickedPhoto,
              );

              Get.back(); // close dialog
              Get.snackbar('Saved', 'Tournament updated successfully',
                  backgroundColor: Colors.green, colorText: Colors.white);
              await controller.fetchVendorTournaments();
            } catch (e) {
              setState(() => saving = false);
              Get.snackbar('Error', e.toString().replaceAll('Exception: ', ''),
                  backgroundColor: Colors.red, colorText: Colors.white);
            }
          }

          return Dialog(
            backgroundColor: cardColor,
            insetPadding: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.edit_outlined, color: Colors.white),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text('Edit Tournament',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                          ),
                          IconButton(
                              onPressed: () => Get.back(),
                              icon: const Icon(Icons.close, color: Colors.white70)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Divider(color: Colors.white.withOpacity(0.08), height: 1),

                      const SizedBox(height: 16),

                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              width: 110,
                              height: 72,
                              color: surfaceColor,
                              child: pickedPhoto != null
                                  ? Image.file(pickedPhoto!, fit: BoxFit.cover)
                                  : _coverImage(_getCoverUrlFromTournament(t), fit: BoxFit.cover),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            onPressed: saving ? null : () async { await pickImage(); },
                            icon: const Icon(Icons.image_outlined),
                            label: const Text('Change photo'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accentColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      _field(label: 'Name', controller: nameC),
                      _field(label: 'Registration Link', controller: regLinkC, keyboardType: TextInputType.url),
                      _field(label: 'Tournament Type', controller: typeC),
                      _field(label: 'Location', controller: locationC),

                      Row(
                        children: [
                          Expanded(
                            child: _field(
                              label: 'Start Date (YYYY-MM-DD)',
                              controller: startDateC,
                              suffix: IconButton(
                                icon: const Icon(Icons.date_range, color: Colors.white70),
                                onPressed: saving ? null : () async { await pickDate(); },
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _field(
                              label: 'Start Time (HH:mm)',
                              controller: startTimeC,
                              suffix: IconButton(
                                icon: const Icon(Icons.access_time, color: Colors.white70),
                                onPressed: saving ? null : () async { await pickTime(); },
                              ),
                            ),
                          ),
                        ],
                      ),
                      _field(label: 'Description', controller: descC, maxLines: 3),

                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: saving ? null : () => Get.back(),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.white.withOpacity(0.22)),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: saving ? null : doSave,
                              icon: saving
                                  ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white))
                                  : const Icon(Icons.save_outlined),
                              label: Text(saving ? 'Saving...' : 'Save'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: accentColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
      barrierColor: Colors.black.withOpacity(0.65),
    );
  }

  // Reusable field
  Widget _field({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    int maxLines = 1,
    Widget? suffix,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          filled: true,
          fillColor: surfaceColor,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide(color: Colors.white),
          ),
          suffixIcon: suffix,
        ),
      ),
    );
  }

  // Now supports clickable value (for links)
  Widget _infoTile({
    required IconData icon,
    required String label,
    required String value,
    VoidCallback? onTap,
    bool isLink = false,
  }) {
    final bool clickable = onTap != null && value.trim().isNotEmpty;
    final textWidget = Text(
      value.isEmpty ? '—' : value,
      style: TextStyle(
        color: clickable && isLink ? accentColor : Colors.white,
        fontWeight: FontWeight.w600,
        decoration: clickable && isLink ? TextDecoration.underline : TextDecoration.none,
      ),
    );

    return Container(
      constraints: const BoxConstraints(minWidth: 160),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
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
              clickable ? InkWell(onTap: onTap, child: textWidget) : textWidget,
            ],
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
        boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: Row(
        children: [
          const Icon(Icons.circle, size: 8, color: Colors.white),
          const SizedBox(width: 6),
          Text(label.toUpperCase(),
              style: const TextStyle(
                  color: Colors.white, fontSize: 11.5, letterSpacing: 0.4, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  Widget _footerButton({required IconData icon, required String label, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Row(
          children: [
            Icon(icon, size: 18, color: Colors.white.withOpacity(0.9)),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _TournamentPostCard extends StatelessWidget {
  const _TournamentPostCard({
    super.key,
    required this.index,
    required this.coverUrl,
    required this.title,
    required this.location,
    required this.dateTime,
    required this.type,
    required this.statusMeta,
    required this.primaryColor,
    required this.cardColor,
    required this.surfaceColor,
    required this.accentColor,
    required this.registrationLink,
    this.onTap,
    this.onShare,
    this.onEdit,
    this.onDelete,
    required this.coverBuilder,
  });

  final int index;
  final String coverUrl;
  final String title;
  final String location;
  final String dateTime;
  final String type;
  final String registrationLink;
  final _StatusMeta statusMeta;
  final Color primaryColor;
  final Color cardColor;
  final Color surfaceColor;
  final Color accentColor;
  final VoidCallback? onTap;
  final VoidCallback? onShare;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final Widget Function(String url, {BoxFit fit}) coverBuilder;

  Future<void> _launchLink(String url) async {
    var link = url.trim();
    if (link.isEmpty) return;
    if (!link.startsWith('http://') && !link.startsWith('https://')) {
      link = 'https://$link';
    }
    final uri = Uri.parse(link);
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok) {
      Get.snackbar('Unable to open link', link,
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.35), blurRadius: 16, offset: const Offset(0, 10))],
        border: Border.all(color: Colors.white.withOpacity(0.04)),
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
                        right: 4,
                        top: 0,
                        child: PopupMenuButton<String>(
                          icon: const Icon(Icons.more_horiz, color: Colors.white),
                          onSelected: (v) {
                            switch (v) {
                              case 'share':
                                onShare?.call();
                                break;
                              case 'edit':
                                onEdit?.call();
                                break;
                              case 'delete':
                                onDelete?.call();
                                break;
                            }
                          },
                          itemBuilder: (context) => [
                            if (onShare != null)
                              const PopupMenuItem(
                                value: 'share',
                                child: ListTile(leading: Icon(Icons.share_outlined), title: Text('Share')),
                              ),
                            if (onEdit != null)
                              const PopupMenuItem(
                                value: 'edit',
                                child: ListTile(leading: Icon(Icons.edit_outlined), title: Text('Manage')),
                              ),
                            PopupMenuItem(
                              value: 'delete',
                              enabled: onDelete != null,
                              child: ListTile(
                                leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                title: Text('Delete',
                                    style: TextStyle(color: onDelete == null ? Colors.grey : Colors.redAccent)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        left: 16,
                        right: 16,
                        bottom: 14,
                        child: Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800, height: 1.2),
                        ),
                      ),
                    ],
                  ),
                ),
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
                        InkWell(
                          onTap: () => _launchLink(registrationLink),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.link, size: 18, color: Colors.white.withOpacity(0.8)),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Fill Form / Registration: ${registrationLink.trim()}',
                                  style: TextStyle(
                                    color: accentColor,
                                    decoration: TextDecoration.underline,
                                    fontSize: 14.5,
                                    height: 1.35,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
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
                Divider(height: 1, thickness: 1, color: Colors.white.withOpacity(0.06)),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 6, 8, 10),
                  child: Row(
                    children: [
                      _footerAction(icon: Icons.edit_outlined, label: 'Manage', onTap: onEdit),
                      const Spacer(),
                      _footerAction(icon: Icons.delete_outline, label: 'Delete', onTap: onDelete),
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
        Icon(icon, size: 18, color: Colors.white.withOpacity(0.8)),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 14.5, height: 1.35))),
      ],
    );
  }

  Widget _pillChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white.withOpacity(0.9)),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _footerAction({required IconData icon, required String label, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 18, color: Colors.white.withOpacity(0.9)),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _statusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.92),
        borderRadius: BorderRadius.circular(999),
        boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: Row(
        children: [
          const Icon(Icons.circle, size: 8, color: Colors.white),
          const SizedBox(width: 6),
          Text(label.toUpperCase(),
              style: const TextStyle(
                  color: Colors.white, fontSize: 11.5, letterSpacing: 0.4, fontWeight: FontWeight.w800)),
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
