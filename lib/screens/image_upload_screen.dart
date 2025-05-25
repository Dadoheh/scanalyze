import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class ImageUploadScreen extends StatefulWidget {
  const ImageUploadScreen({Key? key}) : super(key: key);

  @override
  _ImageUploadScreenState createState() => _ImageUploadScreenState();
}

class _ImageUploadScreenState extends State<ImageUploadScreen> {
  final ImagePicker _picker = ImagePicker();
  Uint8List? _imageBytes;
  bool _isUploading = false;
  String? _selectedFileName;

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _imageBytes = bytes;
        _selectedFileName = image.name;
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_imageBytes == null) {
      Fluttertoast.showToast(msg: 'Proszę wybrać zdjęcie');
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {

      final result = await ApiService.uploadProductImage(_imageBytes!);

      Navigator.pushNamed(context, '/analysis-result', arguments: result);
    } catch (e) {
      Fluttertoast.showToast(msg: 'Błąd podczas przesyłania: ${e.toString()}');
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prześlij zdjęcie produktu'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Wybierz zdjęcie produktu',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Upewnij się, że skład produktu jest dobrze widoczny i czytelny',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Obsługiwane formaty: JPG, JPEG, PNG',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 12,
                  color: Colors.blue,
                  fontWeight: FontWeight.bold
              ),
            ),
            const SizedBox(height: 24),

            // Podgląd zdjęcia
            Expanded(
              child: _imageBytes == null
                  ? Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    'Brak wybranego zdjęcia',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
                  : ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(
                  _imageBytes!,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            if (_selectedFileName != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  _selectedFileName!,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),

            const SizedBox(height: 20),

            // Przycisk wyboru pliku (tylko galeria dla web)
            ElevatedButton.icon(
              onPressed: _isUploading ? null : _pickImage,
              icon: const Icon(Icons.photo_library),
              label: const Text('Wybierz z galerii'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                minimumSize: const Size(200, 45),
              ),
            ),

            const SizedBox(height: 20),

            // Przycisk przesyłania
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isUploading || _imageBytes == null ? null : _uploadImage,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: _isUploading
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Text('Analizuj produkt'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

