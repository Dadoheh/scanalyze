import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:fluttertoast/fluttertoast.dart';
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

  final TransformationController _transformationController = TransformationController();
  double _currentScale = 1.0;
  static const double _minScale = 1.0;
  static const double _maxScale = 5.0;

  final GlobalKey _imageKey = GlobalKey();

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
        _resetZoom();
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
      final Uint8List? croppedImage = await _captureVisibleArea();

      if (croppedImage == null || croppedImage.isEmpty) {
        Fluttertoast.showToast(
          msg: 'Problem z przycięciem obrazu. Spróbuj ponownie lub zmień powiększenie.',
          toastLength: Toast.LENGTH_LONG,
        );
        setState(() {
          _isUploading = false;
        });
        return;
      }

      final String mimeType = 'image/png';
      final String fileName = 'cropped_image.png';

      final result = await ApiService.uploadImageWithMetadata(
          croppedImage,
          fileName: fileName,
          mimeType: mimeType
      );

      Navigator.pushNamed(context, '/analysis-result', arguments: result);
    } catch (e) {
      print('Error uploading: $e');
      Fluttertoast.showToast(msg: 'Błąd podczas przesyłania: ${e.toString()}');
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<Uint8List?> _captureVisibleArea() async {
    await Future.delayed(const Duration(milliseconds: 50));

    try {
      if (_imageKey.currentContext == null) {
        print('Context jest null');
        return null;
      }

      final RenderRepaintBoundary? boundary =
      _imageKey.currentContext!.findRenderObject() as RenderRepaintBoundary?;

      if (boundary == null) {
        print('Boundary jest null');
        return null;
      }

      final ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null || byteData.lengthInBytes == 0) {
        print('ByteData jest null lub pusty');
        return null;
      }

      return byteData.buffer.asUint8List();
    } catch (e) {
      print('Error capturing image: $e');
      return null;
    }
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  void _resetZoom() {
    setState(() {
      _transformationController.value = Matrix4.identity();
      _currentScale = 1.0;
    });
  }

  void _zoomIn() {
    if(_currentScale < _maxScale) {
      setState(() {
        _currentScale += 0.1;
        final zoomed = Matrix4.identity()..scale(_currentScale);
        _transformationController.value = zoomed;
      });
    }
  }

  void _zoomOut() {
    if (_currentScale > _minScale) {
      setState(() {
        _currentScale -= 0.1;
        final zoomed = Matrix4.identity()..scale(_currentScale);
        _transformationController.value = zoomed;
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

            if (_imageBytes != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.zoom_out),
                    onPressed: _zoomOut,
                    tooltip: 'Zmniejsz',
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _resetZoom,
                    tooltip: 'Resetuj widok',
                  ),
                  IconButton(
                    icon: const Icon(Icons.zoom_in),
                    onPressed: _zoomIn,
                    tooltip: 'Powiększ',
                  ),
                ],
              ),
            const SizedBox(height: 8),

            // Podgląd zdjęcia z przesuwaniem
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
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: RepaintBoundary(
                    key: _imageKey,
                    child: InteractiveViewer(
                      transformationController: _transformationController,
                      boundaryMargin: const EdgeInsets.all(20.0),
                      minScale: _minScale,
                      maxScale: _maxScale,
                      child: Image.memory(
                        _imageBytes!,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
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

