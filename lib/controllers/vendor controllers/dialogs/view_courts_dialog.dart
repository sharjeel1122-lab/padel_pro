import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:padel_pro/services/vendors%20api/fetch_club_courts_api.dart';
import 'package:padel_pro/services/vendors%20api/create_club_courts_api.dart';
import 'package:padel_pro/controllers/vendor controllers/dialogs/add_court_dialog.dart';
import 'package:padel_pro/controllers/vendor controllers/dialogs/edit_court_dialog.dart';

class ViewCourtsDialog {
  static void show(
    Map<String, dynamic> club,
    List<dynamic> courts,
    FetchVendorApi fetchVendorApi,
    CreateVendorApi vendorApi,
    VoidCallback onRefresh,
    Function(List<Map<String, dynamic>>) onCourtsUpdated,
  ) {
    final pageCtrl = ScrollController();
    final clubId = (club['_id'] ?? '').toString();
    final RxList<Map<String, dynamic>> currentCourts = <Map<String, dynamic>>[
      ...courts.map((e) => Map<String, dynamic>.from(e as Map))
    ].obs;

    Timer? viewCourtsTimer;

    viewCourtsTimer = Timer.periodic(const Duration(seconds: 10), (_) async {
      try {
        final data = await fetchVendorApi.getVendorPlaygrounds();
        final list = List<Map<String, dynamic>>.from(data);
        final updatedClub = list.firstWhere(
          (p) => (p['_id'] ?? '').toString() == clubId,
          orElse: () => const {},
        );

        final updatedCourts = (updatedClub['courts'] as List? ?? [])
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();

        if (updatedCourts.length != currentCourts.length ||
            !_listDeepEquals(updatedCourts, currentCourts)) {
          currentCourts.assignAll(updatedCourts);
          onCourtsUpdated(updatedCourts);
        }
      } catch (e) {
        debugPrint('viewCourts refresh error: $e');
      }
    });

    Get.dialog(
      Dialog(
        backgroundColor: const Color(0xFF0C1E2C),
        insetPadding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Obx(() {
          final itemCount = currentCourts.length;

          final size = MediaQuery.of(Get.context!).size;
          final isPhone = size.width < 600;
          final dialogW = isPhone
              ? size.width - 24
              : ((size.width).clamp(640.0, 1200.0) as double) - 24;
          final dialogH = isPhone ? size.height * 0.96 : size.height * 0.9;

          return SafeArea(
            child: SizedBox(
              width: dialogW,
              height: dialogH,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.sports_tennis,
                          color: Colors.white,
                          size: 26,
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Available Courts',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // ✅ Add Court
                        IconButton(
                          tooltip: 'Add Court',
                          onPressed: () {
                            AddCourtDialog.show(
                              clubId,
                              vendorApi,
                              () async {
                                onRefresh();
                                // refresh the local list inside the dialog
                                final updated = await fetchVendorApi.getVendorPlaygrounds();
                                final updatedClub = updated.firstWhere(
                                  (c) => (c['_id'] ?? '') == club['_id'],
                                  orElse: () => {},
                                );
                                final updatedCourts =
                                    (updatedClub['courts'] as List? ?? [])
                                        .map(
                                          (e) => Map<String, dynamic>.from(
                                        e as Map,
                                      ),
                                    )
                                        .toList();
                                currentCourts.assignAll(updatedCourts);
                                onCourtsUpdated(updatedCourts);
                              },
                            );
                          },
                          icon: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        IconButton(
                          tooltip: 'Close',
                          onPressed: () {
                            viewCourtsTimer?.cancel();
                            pageCtrl.dispose();
                            Get.back();
                          },
                          icon: const Icon(
                            Icons.close,
                            color: Colors.white70,
                            size: 22,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    Expanded(
                      child: Scrollbar(
                        controller: pageCtrl,
                        thumbVisibility: true,
                        trackVisibility: true,
                        interactive: true,
                        child: SingleChildScrollView(
                          controller: pageCtrl,
                          physics: const BouncingScrollPhysics(),
                          child: LayoutBuilder(
                            builder: (_, constraints) {
                              final maxW = constraints.maxWidth;
                              final cols = maxW >= 1000
                                  ? 3
                                  : (maxW >= 700 ? 2 : 1);
                              const spacing = 16.0;
                              final totalSpacing = spacing * (cols - 1);
                              final cardW = (maxW - totalSpacing) / cols;

                              return Wrap(
                                spacing: spacing,
                                runSpacing: spacing,
                                children: List.generate(itemCount, (i) {
                                  final c = currentCourts[i];
                                  final name =
                                      c['courtNumber']?.toString() ??
                                          'Court ${i + 1}';
                                  final types =
                                      (c['courtType'] as List?)
                                          ?.cast<String>() ??
                                          [];
                                  final pricing =
                                      (c['pricing'] as List?)
                                          ?.map(
                                            (e) => Map<String, dynamic>.from(
                                          e as Map,
                                        ),
                                      )
                                          .toList() ??
                                          [];
                                  final peakHours =
                                      (c['peakHours'] as List?)
                                          ?.map(
                                            (e) => Map<String, dynamic>.from(
                                          e as Map,
                                        ),
                                      )
                                          .toList() ??
                                          [];
                                  final description =
                                      c['description']?.toString() ?? '';

                                  return SizedBox(
                                    width: cardW,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.2,
                                            ),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Material(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          onTap: () {},
                                          child: Padding(
                                            padding: const EdgeInsets.all(14),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  name,
                                                  style: const TextStyle(
                                                    color: Color(0xFF0C1E2C),
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w800,
                                                  ),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),

                                                if (description.isNotEmpty) ...[
                                                  const SizedBox(height: 6),
                                                  Text(
                                                    description,
                                                    style: TextStyle(
                                                      color: Colors.grey[700],
                                                      fontSize: 13,
                                                      height: 1.25,
                                                    ),
                                                  ),
                                                ],

                                                if (types.isNotEmpty) ...[
                                                  const SizedBox(height: 10),
                                                  Wrap(
                                                    spacing: 8,
                                                    runSpacing: 6,
                                                    children: types
                                                        .map(
                                                          (t) => Container(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                          horizontal:
                                                              10,
                                                          vertical: 5,
                                                        ),
                                                        decoration: BoxDecoration(
                                                          color:
                                                              const Color(
                                                                0xFF0C1E2C,
                                                              ),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                            8,
                                                          ),
                                                        ),
                                                        child: Text(
                                                          t,
                                                          style:
                                                              const TextStyle(
                                                            color: Colors
                                                                .white,
                                                            fontSize:
                                                                12,
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                        .toList(),
                                                  ),
                                                ],

                                                const SizedBox(height: 10),
                                                const Text(
                                                  'Pricing Options (Rs.)',
                                                  style: TextStyle(
                                                    color: Color(0xFF0C1E2C),
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 6),

                                                if (pricing.isEmpty)
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                      top: 2,
                                                    ),
                                                    child: Text(
                                                      'No pricing available',
                                                      style: TextStyle(
                                                        color: Colors.grey[600],
                                                        fontStyle:
                                                            FontStyle.italic,
                                                      ),
                                                    ),
                                                  )
                                                else
                                                  Column(
                                                    children: pricing.map((p) {
                                                      final duration =
                                                          p['duration']
                                                              ?.toString() ??
                                                              '0';
                                                      final price =
                                                          p['price']
                                                              ?.toString() ??
                                                              '0';
                                                      return Padding(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                          vertical: 3,
                                                        ),
                                                        child: Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets.only(
                                                                top: 7.0,
                                                              ),
                                                              child: Container(
                                                                width: 6,
                                                                height: 6,
                                                                decoration: BoxDecoration(
                                                                  color: const Color(
                                                                    0xFF0C1E2C,
                                                                  ),
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                    3,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              width: 10,
                                                            ),
                                                            Expanded(
                                                              child: Text(
                                                                'Duration: $duration minutes',
                                                                style: TextStyle(
                                                                  color: Colors
                                                                      .grey[800],
                                                                  fontSize: 14,
                                                                ),
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              width: 10,
                                                            ),
                                                            Text(
                                                              'Price: Rs. $price',
                                                              style: const TextStyle(
                                                                color: Color(
                                                                  0xFF0C1E2C,
                                                                ),
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 14,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    }).toList(),
                                                  ),

                                                // ✅ Peak Hours section
                                                const SizedBox(height: 12),
                                                const Text(
                                                  'Peak Hours',
                                                  style: TextStyle(
                                                    color: Color(0xFF0C1E2C),
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 6),
                                                if (peakHours.isEmpty)
                                                  Text(
                                                    'No peak hours',
                                                    style: TextStyle(
                                                      color: Colors.grey[600],
                                                      fontStyle:
                                                          FontStyle.italic,
                                                    ),
                                                  )
                                                else
                                                  Column(
                                                    children: peakHours.map((
                                                        ph,
                                                        ) {
                                                      final st =
                                                          ph['startTime']
                                                              ?.toString() ??
                                                              '--:--';
                                                      final et =
                                                          ph['endTime']
                                                              ?.toString() ??
                                                              '--:--';
                                                      final pr =
                                                          ph['price']
                                                              ?.toString() ??
                                                              '0';
                                                      return Padding(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                          vertical: 3,
                                                        ),
                                                        child: Row(
                                                          children: [
                                                            const Icon(
                                                              Icons.schedule,
                                                              size: 16,
                                                              color: Color(
                                                                0xFF0C1E2C,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              width: 8,
                                                            ),
                                                            Expanded(
                                                              child: Text(
                                                                '$st → $et',
                                                                style: TextStyle(
                                                                  color: Colors
                                                                      .grey[800],
                                                                  fontSize: 14,
                                                                ),
                                                              ),
                                                            ),
                                                            Text(
                                                              'Rs. $pr',
                                                              style: const TextStyle(
                                                                color: Color(
                                                                  0xFF0C1E2C,
                                                                ),
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 14,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    }).toList(),
                                                  ),

                                                const SizedBox(height: 12),
                                                Align(
                                                  alignment:
                                                      Alignment.centerRight,
                                                  child: ElevatedButton.icon(
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor:
                                                          const Color(
                                                        0xFF0C1E2C,
                                                      ),
                                                      foregroundColor:
                                                          Colors.white,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                          12,
                                                        ),
                                                      ),
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                        horizontal: 16,
                                                        vertical: 10,
                                                      ),
                                                    ),
                                                    onPressed: () {
                                                      EditCourtDialog.show(
                                                        clubId,
                                                        c,
                                                        (id, body) => fetchVendorApi.updateCourtById(id, body),
                                                        () async {
                                                          onRefresh();
                                                          // refresh the local list inside the dialog
                                                          final updated = await fetchVendorApi.getVendorPlaygrounds();
                                                          final updatedClub = updated.firstWhere(
                                                            (c) => (c['_id'] ?? '') == club['_id'],
                                                            orElse: () => {},
                                                          );
                                                          final updatedCourts =
                                                              (updatedClub['courts'] as List? ?? [])
                                                                  .map(
                                                                    (e) => Map<String, dynamic>.from(
                                                                  e as Map,
                                                                ),
                                                              )
                                                                  .toList();
                                                          currentCourts.assignAll(updatedCourts);
                                                          onCourtsUpdated(updatedCourts);
                                                        },
                                                      );
                                                    },
                                                    icon: const Icon(
                                                      Icons.edit,
                                                      size: 18,
                                                    ),
                                                    label: const Text(
                                                      'Edit',
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
      barrierColor: Colors.black.withOpacity(0.7),
      barrierDismissible: true,
    ).then((_) {
      viewCourtsTimer?.cancel();
      pageCtrl.dispose();
    });

    debugPrint(
      'viewCourts opened for clubId=$clubId, initial courts=${currentCourts.length}',
    );
  }

  // Deep equals (very light)
  static bool _listDeepEquals(
    List<Map<String, dynamic>> a,
    List<Map<String, dynamic>> b,
  ) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (!_mapShallowEquals(a[i], b[i])) return false;
    }
    return true;
  }

  static bool _mapShallowEquals(Map<String, dynamic> a, Map<String, dynamic> b) {
    if (a.length != b.length) return false;
    for (final k in a.keys) {
      final va = a[k], vb = b[k];
      if (va is Map && vb is Map) {
        if (va.toString() != vb.toString()) return false;
      } else if (va is List && vb is List) {
        if (va.toString() != vb.toString()) return false;
      } else if (va != vb) {
        return false;
      }
    }
    return true;
  }
}
