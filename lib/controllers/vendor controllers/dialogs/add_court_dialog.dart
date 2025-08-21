import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:padel_pro/services/vendors%20api/create_club_courts_api.dart';
import 'package:padel_pro/controllers/vendor controllers/models/court_models.dart';
import 'package:padel_pro/controllers/vendor controllers/widgets/custom_time_picker.dart';

class AddCourtDialog {
  static void show(
    String playgroundId,
    CreateVendorApi vendorApi,
    Future<void> Function()? onAdded,
  ) {
    const brand = Color(0xFF0C1E2C);
    const allowedDurations = <int>[30, 60, 90, 120, 150, 180];

    final courtNumberCtrl = TextEditingController();
    final List<String> typeOptions = [
      'Wall',
      'Crystal',
      'Panoramic',
      'Indoor',
      'Outdoor',
    ];
    final RxList<String> selectedTypes = <String>[].obs;

    // Pricing rows
    final RxList<PricingRow> pricingRows = <PricingRow>[
      PricingRow(duration: 60, priceCtrl: TextEditingController(text: '0')),
    ].obs;

    // Peak hour rows
    final RxList<PeakRow> peakRows = <PeakRow>[].obs;

    String _hhmm(TimeOfDay t) =>
        '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

    Future<void> _pickHHmm(TextEditingController ctrl) async {
      final picked = await showTimePicker(
        context: Get.context!,
        initialTime: TimeOfDay.now(),
        initialEntryMode: TimePickerEntryMode.dial,
        builder: (ctx, child) => MediaQuery(
          data: MediaQuery.of(ctx!).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        ),
      );
      if (picked != null) ctrl.text = _hhmm(picked);
    }

    void addPeakRow() {
      peakRows.add(PeakRow());
    }

    void removePeakRow(int i) {
      if (peakRows.length > 1) {
        final r = peakRows.removeAt(i);
        r.dispose();
      }
    }

    Future<void> _save() async {
      // Validate
      if (courtNumberCtrl.text.trim().isEmpty) {
        Get.snackbar(
          'Validation',
          'Court name / number is required',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }
      if (selectedTypes.isEmpty) {
        Get.snackbar(
          'Validation',
          'Select at least one court type',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }
      if (pricingRows.isEmpty) {
        Get.snackbar(
          'Validation',
          'Add at least one pricing row',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }
      for (int i = 0; i < pricingRows.length; i++) {
        final r = pricingRows[i];
        final price = int.tryParse(r.priceCtrl.text.trim());
        if (!allowedDurations.contains(r.duration) || price == null) {
          Get.snackbar(
            'Validation',
            'Invalid pricing in row ${i + 1}',
            backgroundColor: Colors.orange,
            colorText: Colors.white,
          );
          return;
        }
      }
      for (int i = 0; i < peakRows.length; i++) {
        final r = peakRows[i];
        final okTime =
            _isHHmm(r.startCtrl.text.trim()) && _isHHmm(r.endCtrl.text.trim());
        final price = int.tryParse(r.priceCtrl.text.trim());
        if (!okTime || price == null) {
          Get.snackbar(
            'Validation',
            'Invalid peak hour in row ${i + 1}',
            backgroundColor: Colors.orange,
            colorText: Colors.white,
          );
          return;
        }
      }

      final courtPayload = {
        "courtNumber": courtNumberCtrl.text.trim(),
        "courtType": selectedTypes.toList(),
        "pricing": pricingRows
            .map(
              (e) => {
                "duration": e.duration,
                "price": int.parse(e.priceCtrl.text.trim()),
              },
            )
            .toList(),
        "peakHours": peakRows
            .map(
              (e) => {
                "startTime": e.startCtrl.text.trim(),
                "endTime": e.endCtrl.text.trim(),
                "price": int.parse(e.priceCtrl.text.trim()),
              },
            )
            .toList(),
      };

      // Call API
      Get.back(); // close dialog
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );
      try {
        await vendorApi.addCourts(
          playgroundId: playgroundId,
          courts: [courtPayload],
        );
        Get.back(); // loader
        Get.snackbar(
          'Success',
          'Court added successfully',
          backgroundColor: const Color(0xFF162A3A),
          colorText: Colors.white,
        );
        await onAdded?.call();
      } catch (e) {
        Get.back(); // loader
        Get.snackbar(
          'Error',
          e.toString(),
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }

    Get.dialog(
      StatefulBuilder(
        builder: (context, setState) {
          final size = MediaQuery.of(context).size;
          final isPhone = size.width < 600;
          final maxW = isPhone
              ? size.width - 20
              : ((size.width).clamp(600.0, 900.0) as double) - 20;
          final maxH = isPhone ? size.height * 0.96 : size.height * 0.85;

          return Dialog(
            backgroundColor: Colors.white,
            insetPadding: const EdgeInsets.all(12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            child: SafeArea(
              child: SizedBox(
                width: maxW,
                height: maxH,
                child: Column(
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: const BoxDecoration(
                        color: brand,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(18),
                        ),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.add, color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Add Court',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Body
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _field(
                              label: "Court Number / Name",
                              controller: courtNumberCtrl,
                              icon: Icons.confirmation_number,
                            ),

                            const Text(
                              "Court Types",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Obx(
                              () => Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: typeOptions.map((t) {
                                  final sel = selectedTypes.contains(t);
                                  return ChoiceChip(
                                    label: Text(t),
                                    selected: sel,
                                    onSelected: (v) {
                                      if (v) {
                                        if (!sel) selectedTypes.add(t);
                                      } else {
                                        selectedTypes.remove(t);
                                      }
                                    },
                                    selectedColor: brand,
                                    backgroundColor: Colors.grey[200],
                                    labelStyle: TextStyle(
                                      color: sel ? Colors.white : Colors.black,
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                            const SizedBox(height: 12),

                            Row(
                              children: const [
                                Text(
                                  "Pricing (Rs.)",
                                  style: TextStyle(
                                    color: brand,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  "(choose Duration and set Price)",
                                  style: TextStyle(color: Colors.black54),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // Pricing rows
                            Obx(
                              () => ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: pricingRows.length,
                                itemBuilder: (_, i) {
                                  final row = pricingRows[i];
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.black12),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: LayoutBuilder(
                                      builder: (_, cts) {
                                        final twoCols = cts.maxWidth > 520;

                                        if (!twoCols) {
                                          return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              DropdownButtonFormField<int>(
                                                value: row.duration,
                                                decoration:
                                                    const InputDecoration(
                                                      labelText: 'Duration',
                                                      border:
                                                          OutlineInputBorder(),
                                                    ),
                                                isExpanded: true,
                                                items: allowedDurations
                                                    .map(
                                                      (d) =>
                                                          DropdownMenuItem<int>(
                                                            value: d,
                                                            child: Text(
                                                              '$d min',
                                                            ),
                                                          ),
                                                    )
                                                    .toList(),
                                                onChanged: (v) {
                                                  if (v == null) return;
                                                  setState(
                                                    () => row.duration = v,
                                                  );
                                                },
                                              ),
                                              const SizedBox(height: 10),
                                              TextField(
                                                controller: row.priceCtrl,
                                                keyboardType:
                                                    TextInputType.number,
                                                inputFormatters: [
                                                  FilteringTextInputFormatter
                                                      .digitsOnly,
                                                ],
                                                decoration:
                                                    const InputDecoration(
                                                      labelText: 'Price (Rs.)',
                                                      border:
                                                          OutlineInputBorder(),
                                                    ),
                                              ),
                                              Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: IconButton(
                                                  tooltip: 'Remove',
                                                  onPressed: () {
                                                    if (pricingRows.length >
                                                        1) {
                                                      final x = pricingRows
                                                          .removeAt(i);
                                                      x.priceCtrl.dispose();
                                                      setState(() {});
                                                    }
                                                  },
                                                  icon: const Icon(
                                                    Icons.delete_outline,
                                                    color: Colors.redAccent,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        }

                                        return Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            ConstrainedBox(
                                              constraints: const BoxConstraints(
                                                minWidth: 160,
                                                maxWidth: 200,
                                              ),
                                              child: DropdownButtonFormField<int>(
                                                value: row.duration,
                                                decoration:
                                                    const InputDecoration(
                                                      labelText: 'Duration',
                                                      border:
                                                          OutlineInputBorder(),
                                                    ),
                                                isExpanded: true,
                                                items: allowedDurations
                                                    .map(
                                                      (d) =>
                                                          DropdownMenuItem<int>(
                                                            value: d,
                                                            child: Text(
                                                              '$d min',
                                                            ),
                                                          ),
                                                    )
                                                    .toList(),
                                                onChanged: (v) {
                                                  if (v == null) return;
                                                  setState(
                                                    () => row.duration = v,
                                                  );
                                                },
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: TextField(
                                                controller: row.priceCtrl,
                                                keyboardType:
                                                    TextInputType.number,
                                                inputFormatters: [
                                                  FilteringTextInputFormatter
                                                      .digitsOnly,
                                                ],
                                                decoration:
                                                    const InputDecoration(
                                                      labelText: 'Price (Rs.)',
                                                      border:
                                                          OutlineInputBorder(),
                                                    ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            IconButton(
                                              tooltip: 'Remove',
                                              onPressed: () {
                                                if (pricingRows.length > 1) {
                                                  final x = pricingRows
                                                      .removeAt(i);
                                                  x.priceCtrl.dispose();
                                                  setState(() {});
                                                }
                                              },
                                              icon: const Icon(
                                                Icons.delete_outline,
                                                color: Colors.redAccent,
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),

                            Align(
                              alignment: Alignment.centerLeft,
                              child: TextButton.icon(
                                onPressed: () {
                                  pricingRows.add(
                                    PricingRow(
                                      duration: 60,
                                      priceCtrl: TextEditingController(
                                        text: '0',
                                      ),
                                    ),
                                  );
                                  setState(() {});
                                },
                                icon: const Icon(Icons.add),
                                label: const Text('Add pricing'),
                                style: TextButton.styleFrom(
                                  foregroundColor: brand,
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),
                            Row(
                              children: const [
                                Text(
                              'Peak Hours',
                              style: TextStyle(
                                color: brand,
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                                SizedBox(width: 8),
                                Text(
                                  '(Start, End, Price)',
                                  style: TextStyle(color: Colors.black54),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: peakRows.length,
                                itemBuilder: (_, i) {
                                  final row = peakRows[i];
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.black12),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      children: [
                                        LayoutBuilder(
                                          builder: (_, cts) {
                                            final twoCols = cts.maxWidth > 520;
                                            final startField = TextField(
                                              controller: row.startCtrl,
                                              readOnly: true,
                                            onTap: () => CustomTimePicker.show(row.startCtrl),
                                              decoration: const InputDecoration(
                                                labelText: 'Start (HH:MM)',
                                                border: OutlineInputBorder(),
                                              prefixIcon: Icon(Icons.schedule),
                                              ),
                                            );
                                            final endField = TextField(
                                              controller: row.endCtrl,
                                              readOnly: true,
                                            onTap: () => CustomTimePicker.show(row.endCtrl),
                                              decoration: const InputDecoration(
                                                labelText: 'End (HH:MM)',
                                                border: OutlineInputBorder(),
                                              prefixIcon: Icon(Icons.schedule),
                                              ),
                                            );

                                            if (!twoCols) {
                                              return Column(
                                                children: [
                                                  startField,
                                                  const SizedBox(height: 10),
                                                  endField,
                                                ],
                                              );
                                            }
                                            return Row(
                                              children: [
                                              Expanded(child: startField),
                                                const SizedBox(width: 12),
                                              Expanded(child: endField),
                                              ],
                                            );
                                          },
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: TextField(
                                                controller: row.priceCtrl,
                                              keyboardType: TextInputType.number,
                                                inputFormatters: [
                                                FilteringTextInputFormatter.digitsOnly,
                                                ],
                                              decoration: const InputDecoration(
                                                      labelText: 'Price (Rs.)',
                                                border: OutlineInputBorder(),
                                                prefixIcon: Icon(Icons.money),
                                                    ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            IconButton(
                                              tooltip: 'Remove',
                                            onPressed: () => removePeakRow(i),
                                              icon: const Icon(
                                                Icons.delete_outline,
                                                color: Colors.redAccent,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                            ),

                            Align(
                              alignment: Alignment.centerLeft,
                              child: TextButton.icon(
                                onPressed: () => addPeakRow(),
                                icon: const Icon(Icons.add),
                                label: const Text('Add peak hour'),
                                style: TextButton.styleFrom(
                                  foregroundColor: brand,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Footer
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
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
                                backgroundColor: brand,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: _save,
                              child: const Text(
                                "ADD COURT",
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      barrierDismissible: true,
    );
  }

  static Widget _field({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    int maxLines = 1,
  }) {
    const brand = Color(0xFF0C1E2C);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: brand.withOpacity(0.7)),
          prefixIcon: Icon(icon, color: brand.withOpacity(0.7)),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: Colors.black26),
          ),
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: Colors.black26),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: brand, width: 1.5),
          ),
          filled: true,
          fillColor: Colors.grey[50],
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 20, color: Colors.grey),
                  onPressed: () {
                    controller.clear();
                    Get.forceAppUpdate();
                  },
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 16,
          ),
        ),
        onChanged: (_) => Get.forceAppUpdate(),
      ),
    );
  }

  static bool _isHHmm(String s) {
    final re = RegExp(r'^(?:[01]\d|2[0-3]):[0-5]\d$');
    return re.hasMatch(s);
  }
}
