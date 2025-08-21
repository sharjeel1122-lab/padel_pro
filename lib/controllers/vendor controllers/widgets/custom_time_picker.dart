import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class CustomTimePicker {
  static void show(TextEditingController controller) {
    final now = TimeOfDay.now();
    int initialHour = now.hour;
    int nearestQuarter(int m) {
      const qs = [0, 15, 30, 45];
      int best = qs.first;
      int bestDiff = (m - best).abs();
      for (final q in qs.skip(1)) {
        final d = (m - q).abs();
        if (d < bestDiff) {
          best = q;
          bestDiff = d;
        }
      }
      return best;
    }

    int initialMinute = nearestQuarter(now.minute);
    final re = RegExp(r'^(?:[01]\d|2[0-3]):[0-5]\d$');
    final text = controller.text.trim();
    if (re.hasMatch(text)) {
      final parts = text.split(':');
      final h = int.tryParse(parts[0]);
      final m = int.tryParse(parts[1]);
      if (h != null && h >= 0 && h <= 23) initialHour = h;
      if (m != null && const [0, 15, 30, 45].contains(m)) initialMinute = m;
    }

    final hours = List<int>.generate(24, (i) => i);
    const minutes = <int>[0, 15, 30, 45];

    int selectedHour = initialHour;
    int selectedMinute = initialMinute;

    final hourCtrl = FixedExtentScrollController(
      initialItem: hours.indexOf(initialHour),
    );
    final minCtrl = FixedExtentScrollController(
      initialItem: minutes.indexOf(initialMinute),
    );

    Get.dialog(
      StatefulBuilder(
        builder: (context, setState) {
          final size = MediaQuery.of(context).size;
          final isPhone = size.width < 600;
          final dialogW = isPhone ? size.width - 40 : 360.0;
          const dialogH = 280.0;

          return Dialog(
            backgroundColor: Colors.white,
            insetPadding: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: SizedBox(
              width: dialogW,
              height: dialogH,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: const BoxDecoration(
                      color: Color(0xFF0C1E2C),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.access_time, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Select Time',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: CupertinoPicker(
                            scrollController: hourCtrl,
                            itemExtent: 36,
                            magnification: 1.1,
                            useMagnifier: true,
                            onSelectedItemChanged: (i) {
                              setState(() => selectedHour = hours[i]);
                            },
                            children: hours
                                .map(
                                  (h) => Center(
                                    child: Text(
                                      h.toString().padLeft(2, '0'),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                        const SizedBox(
                          width: 1,
                          child: DecoratedBox(
                            decoration: BoxDecoration(color: Color(0xFFE0E0E0)),
                          ),
                        ),
                        Expanded(
                          child: CupertinoPicker(
                            scrollController: minCtrl,
                            itemExtent: 36,
                            magnification: 1.1,
                            useMagnifier: true,
                            onSelectedItemChanged: (i) {
                              setState(() => selectedMinute = minutes[i]);
                            },
                            children: minutes
                                .map(
                                  (m) => Center(
                                    child: Text(
                                      m.toString().padLeft(2, '0'),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: Get.back,
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0C1E2C),
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () {
                              final hh = selectedHour.toString().padLeft(2, '0');
                              final mm = selectedMinute.toString().padLeft(2, '0');
                              controller.text = '$hh:$mm';
                              Get.back();
                              Get.forceAppUpdate();
                            },
                            child: const Text('OK'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      barrierDismissible: true,
    );
  }
}
