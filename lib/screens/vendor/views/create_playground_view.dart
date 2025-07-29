// Updated premium UI version of CreatePlaygroundView
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:padel_pro/screens/vendor/vendor%20data%20controller/reate_playground_controller.dart';

class CreatePlaygroundView extends StatelessWidget {
  const CreatePlaygroundView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CreatePlaygroundController());

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF072A40),
        centerTitle: true,
        title: Text(
          'Create New Club',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _section('Club Details'),
              _textField(controller.nameC, 'Club Name*'),
              _textField(controller.sizeC, 'Club Size (e.g., 5-a-side)*'),
              _textField(controller.descriptionC, 'Description*', maxLines: 3),
              _timeField(context, controller.openingTimeC, 'Opening Time*'),
              _timeField(context, controller.closingTimeC, 'Closing Time*'),
              _textField(controller.locationC, 'Location/Address*'),
              _textField(controller.cityC, 'City*'),
              _textField(controller.phoneC, 'Phone Number', isRequired: false),
              _textField(controller.websiteC, 'Website', isRequired: false),
              const SizedBox(height: 24),
              _section('Photos'),
              _imagePicker(controller),
              const SizedBox(height: 24),
              _section('Facilities'),
              _facilities(controller),
              const SizedBox(height: 24),
              _section('Courts'),
              _courts(controller),
              ElevatedButton.icon(
                onPressed: controller.addCourt,
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  'Add Another Court',
                  selectionColor: Colors.white,
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF072A40),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: controller.submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF072A40),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                child: const Text(
                  'Create Club',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _section(String title) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Text(
      title,
      style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
    ),
  );

  Widget _textField(
    TextEditingController c,
    String label, {
    bool isRequired = true,
    int maxLines = 1,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: TextFormField(
      controller: c,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: isRequired
          ? (v) => v == null || v.isEmpty ? 'Required' : null
          : null,
    ),
  );

  Widget _timeField(
    BuildContext context,
    TextEditingController c,
    String label,
  ) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: TextFormField(
      controller: c,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        suffixIcon: const Icon(Icons.access_time),
      ),
      onTap: () async {
        final t = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );
        if (t != null) c.text = t.format(context);
      },
      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
    ),
  );

  Widget _imagePicker(CreatePlaygroundController controller) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Obx(
        () => controller.selectedImages.isEmpty
            ? const SizedBox.shrink()
            : SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: controller.selectedImages.length,
                  itemBuilder: (context, i) => Stack(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(controller.selectedImages[i].path),
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => controller.removeImage(i),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.black45,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
      const SizedBox(height: 8),
      OutlinedButton.icon(
        onPressed: controller.pickImages,
        icon: const Icon(Icons.add_a_photo, color: Color(0xFF072A40)),
        label: const Text('Select Photos', selectionColor: Color(0xFF072A40),style: TextStyle(color: Colors.black),),
      ),
    ],
  );

  Widget _facilities(CreatePlaygroundController controller) {
    final c = TextEditingController();
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: c,
                decoration: const InputDecoration(
                  labelText: 'Facility (e.g., Wifi, Parking)',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                controller.addFacility(c.text);
                c.clear();
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        Obx(
          () => Wrap(
            spacing: 8,
            children: controller.facilities
                .map(
                  (f) => Chip(
                    label: Text(f),
                    onDeleted: () => controller.removeFacility(f),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _courts(CreatePlaygroundController controller) => Obx(
    () => ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controller.courts.length,
      itemBuilder: (context, i) {
        final court = controller.courts[i];
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 3,
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Court ${i + 1}',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                    ),
                    if (controller.courts.length > 1)
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                        onPressed: () => controller.removeCourt(i),
                      ),
                  ],
                ),
                _textField(court.courtNumberController, 'Court Name*'),
                _textField(
                  court.courtTypeController,
                  'Court Type (e.g., Padel)*',
                ),
                const Divider(),
                Text(
                  'Pricing',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                ),
                _pricing(controller, i),
                TextButton.icon(
                  onPressed: () => controller.addPricingToCourt(i),
                  icon: const Icon(Icons.add_circle_outline,color: Colors.black,),
                  label: const Text(
                    'Add Pricing Option',
                    style: TextStyle(color: Colors.black),
                    selectionColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );

  Widget _pricing(CreatePlaygroundController controller, int courtIndex) {
    final court = controller.courts[courtIndex];
    return Obx(
      () => ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: court.pricingList.length,
        itemBuilder: (context, j) {
          final p = court.pricingList[j];
          return Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: DropdownButtonFormField<int>(
                    value: p.duration,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Duration*',
                    ),
                    items: [30, 60, 90, 120, 150, 180]
                        .map(
                          (v) =>
                              DropdownMenuItem(value: v, child: Text('$v min')),
                        )
                        .toList(),
                    onChanged: (v) => p.duration = v!,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: p.priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Price*',
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Required' : null,
                  ),
                ),
                if (court.pricingList.length > 1)
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: () =>
                        controller.removePricingFromCourt(courtIndex, j),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
