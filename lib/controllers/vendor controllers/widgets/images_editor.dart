import 'dart:io' as io;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ImagesEditor extends StatefulWidget {
  const ImagesEditor({required this.initial, required this.onImagesChanged});

  final List<String> initial;
  final void Function(List<String> addPaths, List<String> removeUrls) onImagesChanged;

  @override
  State<ImagesEditor> createState() => _ImagesEditorState();
}

class _ImagesEditorState extends State<ImagesEditor> {
  final List<String> _existing = <String>[]; // URLs
  final List<String> _toRemove = <String>[]; // URLs
  final List<XFile> _toAdd = <XFile>[]; // picked files

  @override
  void initState() {
    super.initState();
    _existing.addAll(widget.initial);
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final files = await picker.pickMultiImage(imageQuality: 85);
    if (files != null && files.isNotEmpty) {
      setState(() => _toAdd.addAll(files));
      // Notify parent immediately for instant UI update
      widget.onImagesChanged(
        _toAdd.map((e) => e.path).toList(),
        _toRemove,
      );
    }
  }

  void _preview(String url) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        child: InteractiveViewer(
          minScale: 0.8,
          maxScale: 4,
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.network(
                  url,
                  fit: BoxFit.contain,
                  loadingBuilder: (c, w, p) {
                    if (p == null) return w;
                    return const Center(child: CircularProgressIndicator(color: Colors.grey));
                  },
                  errorBuilder: (_, __, ___) => const Center(
                    child: Icon(Icons.broken_image, color: Colors.white54, size: 64),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  onPressed: Get.back,
                  icon: const Icon(Icons.close, color: Colors.white70),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _removeImage(String url) {
    setState(() {
      _toRemove.add(url);
      _existing.remove(url);
    });
    // Notify parent immediately for instant UI update
    widget.onImagesChanged(
      _toAdd.map((e) => e.path).toList(),
      _toRemove,
    );
  }

  void _removeNewImage(XFile file) {
    setState(() => _toAdd.remove(file));
    // Notify parent immediately for instant UI update
    widget.onImagesChanged(
      _toAdd.map((e) => e.path).toList(),
      _toRemove,
    );
  }

  @override
  Widget build(BuildContext context) {
    const brand = Color(0xFF0C1E2C);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.photo_library, color: brand),
              SizedBox(width: 8),
              Text('Photos', style: TextStyle(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 10),
          if (_existing.isEmpty && _toAdd.isEmpty)
            const Text('No photos yet. Add some!', style: TextStyle(color: Colors.black54))
          else
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                ..._existing.map((url) => Stack(
                  children: [
                    GestureDetector(
                      onTap: () => _preview(url),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: SizedBox(
                          width: 90,
                          height: 70,
                          child: Image.network(
                            url,
                            fit: BoxFit.cover,
                            loadingBuilder: (c, w, p) {
                              if (p == null) return w;
                              return const Center(
                                child: SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.grey),
                                ),
                              );
                            },
                            errorBuilder: (_, __, ___) => Container(
                              color: Colors.grey[200],
                              child: const Icon(Icons.broken_image, color: Colors.black38),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: InkWell(
                        onTap: () => _removeImage(url),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.close, size: 14, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                )),
                ..._toAdd.map((x) => Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: SizedBox(
                        width: 90,
                        height: 70,
                        child: Image.file(
                          io.File(x.path),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(color: Colors.grey[200]),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: InkWell(
                        onTap: () => _removeNewImage(x),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.close, size: 14, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                )),
              ],
            ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: _pickImages,
            icon: const Icon(Icons.add_photo_alternate, color: brand),
            label: const Text('Add Photos', style: TextStyle(color: brand)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: brand),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }
}
