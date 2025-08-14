
// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../vendor data controller/reate_playground_controller.dart';

class CreatePlaygroundView extends StatelessWidget {
  const CreatePlaygroundView({super.key});

  final Color primaryColor = const Color(0xFF072A40);
  final Color secondaryColor = const Color(0xFF072A40);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CreatePlaygroundController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: primaryColor,
        centerTitle: true,
        title: Text(
          'Create New Club',
          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSectionHeader('Basic Information'),
              _buildCard(children: [
                _buildTextField(controller: controller.nameC, label: 'Club Name*', icon: Icons.sports_soccer),
                const SizedBox(height: 16),
                _buildTextField(controller: controller.sizeC, label: 'Court Size*', icon: Icons.aspect_ratio),
              ]),

              const SizedBox(height: 20),
              _buildSectionHeader('Description'),
              _buildCard(children: [
                _buildTextField(
                  controller: controller.descriptionC,
                  label: 'Detailed Description*',
                  icon: Icons.description,
                  maxLines: 4,
                ),
              ]),

              const SizedBox(height: 20),
              _buildSectionHeader('Contact Information'),
              _buildCard(children: [
                _buildTextField(controller: controller.locationC, label: 'Full Address*', icon: Icons.location_on),
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(child: _buildTextField(controller: controller.cityC, label: 'City*', icon: Icons.location_city)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTextField(controller: controller.phoneC, label: 'Phone Number*', icon: Icons.phone, keyboardType: TextInputType.phone)),
                ]),
                const SizedBox(height: 16),
                _buildTextField(controller: controller.townC, label: 'Town*', icon: Icons.location_on_outlined),
                const SizedBox(height: 16),
                _buildTextField(controller: controller.websiteC, label: 'Website (optional)', icon: Icons.public, isRequired: false),
              ]),

              const SizedBox(height: 20),
              _buildSectionHeader('Operating Hours'),
              _buildCard(children: [
                Row(children: [
                  Expanded(child: _buildTimeField(context: context, controller: controller.openingTimeC, label: 'Opening Time*')),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTimeField(context: context, controller: controller.closingTimeC, label: 'Closing Time*')),
                ]),
              ]),

              const SizedBox(height: 20),
              _buildSectionHeader('Photos (3-5 recommended)'),
              _buildCard(children: [_buildImagePicker(controller)]),

              const SizedBox(height: 20),
              _buildSectionHeader('Facilities'),
              _buildCard(children: [_buildFacilitiesGrid(controller)]),

              const SizedBox(height: 20),
              _buildSectionHeader('Add Courts'),
              Obx(() => Column(children: [
                ...controller.courts.asMap().entries.map((e) {
                  final index = e.key;
                  final courtModel = e.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: _buildCourtCard(controller, index, courtModel),
                  );
                }),
                _buildAddCourtButton(controller),
              ])),

              const SizedBox(height: 30),
              Obx(() => _buildSubmitButton(controller)),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text(title,
        style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: primaryColor)),
  );

  Widget _buildCard({required List<Widget> children}) => Card(
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
    child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children)),
  );

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    IconData? icon,
    bool isRequired = true,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? prefixText,
  }) => TextFormField(
    controller: controller,
    maxLines: maxLines,
    keyboardType: keyboardType,
    decoration: InputDecoration(
      labelText: label,
      prefixText: prefixText,
      prefixIcon: icon != null ? Icon(icon, size: 20) : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: primaryColor, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
    ),
    validator: isRequired ? (val) => val == null || val.isEmpty ? 'This field is required' : null : null,
  );

  String _toHHmm(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Widget _buildTimeField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
  }) => TextFormField(
    controller: controller,
    readOnly: true,
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: const Icon(Icons.access_time, size: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
    ),
    onTap: () async {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        // Optional: show the picker itself in 24h mode
        builder: (ctx, child) => MediaQuery(
          data: MediaQuery.of(ctx!).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        ),
      );
      if (time != null) controller.text = _toHHmm(time); // <-- key change
    },
    validator: (val) {
      if (val == null || val.isEmpty) return 'Required';
      final ok = RegExp(r'^(?:[01]\d|2[0-3]):[0-5]\d$').hasMatch(val);
      return ok ? null : 'Use 24-hour HH:MM';
    },
  );





  // Widget _buildTimeField({
  //   required BuildContext context,
  //   required TextEditingController controller,
  //   required String label,
  // }) => TextFormField(
  //   controller: controller,
  //   readOnly: true,
  //   decoration: InputDecoration(
  //     labelText: label,
  //     prefixIcon: const Icon(Icons.access_time, size: 20),
  //     border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade400)),
  //     contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
  //   ),
  //   onTap: () async {
  //     final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
  //     if (time != null) controller.text = time.format(context);
  //   },
  //   validator: (val) => val == null || val.isEmpty ? 'Required' : null,
  // );

  Widget _buildImagePicker(CreatePlaygroundController controller) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Obx(() => controller.selectedImages.isEmpty
          ? Container(
        height: 120,
        decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(10)),
        child: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.image, size: 40, color: Colors.grey.shade400),
            const SizedBox(height: 8),
            Text('No images selected', style: GoogleFonts.poppins(color: Colors.grey.shade600)),
          ]),
        ),
      )
          : SizedBox(
        height: 130,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: controller.selectedImages.length,
          itemBuilder: (_, i) => Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Stack(children: [
              Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(
                    image: FileImage(File(controller.selectedImages[i].path)),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                top: 6,
                right: 6,
                child: GestureDetector(
                  onTap: () => controller.removeImage(i),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), shape: BoxShape.circle),
                    child: const Icon(Icons.close, size: 16, color: Colors.white),
                  ),
                ),
              ),
            ]),
          ),
        ),
      )),
      const SizedBox(height: 12),
      OutlinedButton(
        onPressed: controller.pickImages,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: BorderSide(color: secondaryColor),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.add_photo_alternate, color: secondaryColor),
          const SizedBox(width: 8),
          Text('Upload Photos', style: GoogleFonts.poppins(color: secondaryColor, fontWeight: FontWeight.w500)),
        ]),
      ),
    ],
  );

  Widget _buildFacilitiesGrid(CreatePlaygroundController controller) {
    final facilityOptions = [
      {'icon': Icons.wifi, 'label': 'WiFi'},
      {'icon': Icons.local_parking, 'label': 'Parking'},
      {'icon': Icons.shower, 'label': 'Showers'},
      {'icon': Icons.local_cafe, 'label': 'Cafe'},
      {'icon': Icons.lock, 'label': 'Lockers'},
    ];
    return Obx(() => Wrap(
      spacing: 10,
      runSpacing: 10,
      children: facilityOptions.map((f) {
        final isSelected = controller.facilities.contains(f['label']);
        return ChoiceChip(
          label: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(f['icon'] as IconData, size: 18, color: isSelected ? Colors.white : primaryColor),
            const SizedBox(width: 6),
            Text(f['label'] as String,
                style: GoogleFonts.poppins(color: isSelected ? Colors.white : primaryColor)),
          ]),
          selected: isSelected,
          onSelected: (sel) {
            sel ? controller.facilities.add(f['label'] as String) : controller.facilities.remove(f['label'] as String);
          },
          selectedColor: primaryColor,
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: isSelected ? primaryColor : Colors.grey.shade400)),
        );
      }).toList(),
    ));
  }

  Widget _buildCourtCard(
      CreatePlaygroundController controller,
      int index,
      CourtUIModel court,
      ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Court ${index + 1}',
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: primaryColor)),
            if (controller.courts.length > 1)
              IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => controller.removeCourt(index)),
          ]),
          const SizedBox(height: 12),
          _buildTextField(controller: court.courtNumberController, label: 'Court Name*', icon: Icons.sports_handball),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: court.courtTypeController.text.isEmpty ? null : court.courtTypeController.text,
            decoration: InputDecoration(
              labelText: 'Court Type*',
              prefixIcon: const Icon(Icons.category, size: 20),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade400)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            items: ['Wall', 'Crystal', 'Panoramic', 'Indoor', 'Outdoor']
                .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                .toList(),
            onChanged: (val) {
              if (val != null) court.courtTypeController.text = val;
            },
            validator: (val) => val == null || val.isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: 16),
          Text('Regular Pricing',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 15, color: primaryColor)),
          const SizedBox(height: 8),
          _buildPricingOptions(controller, index),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => controller.addPricing(index),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.add, color: secondaryColor, size: 20),
              const SizedBox(width: 6),
              Text('Add Pricing Option', style: GoogleFonts.poppins(color: secondaryColor)),
            ]),
          ),
          const SizedBox(height: 16),
          Text('Peak Hours Pricing',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 15, color: primaryColor)),
          const SizedBox(height: 8),
          _buildPeakHoursOptions(controller, index),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => controller.addPeak(index),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.add, color: secondaryColor, size: 20),
              const SizedBox(width: 6),
              Text('Add Peak Hours', style: GoogleFonts.poppins(color: secondaryColor)),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _buildPricingOptions(CreatePlaygroundController controller, int i) {
    final court = controller.courts[i];
    return Obx(() => Column(children: court.pricingList.asMap().entries.map((e) {
      final idx = e.key;
      final pricing = e.value;
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(children: [
          Expanded(
            flex: 3,
            child: DropdownButtonFormField<int>(
              value: pricing.duration,
              decoration: InputDecoration(
                labelText: 'Duration*',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade400)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              items: [30, 60, 90, 120].map((d) => DropdownMenuItem(value: d, child: Text('$d minutes'))).toList(),
              onChanged: (val) => pricing.duration = val!,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: TextFormField(
              controller: pricing.priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Price*',
                prefixText: 'Rs. ',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade400)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
          ),
          if (court.pricingList.length > 1)
            IconButton(icon: const Icon(Icons.remove, color: Colors.red, size: 20),
                onPressed: () => controller.removePricing(i, idx)),
        ]),
      );
    }).toList()));
  }

  Widget _buildPeakHoursOptions(CreatePlaygroundController controller, int ci) {
    final court = controller.courts[ci];
    return Obx(() => Column(children: court.peakHoursList.asMap().entries.map((e) {
      final idx = e.key;
      final ph = e.value;
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(children: [
          Row(children: [
            Expanded(child: _buildTimeField(context: Get.context!, controller: ph.startTimeController, label: 'Start Time*')),
            const SizedBox(width: 12),
            Expanded(child: _buildTimeField(context: Get.context!, controller: ph.endTimeController, label: 'End Time*')),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(
              child: TextFormField(
                controller: ph.priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Peak Price*',
                  prefixText: 'Rs. ',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade400)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
            ),
            if (court.peakHoursList.length > 1)
              IconButton(icon: const Icon(Icons.remove, color: Colors.red, size: 20),
                  onPressed: () => controller.removePeak(ci, idx)),
          ]),
          const Divider(height: 24),
        ]),
      );
    }).toList()));
  }

  Widget _buildAddCourtButton(CreatePlaygroundController controller) => OutlinedButton(
    onPressed: controller.addCourt,
    style: OutlinedButton.styleFrom(
      padding: const EdgeInsets.symmetric(vertical: 14),
      side: BorderSide(color: secondaryColor),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.add, color: secondaryColor),
      const SizedBox(width: 8),
      Text('Add Another Court', style: GoogleFonts.poppins(color: secondaryColor, fontWeight: FontWeight.w500)),
    ]),
  );

  Widget _buildSubmitButton(CreatePlaygroundController controller) => ElevatedButton(
    onPressed: controller.isSubmitting.value ? null : controller.submitForm,
    style: ElevatedButton.styleFrom(
      backgroundColor: primaryColor,
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 2,
      minimumSize: const Size(double.infinity, 50),
    ),
    child: controller.isSubmitting.value
        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
        : Text('Create Club', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
  );
}
