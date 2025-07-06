import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class AddGroundScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();

  final titleCtrl = TextEditingController();
  final locationCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  final ratingCtrl = TextEditingController();

  final RxBool isRecommended = false.obs; // 👈 track state

  AddGroundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: Text('Add New Ground', style: GoogleFonts.poppins()),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildInput("Ground Title", titleCtrl),
              buildInput("Location", locationCtrl),
              buildInput("Price", priceCtrl, type: TextInputType.number),
              buildInput("Rating (1-5)", ratingCtrl, type: TextInputType.number),

              const SizedBox(height: 10),
              Text("Recommended?", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),

              const SizedBox(height: 6),
              Obx(() {
                return DropdownButtonFormField<String>(
                  value: isRecommended.value ? 'Yes' : 'No',
                  items: ['Yes', 'No'].map((e) {
                    return DropdownMenuItem<String>(
                      value: e,
                      child: Text(e),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onChanged: (value) {
                    isRecommended.value = (value == 'Yes');
                  },
                );
              }),

              const SizedBox(height: 20),
              Text("Upload Images", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),

              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Icon(Icons.image_outlined, size: 40, color: Colors.grey),
                ),
              ),

              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // ✅ Final collected values:
                    final data = {
                      'title': titleCtrl.text,
                      'location': locationCtrl.text,
                      'price': priceCtrl.text,
                      'rating': ratingCtrl.text,
                      'recommended': isRecommended.value, // 👈 true/false
                    };

                    // ✅ Print or send to DB
                    print(data);

                    Get.snackbar("Success", "Ground added successfully!");
                    Get.back();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF91E208),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Add Ground', style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.w500)),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildInput(String label, TextEditingController ctrl, {TextInputType? type}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: ctrl,
        keyboardType: type,
        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
