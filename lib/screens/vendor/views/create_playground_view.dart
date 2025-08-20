// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../vendor data controller/reate_playground_controller.dart';

class CreatePlaygroundView extends StatelessWidget {
  CreatePlaygroundView({super.key});

  // Brand palette
  final Color primaryColor = const Color(0xFF072A40);
  final Color secondaryColor = const Color(0xFF145DA0);
  final Color surface = const Color(0xFFF7F9FC);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CreatePlaygroundController());

    return Scaffold(
      backgroundColor: surface,
      appBar: AppBar(
        backgroundColor: primaryColor,
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Create New Club',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Scrollbar(
        thickness: 6,
        radius: const Radius.circular(12),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 820),
              child: Form(
                key: controller.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _sectionHeader(
                      context,
                      title: 'Basic Information',
                      icon: Icons.info_outline,
                    ),
                    _card(
                      children: [
                        _textField(
                          controller: controller.nameC,
                          label: 'Club Name*',
                          icon: Icons.sports_soccer,
                          hint: 'e.g. Blue Ridge Padel Club',
                        ),
                        const SizedBox(height: 16),
                        _textField(
                          controller: controller.sizeC,
                          label: 'Court Size*',
                          icon: Icons.aspect_ratio,
                          hint: 'e.g. 20m x 10m',
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                    _sectionHeader(
                      context,
                      title: 'Description',
                      icon: Icons.description_outlined,
                      subtitle: 'Share details players should know before booking',
                    ),
                    _card(
                      children: [
                        _textField(
                          controller: controller.descriptionC,
                          label: 'Detailed Description*',
                          icon: Icons.description,
                          maxLines: 5,
                          hint: 'Amenities, surface type, rules, parking, etc.',
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                    _sectionHeader(
                      context,
                      title: 'Contact Information',
                      icon: Icons.location_on_outlined,
                    ),
                    _card(
                      children: [
                        _textField(
                          controller: controller.locationC,
                          label: 'Full Address*',
                          icon: Icons.home_work_outlined,
                          hint: 'Street, area, city',
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _textField(
                                controller: controller.cityC,
                                label: 'City*',
                                icon: Icons.location_city,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _textField(
                                controller: controller.phoneC,
                                label: 'Phone Number*',
                                icon: Icons.phone,
                                keyboardType: TextInputType.phone,
                                prefixText: '+',
                                hint: '92 3XX XXXXXXX',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _textField(
                          controller: controller.townC,
                          label: 'Town*',
                          icon: Icons.location_on_outlined,
                        ),
                        const SizedBox(height: 16),
                        _textField(
                          controller: controller.websiteC,
                          label: 'Website (optional)',
                          icon: Icons.public,
                          isRequired: false,
                          hint: 'https://',
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                    _sectionHeader(
                      context,
                      title: 'Operating Hours',
                      icon: Icons.schedule_outlined,
                    ),
                    _card(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _timeField(
                                context: context,
                                controller: controller.openingTimeC,
                                label: 'Opening Time*',
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _timeField(
                                context: context,
                                controller: controller.closingTimeC,
                                label: 'Closing Time*',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                    _sectionHeader(
                      context,
                      title: 'Photos (3–5 recommended)',
                      icon: Icons.photo_library_outlined,
                    ),
                    _card(children: [_imagePicker(controller)]),

                    const SizedBox(height: 20),
                    _sectionHeader(
                      context,
                      title: 'Facilities',
                      icon: Icons.handyman_outlined,
                    ),
                    _card(children: [_facilitiesGrid(controller)]),

                    const SizedBox(height: 20),
                    _sectionHeader(
                      context,
                      title: 'Add Courts',
                      icon: Icons.sports_tennis,
                    ),
                    Obx(
                          () => Column(
                        children: [
                          ...controller.courts.asMap().entries.map((e) {
                            final index = e.key;
                            final courtModel = e.value;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _courtExpansionCard(controller, index, courtModel),
                            );
                          }),
                          _addCourtButton(controller),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),
                    Obx(() => _submitButton(controller)),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------- UI Building Blocks ---------- //
  Widget _sectionHeader(BuildContext context,
      {required String title, String? subtitle, required IconData icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: primaryColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 12.5,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _card({required List<Widget> children}) => Card(
    elevation: 0,
    color: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
      side: BorderSide(color: Colors.grey.shade200),
    ),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    ),
  );

  InputDecoration _decor({
    required String label,
    IconData? icon,
    String? prefixText,
    String? hint,
  }) => InputDecoration(
    labelText: label,
    hintText: hint,
    prefixText: prefixText,
    prefixIcon: icon != null ? Icon(icon, size: 20) : null,
    filled: true,
    fillColor: Colors.grey.shade50,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: primaryColor, width: 1.6),
    ),
    contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
  );

  Widget _textField({
    required TextEditingController controller,
    required String label,
    IconData? icon,
    bool isRequired = true,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? prefixText,
    String? hint,
  }) => TextFormField(
    controller: controller,
    maxLines: maxLines,
    keyboardType: keyboardType,
    style: GoogleFonts.poppins(fontSize: 14.5, height: 1.3),
    decoration: _decor(label: label, icon: icon, prefixText: prefixText, hint: hint),
    validator: isRequired
        ? (val) => val == null || val.trim().isEmpty ? 'This field is required' : null
        : null,
  );

  String _toHHmm(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<TimeOfDay?> _showCustomTimePicker(
      BuildContext context, {
        TimeOfDay? initialTime,
      }) async {
    final List<int> hours = List<int>.generate(24, (i) => i);
    const List<int> quarterMinutes = <int>[0, 15, 30, 45];

    final TimeOfDay base = initialTime ?? TimeOfDay.now();
    int selectedHour = base.hour.clamp(0, 23);
    int selectedMinuteIndex = quarterMinutes.indexWhere(
          (m) => m == (base.minute ~/ 15) * 15,
    );
    if (selectedMinuteIndex == -1) selectedMinuteIndex = 0;

    return showDialog<TimeOfDay>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.white,
          contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: SizedBox(
            height: 220,
            child: Row(
              children: [
                Expanded(
                  child: CupertinoPicker(

                    scrollController: FixedExtentScrollController(initialItem: selectedHour),
                    itemExtent: 32,
                    onSelectedItemChanged: (i) {
                      selectedHour = hours[i];
                    },
                    children: hours
                        .map((h) => Center(
                      child: Text(
                        h.toString().padLeft(2, '0'),
                        style: GoogleFonts.poppins(fontSize: 18),
                      ),
                    ))
                        .toList(),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: CupertinoPicker(
                    scrollController: FixedExtentScrollController(initialItem: selectedMinuteIndex),
                    itemExtent: 32,
                    onSelectedItemChanged: (i) {
                      selectedMinuteIndex = i;
                    },
                    children: quarterMinutes
                        .map((m) => Center(
                      child: Text(
                        m.toString().padLeft(2, '0'),
                        style: GoogleFonts.poppins(fontSize: 18),
                      ),
                    ))
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('Cancel', style: GoogleFonts.poppins()),
            ),
            TextButton(
              onPressed: () {
                final int minute = quarterMinutes[selectedMinuteIndex];
                Navigator.of(ctx).pop(TimeOfDay(hour: selectedHour, minute: minute));
              },
              child: Text(
                'OK',
                style: GoogleFonts.poppins(color: primaryColor, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _timeField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
  }) => TextFormField(
    controller: controller,
    readOnly: true,
    style: GoogleFonts.poppins(fontSize: 14.5),
    decoration: _decor(label: label, icon: Icons.access_time),
    onTap: () async {
      TimeOfDay? initial;
      final String val = controller.text;
      final RegExp re = RegExp(r'^(?:[01]\d|2[0-3]):[0-5]\d$');
      if (val.isNotEmpty && re.hasMatch(val)) {
        final parts = val.split(':');
        initial = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      }
      final TimeOfDay? picked = await _showCustomTimePicker(context, initialTime: initial);
      if (picked != null) controller.text = _toHHmm(picked);
    },
    validator: (val) {
      if (val == null || val.isEmpty) return 'Required';
      final ok = RegExp(r'^(?:[01]\d|2[0-3]):[0-5]\d$').hasMatch(val);
      return ok ? null : 'Use 24-hour HH:MM';
    },
  );

  Widget _imagePicker(CreatePlaygroundController controller) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Obx(
            () => controller.selectedImages.isEmpty
            ? Container(
          height: 140,
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.image_outlined, size: 42, color: Colors.grey.shade500),
                const SizedBox(height: 8),
                Text('No images selected', style: GoogleFonts.poppins(color: Colors.grey.shade700)),
              ],
            ),
          ),
        )
            : SizedBox(
          height: 140,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemBuilder: (_, i) => Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(controller.selectedImages[i].path),
                    width: 160,
                    height: 140,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 6,
                  right: 6,
                  child: InkWell(
                    onTap: () => controller.removeImage(i),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(.55),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, size: 16, color: Colors.white),
                    ),
                  ),
                )
              ],
            ),
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemCount: controller.selectedImages.length,
          ),
        ),
      ),
      const SizedBox(height: 12),
      OutlinedButton.icon(
        onPressed: controller.pickImages,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
          side: BorderSide(color: secondaryColor),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        icon: Icon(Icons.add_photo_alternate_outlined, color: secondaryColor),
        label: Text(
          'Upload Photos',
          style: GoogleFonts.poppins(color: secondaryColor, fontWeight: FontWeight.w600),
        ),
      )
    ],
  );

  Widget _facilitiesGrid(CreatePlaygroundController controller) {
    // Show friendly labels, store backend-allowed lowercase values
    final facilityOptions = [
      {'icon': Icons.wifi, 'label': 'WiFi', 'value': 'wifi'},
      {'icon': Icons.lock, 'label': 'Lockers', 'value': 'lockers'},
      {'icon': Icons.shower, 'label': 'Showers', 'value': 'showers'},
      {'icon': Icons.local_cafe, 'label': 'Cafe', 'value': 'cafe'},
      {'icon': Icons.local_parking, 'label': 'Parking', 'value': 'parking'},
    ];

    return Obx(
          () => Wrap(
        spacing: 10,
        runSpacing: 10,
        children: facilityOptions.map((f) {
          final isSelected = controller.facilities.contains(f['value']);
          return FilterChip(
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  f['icon'] as IconData,
                  size: 18,
                  color: isSelected ? Colors.white : primaryColor,
                ),
                const SizedBox(width: 6),
                Text(
                  f['label'] as String,
                  style: GoogleFonts.poppins(
                    color: isSelected ? Colors.white : primaryColor,
                  ),
                ),
              ],
            ),
            selected: isSelected,
            onSelected: (sel) => sel
                ? controller.facilities.add(f['value'] as String)
                : controller.facilities.remove(f['value'] as String),
            selectedColor: primaryColor,
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: isSelected ? primaryColor : Colors.grey.shade300),
            ),
            showCheckmark: false,
          );
        }).toList(),
      ),
    );
  }

  Widget _courtExpansionCard(
      CreatePlaygroundController controller,
      int index,
      CourtUIModel court,
      ) {
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          initiallyExpanded: index == 0,
          title: Text(
            'Court ${index + 1}',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: primaryColor,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (controller.courts.length > 1)
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: () => controller.removeCourt(index),
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                ),
              const Icon(Icons.expand_more),
            ],
          ),
          children: [
            _textField(
              controller: court.courtNumberController,
              label: 'Court Name*',
              icon: Icons.sports_handball,
            ),
            const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: court.courtTypeController.text.isEmpty
                ? null
                : court.courtTypeController.text,
            isExpanded: true,
            alignment: AlignmentDirectional.centerStart, // selected text left aligned
            menuMaxHeight: 280,
            icon: const Icon(Icons.arrow_drop_down_rounded),
            dropdownColor: Colors.white,
            decoration: _decor(
              label: 'Court Type*',
              icon: Icons.category,
            ).copyWith(
              filled: true,
              fillColor: Colors.grey.shade50,
              // zyada clear spacing taake text clip na ho
              contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
            ),
            style: GoogleFonts.poppins(
              fontSize: 14.5,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            hint: Text(
              'Select Court Type',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),

            selectedItemBuilder: (context) {
              const types = ['Wall', 'Crystal', 'Panoramic', 'Indoor', 'Outdoor'];
              return types.map((t) {
                return Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    t,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis, // cut-off na ho
                    style: GoogleFonts.poppins(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,  // thoda bold for visibility
                      color: Colors.black87,
                    ),
                  ),
                );
              }).toList();
            },

            items: const ['Wall', 'Crystal', 'Panoramic', 'Indoor', 'Outdoor']
                .map((type) => DropdownMenuItem<String>(
              value: type,
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                type,
                style: GoogleFonts.poppins(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ))
                .toList(),

            onChanged: (val) {
              if (val != null) court.courtTypeController.text = val;
            },
            validator: (val) => val == null || val.isEmpty ? 'Required' : null,
          ),



          const SizedBox(height: 16),
            _subTitle('Regular Pricing'),
            const SizedBox(height: 8),
            _pricingOptions(controller, index),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => controller.addPricing(index),
                icon: Icon(Icons.add, color: secondaryColor, size: 20),
                label: Text(
                  'Add Pricing Option',
                  style: GoogleFonts.poppins(color: secondaryColor),
                ),
              ),
            ),

            const SizedBox(height: 8),
            _subTitle('Peak Hours Pricing'),
            const SizedBox(height: 8),
            _peakHoursOptions(controller, index),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => controller.addPeak(index),
                icon: Icon(Icons.add, color: secondaryColor, size: 20),
                label: Text(
                  'Add Peak Hours',
                  style: GoogleFonts.poppins(color: secondaryColor),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _subTitle(String text) => Text(
    text,
    style: GoogleFonts.poppins(
      fontWeight: FontWeight.w600,
      fontSize: 15,
      color: primaryColor,
    ),
  );

  Widget _pricingOptions(CreatePlaygroundController controller, int i) {
    final court = controller.courts[i];
    return Obx(
          () => Column(
        children: court.pricingList.asMap().entries.map((e) {
          final idx = e.key;
          final pricing = e.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: DropdownButtonFormField<int>(
                    value: (pricing.duration == 0) ? null : pricing.duration,
                    isExpanded: true,
                    menuMaxHeight: 280,
                    dropdownColor: Colors.white,
                    decoration: _decor(
                      label: 'Duration*',

                      icon: Icons.timer_outlined,
                    ).copyWith(
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    style: GoogleFonts.poppins(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                    hint: Text(
                      'Select duration',
                      style: GoogleFonts.poppins(color: Colors.grey.shade600),
                    ),
                    items: const [30, 60, 90, 120]
                        .map(
                          (d) => DropdownMenuItem<int>(
                        value: d,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text('$d minutes'),
                        ),
                      ),
                    )
                        .toList(),
                    selectedItemBuilder: (context) {
                      return const [30, 60, 90, 120]
                          .map(
                            (d) => Align(
                          alignment: Alignment.centerLeft,
                          child: Text('$d min'),
                        ),
                      )
                          .toList();
                    },
                    onChanged: (val) {
                      if (val == null) return;
                      pricing.duration = val;
                    },
                    validator: (val) => val == null ? 'Required' : null,
                  )


                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: pricing.priceController,
                    keyboardType: TextInputType.number,
                    decoration: _decor(label: 'Price*', prefixText: 'Rs. '),
                    validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                  ),
                ),
                if (court.pricingList.length > 1)
                  Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: IconButton(
                      icon: const Icon(Icons.remove_circle_outline, color: Colors.red, size: 22),
                      onPressed: () => controller.removePricing(i, idx),
                    ),
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _peakHoursOptions(CreatePlaygroundController controller, int ci) {
    final court = controller.courts[ci];
    return Obx(
          () => Column(
        children: court.peakHoursList.asMap().entries.map((e) {
          final idx = e.key;
          final ph = e.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _timeField(
                        context: Get.context!,
                        controller: ph.startTimeController,
                        label: 'Start Time*',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _timeField(
                        context: Get.context!,
                        controller: ph.endTimeController,
                        label: 'End Time*',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: ph.priceController,
                        keyboardType: TextInputType.number,
                        decoration: _decor(label: 'Peak Price*', prefixText: 'Rs. '),
                        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                      ),
                    ),
                    if (court.peakHoursList.length > 1)
                      Padding(
                        padding: const EdgeInsets.only(left: 6),
                        child: IconButton(
                          icon: const Icon(Icons.remove_circle_outline, color: Colors.red, size: 22),
                          onPressed: () => controller.removePeak(ci, idx),
                        ),
                      ),
                  ],
                ),
                const Divider(height: 24),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _addCourtButton(CreatePlaygroundController controller) => OutlinedButton.icon(
    onPressed: controller.addCourt,
    style: OutlinedButton.styleFrom(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
      side: BorderSide(color: secondaryColor),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    icon: Icon(Icons.add, color: secondaryColor),
    label: Text(
      'Add Another Court',
      style: GoogleFonts.poppins(color: secondaryColor, fontWeight: FontWeight.w600),
    ),
  );

  Widget _submitButton(CreatePlaygroundController controller) => ElevatedButton(
    onPressed: controller.isSubmitting.value ? null : controller.submitForm,
    style: ElevatedButton.styleFrom(
      backgroundColor: primaryColor,
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1.5,
      minimumSize: const Size(double.infinity, 50),
    ),
    child: controller.isSubmitting.value
        ? const SizedBox(
      width: 24,
      height: 24,
      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
    )
        : Text(
      'Create Club',
      style: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
    ),
  );
}
