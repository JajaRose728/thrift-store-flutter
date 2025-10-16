import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/supabase_service.dart';
import '../../widgets/custom_input_field.dart';

const Color beigeAccent = Color(0xFFFAD9C1);
const Color softPink = Color(0xFFFF8FAB);
const Color mutedPink = Color(0xFFE57A8B);
const Color inputFill = Colors.white;

class AddItemPage extends StatefulWidget {
  const AddItemPage({super.key});
  @override
  AddItemPageState createState() => AddItemPageState();
}

class AddItemPageState extends State<AddItemPage> {
  // --- No changes to controllers or state variables ---
  final _nameCtrl = TextEditingController();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();

  File? _imageFile;
  Uint8List? _imageBytes;
  final picker = ImagePicker();
  bool _uploading = false;

  Future<void> pickImage() async {
    final XFile? img = await picker.pickImage(source: ImageSource.gallery);
    if (img == null) return;
    if (kIsWeb) {
      final bytes = await img.readAsBytes();
      setState(() {
        _imageBytes = bytes;
        _imageFile = null;
      });
    } else {
      setState(() {
        _imageFile = File(img.path);
        _imageBytes = null;
      });
    }
  }

  Future<void> _handleUpload() async {
    // --- Form validation ---
    if (_nameCtrl.text.trim().isEmpty ||
        _titleCtrl.text.trim().isEmpty ||
        _priceCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please fill all required fields.'),
            backgroundColor: Colors.redAccent),
      );
      return;
    }
    if (_imageFile == null && _imageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select an image.'),
            backgroundColor: Colors.redAccent),
      );
      return;
    }

    setState(() => _uploading = true);
    final svc = Provider.of<SupabaseService>(context, listen: false);
    final imageBytes = kIsWeb ? _imageBytes! : await _imageFile!.readAsBytes();
    final imageName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    await svc.addItem(
      title: _titleCtrl.text.trim(),
      desc: _descCtrl.text.trim(),
      price: double.tryParse(_priceCtrl.text) ?? 0,
      contact: _contactCtrl.text.trim(),
      uploaderName: _nameCtrl.text.trim(),
      imageBytes: imageBytes,
      imageName: imageName,
    );
    setState(() => _uploading = false);
    if (svc.error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Item added successfully!'),
            backgroundColor: softPink),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error: ${svc.error}'),
            backgroundColor: Colors.redAccent),
      );
    }
  }

  Widget _buildThemedInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: GoogleFonts.montserrat(color: Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.montserrat(color: mutedPink, fontWeight: FontWeight.w500),
        prefixIcon: Icon(icon, color: softPink),
        fillColor: inputFill,
        filled: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: beigeAccent, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: softPink, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    final canUpload = (_imageFile != null || _imageBytes != null) && !_uploading;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(

        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: mutedPink),
        title: Text(
          'Add a New Item',
          style: GoogleFonts.pacifico(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: mutedPink,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              softPink,    // Pink starts in the top-left corner
              beigeAccent, // Beige ends in the bottom-right corner
            ],
            stops: [0.2, 0.8],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildThemedInputField(
                  controller: _titleCtrl,
                  label: 'Item Title',
                  icon: Icons.label_outline,
                ),
                const SizedBox(height: 16),
                _buildThemedInputField(
                    controller: _descCtrl,
                    label: 'Description',
                    icon: Icons.description_outlined,
                    maxLines: 3),
                const SizedBox(height: 16),
                _buildThemedInputField(
                    controller: _priceCtrl,
                    label: 'Price (PHP)',
                    icon: Icons.attach_money,
                    keyboardType: TextInputType.number),
                const SizedBox(height: 16),
                _buildThemedInputField(
                    controller: _nameCtrl,
                    label: 'Your Display Name',
                    icon: Icons.person_outline),
                const SizedBox(height: 16),
                _buildThemedInputField(
                    controller: _contactCtrl,
                    label: 'Contact (Email/Phone)',
                    icon: Icons.contact_mail_outlined),
                const SizedBox(height: 24),

                // --- Image picker and display ---
                (_imageFile == null && _imageBytes == null)
                    ? ElevatedButton.icon(
                  icon: const Icon(Icons.photo_library, size: 24),
                  label: Text(
                    'Choose Photo',
                    style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w600, color: softPink),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: inputFill, // White fill
                    foregroundColor: softPink,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: softPink, width: 1.5),
                    ),
                    elevation: 0,
                  ),
                  onPressed: pickImage,
                )
                    : Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: kIsWeb
                          ? Image.memory(_imageBytes!, height: 200, width: double.infinity, fit: BoxFit.cover)
                          : Image.file(_imageFile!, height: 200, width: double.infinity, fit: BoxFit.cover),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => setState(() {
                        _imageFile = null;
                        _imageBytes = null;
                      }),
                      child: Text(
                        'Choose a different image',
                        style: GoogleFonts.montserrat(color: mutedPink),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: canUpload ? _handleUpload : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: softPink, // Primary soft pink button
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: softPink.withOpacity(0.5),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 3,
                    ),
                    child: _uploading
                        ? const CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    )
                        : Text(
                      'Upload Item',
                      style: GoogleFonts.pacifico(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}