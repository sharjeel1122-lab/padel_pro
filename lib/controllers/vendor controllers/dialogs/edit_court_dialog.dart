import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:padel_pro/controllers/vendor controllers/models/court_models.dart';
import 'package:padel_pro/controllers/vendor controllers/widgets/custom_time_picker.dart';

class EditCourtDialog {
  static void show(
    String playgroundId,
    Map<String, dynamic> court,
    Future<void> Function(
      String playgroundId,
      Map<String, dynamic> payload,
    ) updateCourtsApi,
    VoidCallback? onAfterSave,
  ) {
    const brand = Color(0xFF0C1E2C);
    const allowedDurations = <int>[30, 60, 90, 120, 150, 180];

    final TextEditingController courtNumberCtrl = TextEditingController(
      text: (court['courtNumber'] ?? '').toString(),
    );

    final List<String> typeOptions = [
      'Wall',
      'Crystal',
      'Panoramic',
      'Indoor',
      'Outdoor',
    ];
    List<String> selectedTypes =
        ((court['courtType'] as List?)?.map((e) => e.toString()).toList() ??
                <String>[])
            .toList();
    bool isActive = (court['isActive'] ?? false) as bool;

    final List<int> durations = [];
    final List<TextEditingController> priceCtrls = [];
    final List<FocusNode> priceFocus = [];
    final List<PeakRow> peakRows = <PeakRow>[];

    void seedPricing() {
      final src = (court['pricing'] as List? ?? []);
      if (src.isEmpty) {
        durations.add(60);
        priceCtrls.add(TextEditingController(text: '0'));
        priceFocus.add(FocusNode());
        return;
      }
      for (final e in src) {
        final m = Map<String, dynamic>.from(e as Map);
        durations.add((m['duration'] is int) ? m['duration'] as int : 60);
        priceCtrls.add(
          TextEditingController(text: (m['price'] ?? '0').toString()),
        );
        priceFocus.add(FocusNode());
      }
    }

    seedPricing();
    
    void seedPeakRows() {
      final src = (court['peakHours'] as List? ?? []);
      for (final e in src) {
        final m = Map<String, dynamic>.from(e as Map);
        final row = PeakRow();
        row.startCtrl.text = (m['startTime'] ?? '').toString();
        row.endCtrl.text = (m['endTime'] ?? '').toString();
        row.priceCtrl.text = (m['price'] ?? '0').toString();
        peakRows.add(row);
      }
      if (peakRows.isEmpty) {
        peakRows.add(PeakRow());
      }
    }
    seedPeakRows();

    void addPricingRow(void Function(void Function()) setState) {
      setState(() {
        durations.add(60);
        priceCtrls.add(TextEditingController(text: '0'));
        priceFocus.add(FocusNode());
      });
    }

    void removePricingRow(int i, void Function(void Function()) setState) {
      if (durations.length <= 1) return;
      setState(() {
        durations.removeAt(i);
        priceCtrls.removeAt(i).dispose();
        priceFocus.removeAt(i).dispose();
      });
    }

    void addPeakRow(void Function(void Function()) setState) {
      setState(() => peakRows.add(PeakRow()));
    }

    void removePeakRow(int i, void Function(void Function()) setState) {
      setState(() {
        final r = peakRows.removeAt(i);
        r.dispose();
      });
    }

    Future<void> onSave() async {
      if (courtNumberCtrl.text.trim().isEmpty) {
        Get.snackbar(
          "Validation",
          "Court number / name is required",
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }
      for (int i = 0; i < durations.length; i++) {
        final d = durations[i];
        final prStr = priceCtrls[i].text.trim();
        if (!allowedDurations.contains(d)) {
          Get.snackbar(
            "Validation",
            "Invalid duration value",
            backgroundColor: Colors.orange,
            colorText: Colors.white,
          );
          return;
        }
        if (prStr.isEmpty || int.tryParse(prStr) == null) {
          Get.snackbar(
            "Validation",
            "Invalid price in row ${i + 1}",
            backgroundColor: Colors.orange,
            colorText: Colors.white,
          );
          return;
        }
      }

      // Validate peak hours
      for (int i = 0; i < peakRows.length; i++) {
        final r = peakRows[i];
        final okTime = _isHHmm(r.startCtrl.text.trim()) && _isHHmm(r.endCtrl.text.trim());
        final price = int.tryParse(r.priceCtrl.text.trim());
        if (!okTime || price == null) {
          Get.snackbar(
            "Validation",
            'Invalid peak hour in row ${i + 1}',
            backgroundColor: Colors.orange,
            colorText: Colors.white,
          );
          return;
        }
      }

      final payloadCourt = {
        "courtNumber": courtNumberCtrl.text.trim(),
        "courtType": selectedTypes,
        "pricing": List.generate(durations.length, (i) {
          return {
            "duration": durations[i],
            "price": int.parse(priceCtrls[i].text.trim()),
          };
        }),
        "peakHours": peakRows
            .map((e) => {
          "startTime": e.startCtrl.text.trim(),
          "endTime": e.endCtrl.text.trim(),
          "price": int.parse(e.priceCtrl.text.trim()),
        })
            .toList(),
        "isActive": isActive,
      };

      Get.back();
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      try {
        await updateCourtsApi(playgroundId, {
          "courts": [payloadCourt],
        });
        Get.back();
        Get.snackbar(
          "Success",
          "Court updated successfully",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        onAfterSave?.call();
      } catch (e) {
        Get.back();
        Get.snackbar(
          "Error",
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
                          Icon(Icons.edit, color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Edit Court',
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
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: typeOptions.map((t) {
                                final sel = selectedTypes.contains(t);
                                return ChoiceChip(
                                  label: Text(t),
                                  selected: sel,
                                  onSelected: (v) {
                                    setState(() {
                                      if (v) {
                                        if (!sel) selectedTypes.add(t);
                                      } else {
                                        selectedTypes.remove(t);
                                      }
                                    });
                                  },
                                  selectedColor: brand,
                                  backgroundColor: Colors.grey[200],
                                  labelStyle: TextStyle(
                                    color: sel ? Colors.white : Colors.black,
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 12),

                            SwitchListTile(
                              value: isActive,
                              onChanged: (v) => setState(() => isActive = v),
                              title: const Text('Active'),
                              activeColor: brand,
                              contentPadding: EdgeInsets.zero,
                            ),
                            const SizedBox(height: 8),

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

                            // PRICING LIST - overflow safe
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: durations.length,
                              itemBuilder: (_, i) {
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
                                            // Duration
                                            DropdownButtonFormField<int>(
                                              value: durations[i],
                                              decoration: const InputDecoration(
                                                labelText: 'Duration',
                                                border: OutlineInputBorder(),
                                              ),
                                              isExpanded: true,
                                              items: allowedDurations
                                                  .map(
                                                    (d) =>
                                                        DropdownMenuItem<int>(
                                                          value: d,
                                                          child: Text('$d min'),
                                                        ),
                                                  )
                                                  .toList(),
                                              onChanged: (v) {
                                                if (v == null) return;
                                                setState(
                                                  () => durations[i] = v,
                                                );
                                              },
                                            ),
                                            const SizedBox(height: 10),
                                            // Price
                                            TextField(
                                              controller: priceCtrls[i],
                                              focusNode: priceFocus[i],
                                              keyboardType:
                                                  TextInputType.number,
                                              inputFormatters: [
                                                FilteringTextInputFormatter
                                                    .digitsOnly,
                                              ],
                                              decoration: const InputDecoration(
                                                labelText: 'Price (Rs.)',
                                                border: OutlineInputBorder(),
                                              ),
                                            ),
                                            Align(
                                              alignment: Alignment.centerRight,
                                              child: IconButton(
                                                tooltip: 'Remove',
                                                onPressed: () =>
                                                    removePricingRow(
                                                      i,
                                                      setState,
                                                    ),
                                                icon: const Icon(
                                                  Icons.delete_outline,
                                                  color: Colors.redAccent,
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      }

                                      // Wide layout (Row 2-col)
                                      return Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Duration (fixed)
                                          ConstrainedBox(
                                            constraints: const BoxConstraints(
                                              minWidth: 160,
                                              maxWidth: 200,
                                            ),
                                            child: DropdownButtonFormField<int>(
                                              value: durations[i],
                                              decoration: const InputDecoration(
                                                labelText: 'Duration',
                                                border: OutlineInputBorder(),
                                              ),
                                              isExpanded: true,
                                              items: allowedDurations
                                                  .map(
                                                    (d) =>
                                                        DropdownMenuItem<int>(
                                                          value: d,
                                                          child: Text('$d min'),
                                                        ),
                                                  )
                                                  .toList(),
                                              onChanged: (v) {
                                                if (v == null) return;
                                                setState(
                                                  () => durations[i] = v,
                                                );
                                              },
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          // Price (flex)
                                          Expanded(
                                            child: TextField(
                                              controller: priceCtrls[i],
                                              focusNode: priceFocus[i],
                                              keyboardType:
                                                  TextInputType.number,
                                              inputFormatters: [
                                                FilteringTextInputFormatter
                                                    .digitsOnly,
                                              ],
                                              decoration: const InputDecoration(
                                                labelText: 'Price (Rs.)',
                                                border: OutlineInputBorder(),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          IconButton(
                                            tooltip: 'Remove',
                                            onPressed: () =>
                                                removePricingRow(i, setState),
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

                            Align(
                              alignment: Alignment.centerLeft,
                              child: TextButton.icon(
                                onPressed: () => addPricingRow(setState),
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
                                            onPressed: () => removePeakRow(i, setState),
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
                                onPressed: () => addPeakRow(setState),
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
                              onPressed: onSave,
                              child: const Text(
                                "SAVE CHANGES",
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
