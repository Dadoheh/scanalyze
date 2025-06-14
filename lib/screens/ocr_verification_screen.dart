import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../services/api_service.dart';


class OcrVerificationScreen extends StatefulWidget {
  const OcrVerificationScreen({Key? key}) : super(key: key);

  @override
  _OcrVerificationScreenState createState() => _OcrVerificationScreenState();
}

class _OcrVerificationScreenState extends State<OcrVerificationScreen> {
  bool _isAnalyzing = false;
  final TextEditingController _rawTextController = TextEditingController();
  List<String> _ingredients = [];
  List<String> _ingredientIds = [];
  String _fileId = '';
  bool _isEditingText = false;
  Uint8List? _croppedImage;


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args != null) {
      _rawTextController.text = args['raw_text'] ?? '';
      _ingredients = List<String>.from(args['extracted_ingredients'] ?? []);
      _fileId = args['file_id'] ?? '';
      _croppedImage = args['cropped_image'];
      _ingredientIds = List.generate(
          _ingredients.length,
              (index) => 'ingredient_${DateTime.now().millisecondsSinceEpoch}_$index'
      );
    }
  }

  @override
  void dispose() {
    _rawTextController.dispose();
    super.dispose();
  }

  void _addIngredient() {
    setState(() {
      _ingredients.add('');
      _ingredientIds.add('ingredient_${DateTime.now().millisecondsSinceEpoch}_${_ingredients.length}');
    });
  }

  void _updateIngredient(int index, String value) {
    setState(() {
      if (index >= 0 && index < _ingredients.length) {
        _ingredients[index] = value;
      }
    });
  }

  void _removeIngredient(int index) {
    setState(() {
      // Usuń składnik i odpowiadające mu ID
      _ingredients.removeAt(index);
      _ingredientIds.removeAt(index);
    });
  }

  Future<void> _analyzeIngredients() async {
    final confirmedIngredients = _ingredients
        .where((ing) => ing.trim().isNotEmpty)
        .toList();

    if (confirmedIngredients.isEmpty) {
      Fluttertoast.showToast(msg: 'Proszę dodać co najmniej jeden składnik');
      return;
    }

    setState(() {
      _isAnalyzing = true;
    });

    try {
      final mappingResult = await ApiService.mapChemicalIdentities(confirmedIngredients);

      Navigator.pushReplacementNamed(
          context,
          '/analysis-result',
          arguments: {
            'chemical_mapping': mappingResult,
            'ingredients': confirmedIngredients,
            'file_id': _fileId,
          }
      );
    } catch (e) {
      Fluttertoast.showToast(msg: 'Błąd podczas analizy: ${e.toString()}');
    } finally {
      setState(() {
        _isAnalyzing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weryfikacja tekstu'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Card(
              color: Color(0xFFF0F7FF),
              child: Padding(
                padding: EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Sprawdź rozpoznany tekst i składniki',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Możesz edytować listę składników poniżej. '
                      'Przed dokonaniem analizy, pewnij się, że wszystkie składniki są poprawne.',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            if (_croppedImage != null)
              Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.memory(
                    _croppedImage! as Uint8List,
                    fit: BoxFit.contain,
                  ),
                ),
              ),

            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Rozpoznane składniki:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, color: Colors.blue),
                  onPressed: _addIngredient,
                  tooltip: 'Dodaj składnik',
                ),
              ],
            ),

            const SizedBox(height: 8),

            Expanded(
              child: _ingredients.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.format_list_bulleted, size: 48, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text(
                      'Nie rozpoznano składników',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: _addIngredient,
                      icon: const Icon(Icons.add),
                      label: const Text('Dodaj ręcznie'),
                    )
                  ],
                ),
              )
                  : ListView.builder(
                itemCount: _ingredients.length,
                itemBuilder: (context, index) {
                  final uniqueId = _ingredientIds[index];

                  return Card(
                    key: ValueKey(uniqueId),
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              key: ValueKey('textfield_$uniqueId'),
                              initialValue: _ingredients[index],
                              onChanged: (value) => _updateIngredient(index, value),
                              decoration: InputDecoration(
                                hintText: 'Składnik ${index + 1}',
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                            ),
                          ),
                          IconButton(
                            key: ValueKey('delete_$uniqueId'),
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            onPressed: () => _removeIngredient(index),
                            tooltip: 'Usuń',
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isAnalyzing ? null : _analyzeIngredients,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: _isAnalyzing
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Potwierdź i analizuj składniki',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}