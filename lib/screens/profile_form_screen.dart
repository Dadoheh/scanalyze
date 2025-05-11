import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../models/user_profile.dart';
import '../services/api_service.dart';
import '../services/api_service.dart';

class ProfileFormScreen extends StatefulWidget {
  const ProfileFormScreen({super.key});

  @override
  State<ProfileFormScreen> createState() => _ProfileFormScreenState();
}

class _ProfileFormScreenState extends State<ProfileFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  int _currentPageIndex = 0;
  bool _isLoading = false;

  int? _age;
  String? _gender;
  double? _weight;
  double? _height;

  String? _skinType;
  bool? _sensitiveSkin;
  bool? _atopicSkin;
  bool? _acneProne;

  bool? _hasAllergies;
  List<String> _cosmeticAllergies = [];
  List<String> _generalAllergies = [];

  bool? _acneVulgaris;
  bool? _psoriasis;
  bool? _eczema;
  bool? _rosacea;

  bool? _photosensitizingDrugs;
  bool? _diuretics;
  String? _otherMedications;
  String? _medicalProcedures;

  bool? _smoking;
  String? _stressLevel;
  bool? _tanning;

  final List<String> _pageTitles = [
    'Cechy fizjologiczne',
    'Typ skóry i wrażliwość',
    'Alergie i nadwrażliwości',
    'Schorzenia dermatologiczne',
    'Stosowane leki',
    'Inne leki i zabiegi',
    'Styl życia i nawyki'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Formularz zdrowotny (${_currentPageIndex + 1}/${_pageTitles.length})'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                _pageTitles[_currentPageIndex],
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (index) {
                    setState(() {
                      _currentPageIndex = index;
                    });
                  },
                  children: [
                    _buildPhysiologicalForm(),
                    _buildSkinTypeForm(),
                    _buildAllergiesForm(),
                    _buildDermatologicalConditionsForm(),
                    _buildMedicationsForm(),
                    _buildOtherMedicationsForm(),
                    _buildLifestyleForm(),
                  ],
                ),
              ),
              _buildNavigationButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _currentPageIndex > 0
            ? ElevatedButton(
          onPressed: () {
            _pageController.previousPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
          child: const Text('Wstecz'),
        )
            : const SizedBox(),
        _currentPageIndex < _pageTitles.length - 1
            ? ElevatedButton(
          onPressed: _validateAndContinue,
          child: const Text('Dalej'),
        )
            : ElevatedButton(
          onPressed: _isLoading ? null : _submitForm,
          child: _isLoading
              ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
            ),
          )
              : const Text('Zapisz'),
        ),
      ],
    );
  }

  // Validation and next page logic
  void _validateAndContinue() {
    if (_currentPageIndex == 0) {
      // Walidacja dla strony z cechami fizjologicznymi (wymagane)
      if (_age == null || _gender == null || _weight == null || _height == null) {
        Fluttertoast.showToast(msg: 'Wypełnij wszystkie wymagane pola');
        return;
      }
    }

    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  // Saving the form
  Future<void> _submitForm() async {
    if (_currentPageIndex == 0 && (_age == null || _gender == null || _weight == null || _height == null)) {
      Fluttertoast.showToast(msg: 'Wypełnij wszystkie wymagane pola');
      _pageController.jumpToPage(0);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final profile = UserProfile(
        age: _age,
        gender: _gender,
        weight: _weight,
        height: _height,
        skinType: _skinType,
        sensitiveSkin: _sensitiveSkin,
        atopicSkin: _atopicSkin,
        acneProne: _acneProne,
        hasAllergies: _hasAllergies,
        cosmeticAllergies: _cosmeticAllergies,
        generalAllergies: _generalAllergies,
        acneVulgaris: _acneVulgaris,
        psoriasis: _psoriasis,
        eczema: _eczema,
        rosacea: _rosacea,
        photosensitizingDrugs: _photosensitizingDrugs,
        diuretics: _diuretics,
        otherMedications: _otherMedications,
        medicalProcedures: _medicalProcedures,
        smoking: _smoking,
        stressLevel: _stressLevel,
        tanning: _tanning,
      );

      await ApiService.updateUserProfile(profile);

      Fluttertoast.showToast(msg: 'Dane zostały zapisane pomyślnie!');
      Navigator.pop(context);
    } catch (e) {
      Fluttertoast.showToast(msg: 'Błąd podczas zapisywania danych: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // FORM FOR EACH PAGE

  // Page 1: Physiological features
  Widget _buildPhysiologicalForm() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('* Pola wymagane', style: TextStyle(color: Colors.red)),
          const SizedBox(height: 16),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Wiek *',
              hintText: 'Podaj swój wiek',
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              if (value.isNotEmpty) {
                setState(() {
                  _age = int.tryParse(value);
                });
              }
            },
            initialValue: _age?.toString(),
          ),
          const SizedBox(height: 16),
          const Text('Płeć *'),
          Row(
            children: [
              Radio<String>(
                value: 'Kobieta',
                groupValue: _gender,
                onChanged: (value) {
                  setState(() {
                    _gender = value;
                  });
                },
              ),
              const Text('Kobieta'),
              Radio<String>(
                value: 'Mężczyzna',
                groupValue: _gender,
                onChanged: (value) {
                  setState(() {
                    _gender = value;
                  });
                },
              ),
              const Text('Mężczyzna'),
              Radio<String>(
                value: 'Inne',
                groupValue: _gender,
                onChanged: (value) {
                  setState(() {
                    _gender = value;
                  });
                },
              ),
              const Text('Inne'),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Masa ciała (kg) *',
              hintText: 'Podaj masę ciała w kg',
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              if (value.isNotEmpty) {
                setState(() {
                  _weight = double.tryParse(value);
                });
              }
            },
            initialValue: _weight?.toString(),
          ),
          const SizedBox(height: 16),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Wzrost (cm) *',
              hintText: 'Podaj wzrost w cm',
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              if (value.isNotEmpty) {
                setState(() {
                  _height = double.tryParse(value);
                });
              }
            },
            initialValue: _height?.toString(),
          ),
        ],
      ),
    );
  }

  // Page 2: Skin type and sensitivity
  Widget _buildSkinTypeForm() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Rodzaj skóry'),
          DropdownButtonFormField<String>(
            value: _skinType,
            items: const [
              DropdownMenuItem(value: 'Sucha', child: Text('Sucha')),
              DropdownMenuItem(value: 'Tłusta', child: Text('Tłusta')),
              DropdownMenuItem(value: 'Mieszana', child: Text('Mieszana')),
              DropdownMenuItem(value: 'Normalna', child: Text('Normalna')),
            ],
            onChanged: (value) {
              setState(() {
                _skinType = value;
              });
            },
            decoration: const InputDecoration(
              hintText: 'Wybierz rodzaj skóry',
            ),
          ),
          const SizedBox(height: 16),
          CheckboxListTile(
            title: const Text('Skóra wrażliwa/nadreaktywna'),
            value: _sensitiveSkin ?? false,
            onChanged: (value) {
              setState(() {
                _sensitiveSkin = value;
              });
            },
          ),
          CheckboxListTile(
            title: const Text('Skóra atopowa'),
            value: _atopicSkin ?? false,
            onChanged: (value) {
              setState(() {
                _atopicSkin = value;
              });
            },
          ),
          CheckboxListTile(
            title: const Text('Trądzik'),
            value: _acneProne ?? false,
            onChanged: (value) {
              setState(() {
                _acneProne = value;
              });
            },
          ),
        ],
      ),
    );
  }

  // Page 3: Allergies and sensitivities
  Widget _buildAllergiesForm() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CheckboxListTile(
            title: const Text('Alergie na składniki kosmetyków'),
            value: _hasAllergies ?? false,
            onChanged: (value) {
              setState(() {
                _hasAllergies = value;
              });
            },
          ),
          if (_hasAllergies == true) ...[
            const SizedBox(height: 8),
            const Text('Wybierz rodzaje alergii kosmetycznych:'),
            CheckboxListTile(
              title: const Text('Substancje zapachowe'),
              value: _cosmeticAllergies.contains('Substancje zapachowe'),
              onChanged: (value) {
                setState(() {
                  if (value == true) {
                    _cosmeticAllergies.add('Substancje zapachowe');
                  } else {
                    _cosmeticAllergies.remove('Substancje zapachowe');
                  }
                });
              },
              dense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
            ),
            CheckboxListTile(
              title: const Text('Konserwanty'),
              value: _cosmeticAllergies.contains('Konserwanty'),
              onChanged: (value) {
                setState(() {
                  if (value == true) {
                    _cosmeticAllergies.add('Konserwanty');
                  } else {
                    _cosmeticAllergies.remove('Konserwanty');
                  }
                });
              },
              dense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
            ),
            CheckboxListTile(
              title: const Text('Barwniki'),
              value: _cosmeticAllergies.contains('Barwniki'),
              onChanged: (value) {
                setState(() {
                  if (value == true) {
                    _cosmeticAllergies.add('Barwniki');
                  } else {
                    _cosmeticAllergies.remove('Barwniki');
                  }
                });
              },
              dense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
            ),
            const SizedBox(height: 8),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Inne alergie kosmetyczne (oddziel przecinkiem)',
                hintText: 'Np. nikiel, lateks, aloes',
              ),
              onChanged: (value) {
                if (value.isNotEmpty) {
                  final List<String> others = value.split(',')
                      .map((e) => e.trim())
                      .where((e) => e.isNotEmpty)
                      .toList();

                  setState(() {
                    _generalAllergies = others;
                  });
                }
              },
            ),
          ],
        ],
      ),
    );
  }

  // Page 4: Dermatological conditions
  Widget _buildDermatologicalConditionsForm() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Występujące schorzenia:'),
          CheckboxListTile(
            title: const Text('Trądzik pospolity'),
            value: _acneVulgaris ?? false,
            onChanged: (value) {
              setState(() {
                _acneVulgaris = value;
              });
            },
          ),
          CheckboxListTile(
            title: const Text('Łuszczyca'),
            value: _psoriasis ?? false,
            onChanged: (value) {
              setState(() {
                _psoriasis = value;
              });
            },
          ),
          CheckboxListTile(
            title: const Text('Egzema/atopowe zapalenie skóry'),
            value: _eczema ?? false,
            onChanged: (value) {
              setState(() {
                _eczema = value;
              });
            },
          ),
          CheckboxListTile(
            title: const Text('Trądzik różowaty'),
            value: _rosacea ?? false,
            onChanged: (value) {
              setState(() {
                _rosacea = value;
              });
            },
          ),
        ],
      ),
    );
  }

  // Page 5: Medications
  Widget _buildMedicationsForm() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Stosowane leki:'),
          CheckboxListTile(
            title: const Text('Leki fotouczulające (np. tetracykliny)'),
            value: _photosensitizingDrugs ?? false,
            onChanged: (value) {
              setState(() {
                _photosensitizingDrugs = value;
              });
            },
          ),
          CheckboxListTile(
            title: const Text('Leki moczopędne (np. hydrochlorotiazyd, furosemid)'),
            value: _diuretics ?? false,
            onChanged: (value) {
              setState(() {
                _diuretics = value;
              });
            },
          ),
        ],
      ),
    );
  }

  // Page 6: Other medications and procedures
  Widget _buildOtherMedicationsForm() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Inne leki dermatologiczne',
              hintText: 'Wpisz nazwy innych stosowanych leków',
            ),
            maxLines: 3,
            onChanged: (value) {
              setState(() {
                _otherMedications = value;
              });
            },
            initialValue: _otherMedications,
          ),
          const SizedBox(height: 16),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Przebyte zabiegi medyczne',
              hintText: 'Opisz zabiegi medyczne i kosmetyczne',
            ),
            maxLines: 3,
            onChanged: (value) {
              setState(() {
                _medicalProcedures = value;
              });
            },
            initialValue: _medicalProcedures,
          ),
        ],
      ),
    );
  }

  // Page 7: Lifestyle and habits
  Widget _buildLifestyleForm() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Styl życia:'),
          CheckboxListTile(
            title: const Text('Palenie tytoniu'),
            value: _smoking ?? false,
            onChanged: (value) {
              setState(() {
                _smoking = value;
              });
            },
          ),
          const SizedBox(height: 16),
          const Text('Poziom stresu:'),
          Row(
            children: [
              Radio<String>(
                value: 'Niski',
                groupValue: _stressLevel,
                onChanged: (value) {
                  setState(() {
                    _stressLevel = value;
                  });
                },
              ),
              const Text('Niski'),
              Radio<String>(
                value: 'Średni',
                groupValue: _stressLevel,
                onChanged: (value) {
                  setState(() {
                    _stressLevel = value;
                  });
                },
              ),
              const Text('Średni'),
              Radio<String>(
                value: 'Wysoki',
                groupValue: _stressLevel,
                onChanged: (value) {
                  setState(() {
                    _stressLevel = value;
                  });
                },
              ),
              const Text('Wysoki'),
            ],
          ),
          const SizedBox(height: 16),
          CheckboxListTile(
            title: const Text('Korzystanie z solarium/częste opalanie'),
            value: _tanning ?? false,
            onChanged: (value) {
              setState(() {
                _tanning = value;
              });
            },
          ),
        ],
      ),
    );
  }
}