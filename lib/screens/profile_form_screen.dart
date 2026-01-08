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
  late var _pageController = PageController();
  int _currentPageIndex = 0;
  bool _isLoading = false;

  // Physiological
  int? _age;
  String? _gender;
  double? _weight;
  double? _height;

  // Skin type
  String? _skinType;
  bool? _sensitiveSkin;
  bool? _atopicSkin;
  bool? _acneProne;

  // Allergies
  bool? _hasAllergies;
  List<String> _cosmeticAllergies = [];
  List<String> _generalAllergies = [];

  // Dermatological conditions (existing)
  bool? _acneVulgaris;
  bool? _psoriasis;
  bool? _eczema;
  bool? _rosacea;

  // Additional skin conditions
  bool? _barrierDysfunction;
  bool? _seborrheicDermatitis;
  bool? _periorbitalDermatitis;
  bool? _contactDermatitis;
  bool? _keratinizationDisorders;

  // Medications (detailed)
  List<String> _photosensitizingMedications = [];
  List<String> _diureticMedications = [];
  bool? _retinoidTherapy;
  String? _corticosteroidUse;
  List<String> _immunosuppressants = [];
  String? _hormonalTherapy;
  String? _otherMedications;
  String? _medicalProcedures;

  // Legacy (backward compatibility)
  bool? _photosensitizingDrugs;
  bool? _diuretics;

  // Lifestyle
  String? _smoking;
  int? _stressLevel;
  String? _tanning;
  bool? _pregnancy;

  // Cosmetic exposure patterns
  String? _productUsageFrequency;
  List<String> _typicalApplicationAreas = [];
  double? _bodyBackgroundExposure;
  List<String> _preferredProductTypes = [];

  // Ingredient safety history
  List<String> _knownIntolerances = [];
  List<Map<String, dynamic>> _previousAdverseReactions = [];
  List<String> _dermatologistRecommendedAvoid = [];

  // User preferences
  bool? _preferNatural;
  bool? _veganOnly;
  bool? _fragranceFree;
  List<String> _avoidCategories = [];
  List<String> _certificationPreferences = [];

  // Environmental factors
  String? _climateType;
  String? _pollutionExposure;
  String? _sunExposure;
  String? _waterHardness;

  // Cosmetic goals
  List<String> _primaryConcerns = [];

  late TextEditingController _ageController;
  late TextEditingController _weightController;
  late TextEditingController _heightController;

  final List<String> _pageTitles = [
    'Cechy fizjologiczne',
    'Typ skóry i wrażliwość',
    'Alergie i nadwrażliwości',
    'Schorzenia dermatologiczne',
    'Stosowane leki',
    'Inne leki i zabiegi',
    'Styl życia, nawyki, inne',
    'Ekspozycja na kosmetyki',
    'Preferencje użytkownika',
    'Środowisko i cele'
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    _age = 25;
    _weight = 70.0;
    _height = 170.0;
    _smoking = 'Nigdy';
    _tanning = 'Nigdy';
    _stressLevel = 5;
    _pregnancy = false;

    _ageController = TextEditingController(text: '${_age}');
    _weightController = TextEditingController(text: '${_weight}');
    _heightController = TextEditingController(text: '${_height}');
  }

  @override
  void dispose() {
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _pageController.dispose();
    super.dispose();
  }

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
                    _buildCosmeticExposureForm(),
                    _buildUserPreferencesForm(),
                    _buildEnvironmentAndGoalsForm(),
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
        cosmeticAllergies: _cosmeticAllergies.isEmpty ? null : _cosmeticAllergies,
        generalAllergies: _generalAllergies.isEmpty ? null : _generalAllergies,
        acneVulgaris: _acneVulgaris,
        psoriasis: _psoriasis,
        eczema: _eczema,
        rosacea: _rosacea,
        barrierDysfunction: _barrierDysfunction,
        seborrheicDermatitis: _seborrheicDermatitis,
        periorbitalDermatitis: _periorbitalDermatitis,
        contactDermatitis: _contactDermatitis,
        keratinizationDisorders: _keratinizationDisorders,
        photosensitizingMedications: _photosensitizingMedications.isEmpty ? null : _photosensitizingMedications,
        diureticMedications: _diureticMedications.isEmpty ? null : _diureticMedications,
        retinoidTherapy: _retinoidTherapy,
        corticosteroidUse: _corticosteroidUse,
        immunosuppressants: _immunosuppressants.isEmpty ? null : _immunosuppressants,
        hormonalTherapy: _hormonalTherapy,
        otherMedications: _otherMedications,
        medicalProcedures: _medicalProcedures,
        photosensitizingDrugs: _photosensitizingDrugs,
        diuretics: _diuretics,
        smoking: _smoking,
        stressLevel: _stressLevel,
        tanning: _tanning,
        pregnancy: _pregnancy,
        productUsageFrequency: _productUsageFrequency,
        typicalApplicationAreas: _typicalApplicationAreas.isEmpty ? null : _typicalApplicationAreas,
        bodyBackgroundExposure: _bodyBackgroundExposure,
        preferredProductTypes: _preferredProductTypes.isEmpty ? null : _preferredProductTypes,
        knownIntolerances: _knownIntolerances.isEmpty ? null : _knownIntolerances,
        previousAdverseReactions: _previousAdverseReactions.isEmpty ? null : _previousAdverseReactions,
        dermatologistRecommendedAvoid: _dermatologistRecommendedAvoid.isEmpty ? null : _dermatologistRecommendedAvoid,
        preferNatural: _preferNatural,
        veganOnly: _veganOnly,
        fragranceFree: _fragranceFree,
        avoidCategories: _avoidCategories.isEmpty ? null : _avoidCategories,
        certificationPreferences: _certificationPreferences.isEmpty ? null : _certificationPreferences,
        climateType: _climateType,
        pollutionExposure: _pollutionExposure,
        sunExposure: _sunExposure,
        waterHardness: _waterHardness,
        primaryConcerns: _primaryConcerns.isEmpty ? null : _primaryConcerns,
      );

      await ApiService.updateUserProfile(profile);

      print('===== ZAPISANE DANE FORMULARZA =====');
      print(profile.toJson());
      print('===================================');

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

          const Text('Wiek *'),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Slider(
                  value: _age?.toDouble() ?? 25.0,
                  min: 1.0,
                  max: 120.0,
                  divisions: 119,
                  label: '${_age ?? 25} lat',
                  onChanged: (value) {
                    setState(() {
                      _age = value.round();
                      _ageController.text = '${_age}';
                    });
                  },
                ),
              ),
              Expanded(
                flex: 1,
                child: TextField(
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    suffix: Text('lat'),
                    contentPadding: EdgeInsets.symmetric(horizontal: 8),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    final parsedValue = int.tryParse(value);
                    if (parsedValue != null && parsedValue >= 1 && parsedValue <= 120) {
                      setState(() {
                        _age = parsedValue;
                      });
                    }
                  },
                ),
              ),
            ],
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
                    if (value == 'Kobieta') {
                      _pregnancy = false;
                    }
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
                    if (value == 'Mężczyzna') {
                      _pregnancy = false;
                    }
                  });
                },
              ),
              const Text('Mężczyzna'),
            ],
          ),

          const SizedBox(height: 16),
          const Text('Masa ciała *'),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Slider(
                  value: _weight ?? 70.0,
                  min: 30.0,
                  max: 200.0,
                  divisions: 170,
                  label: '${_weight?.toStringAsFixed(1) ?? "70.0"} kg',
                  onChanged: (value) {
                    setState(() {
                      _weight = double.parse(value.toStringAsFixed(1));
                      _weightController.text = '${_weight?.toStringAsFixed(1)}';
                    });
                  },
                ),
              ),
              Expanded(
                flex: 1,
                child: TextField(
                  controller: _weightController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    suffix: Text('kg'),
                    contentPadding: EdgeInsets.symmetric(horizontal: 8),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    final parsedValue = double.tryParse(value);
                    if (parsedValue != null && parsedValue >= 30 && parsedValue <= 200) {
                      setState(() {
                        _weight = parsedValue;
                      });
                    }
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Text('Wzrost *'),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Slider(
                  value: _height ?? 170.0,
                  min: 100.0,
                  max: 220.0,
                  divisions: 120,
                  label: '${_height?.round() ?? 170} cm',
                  onChanged: (value) {
                    setState(() {
                      _height = value.round().toDouble();
                      _heightController.text = '${_height?.round()}';
                    });
                  },
                ),
              ),
              Expanded(
                flex: 1,
                child: TextField(
                  controller: _heightController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    suffix: Text('cm'),
                    contentPadding: EdgeInsets.symmetric(horizontal: 8),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    final parsedValue = int.tryParse(value);
                    if (parsedValue != null && parsedValue >= 100 && parsedValue <= 220) {
                      setState(() {
                        _height = parsedValue.toDouble();
                      });
                    }
                  },
                ),
              ),
            ],
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
          const Text('Właściwości skóry:', style: TextStyle(fontWeight: FontWeight.bold)),
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
          CheckboxListTile(
            title: const Text('Uszkodzona bariera skóry'),
            value: _barrierDysfunction ?? false,
            onChanged: (value) {
              setState(() {
                _barrierDysfunction = value;
              });
            },
          ),
          CheckboxListTile(
            title: const Text('Łojotokowe zapalenie skóry'),
            value: _seborrheicDermatitis ?? false,
            onChanged: (value) {
              setState(() {
                _seborrheicDermatitis = value;
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
          const Padding(
            padding: EdgeInsets.only(left: 16.0, bottom: 8.0, top: 8.0),
            child: Text(
              'Alergie na składniki kosmetyków',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),

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
          
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.only(left: 16.0, bottom: 8.0),
            child: Text(
              'Znane nietolerancje składników',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextFormField(
              decoration: const InputDecoration(
                labelText: 'Składniki powodujące reakcje',
                hintText: 'Np. SLS, methylisothiazolinone, propylene glycol',
                helperText: 'Oddziel przecinkiem',
              ),
              maxLines: 2,
              onChanged: (value) {
                if (value.isNotEmpty) {
                  setState(() {
                    _knownIntolerances = value.split(',')
                        .map((e) => e.trim())
                        .where((e) => e.isNotEmpty)
                        .toList();
                  });
                }
              },
            ),
          ),
          
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextFormField(
              decoration: const InputDecoration(
                labelText: 'Inne alergie ogólne',
                hintText: 'Np. nikiel, lateks, aloes',
                helperText: 'Oddziel przecinkiem',
              ),
              onChanged: (value) {
                if (value.isNotEmpty) {
                  setState(() {
                    _generalAllergies = value.split(',')
                        .map((e) => e.trim())
                        .where((e) => e.isNotEmpty)
                        .toList();
                  });
                }
              },
            ),
          ),
          
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextFormField(
              decoration: const InputDecoration(
                labelText: 'Składniki zalecane do unikania przez dermatologa',
                hintText: 'Np. retinoidy, kwasy AHA',
                helperText: 'Oddziel przecinkiem',
              ),
              maxLines: 2,
              onChanged: (value) {
                if (value.isNotEmpty) {
                  setState(() {
                    _dermatologistRecommendedAvoid = value.split(',')
                        .map((e) => e.trim())
                        .where((e) => e.isNotEmpty)
                        .toList();
                  });
                }
              },
            ),
          ),
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
          const Text('Występujące schorzenia:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
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
          CheckboxListTile(
            title: const Text('Zapalenie okolic oczu'),
            value: _periorbitalDermatitis ?? false,
            onChanged: (value) {
              setState(() {
                _periorbitalDermatitis = value;
              });
            },
          ),
          CheckboxListTile(
            title: const Text('Kontaktowe zapalenie skóry'),
            value: _contactDermatitis ?? false,
            onChanged: (value) {
              setState(() {
                _contactDermatitis = value;
              });
            },
          ),
          CheckboxListTile(
            title: const Text('Zaburzenia rogowacenia'),
            value: _keratinizationDisorders ?? false,
            onChanged: (value) {
              setState(() {
                _keratinizationDisorders = value;
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
          const Text('Stosowane leki:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          
          CheckboxListTile(
            title: const Text('Terapia retinoidami'),
            subtitle: const Text('Np. izotretynoina, tretynoina'),
            value: _retinoidTherapy ?? false,
            onChanged: (value) {
              setState(() {
                _retinoidTherapy = value;
              });
            },
          ),
          
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text('Kortykosteroidy:', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: DropdownButtonFormField<String>(
              value: _corticosteroidUse,
              items: const [
                DropdownMenuItem(value: null, child: Text('Nie stosuję')),
                DropdownMenuItem(value: 'topical', child: Text('Miejscowo (maści, kremy)')),
                DropdownMenuItem(value: 'systemic', child: Text('Ogólnoustrojowo (tabletki)')),
                DropdownMenuItem(value: 'both', child: Text('Oba rodzaje')),
              ],
              onChanged: (value) {
                setState(() {
                  _corticosteroidUse = value;
                });
              },
              decoration: const InputDecoration(
                hintText: 'Wybierz rodzaj terapii',
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text('Terapia hormonalna:', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: DropdownButtonFormField<String>(
              value: _hormonalTherapy,
              items: const [
                DropdownMenuItem(value: null, child: Text('Nie stosuję')),
                DropdownMenuItem(value: 'birth_control', child: Text('Antykoncepcja hormonalna')),
                DropdownMenuItem(value: 'hrt', child: Text('Hormonalna terapia zastępcza')),
                DropdownMenuItem(value: 'other', child: Text('Inna terapia hormonalna')),
              ],
              onChanged: (value) {
                setState(() {
                  _hormonalTherapy = value;
                });
              },
              decoration: const InputDecoration(
                hintText: 'Wybierz rodzaj terapii',
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextFormField(
              decoration: const InputDecoration(
                labelText: 'Leki fotouczulające',
                hintText: 'Np. tetracykliny, fluorochinolony',
                helperText: 'Oddziel przecinkiem',
              ),
              maxLines: 2,
              onChanged: (value) {
                if (value.isNotEmpty) {
                  setState(() {
                    _photosensitizingMedications = value.split(',')
                        .map((e) => e.trim())
                        .where((e) => e.isNotEmpty)
                        .toList();
                  });
                } else {
                  setState(() {
                    _photosensitizingMedications = [];
                  });
                }
              },
            ),
          ),
          
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextFormField(
              decoration: const InputDecoration(
                labelText: 'Leki moczopędne',
                hintText: 'Np. hydrochlorotiazyd, furosemid',
                helperText: 'Oddziel przecinkiem',
              ),
              maxLines: 2,
              onChanged: (value) {
                if (value.isNotEmpty) {
                  setState(() {
                    _diureticMedications = value.split(',')
                        .map((e) => e.trim())
                        .where((e) => e.isNotEmpty)
                        .toList();
                  });
                } else {
                  setState(() {
                    _diureticMedications = [];
                  });
                }
              },
            ),
          ),
          
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextFormField(
              decoration: const InputDecoration(
                labelText: 'Leki immunosupresyjne',
                hintText: 'Np. metotreksat, cyklosporyna',
                helperText: 'Oddziel przecinkiem',
              ),
              maxLines: 2,
              onChanged: (value) {
                if (value.isNotEmpty) {
                  setState(() {
                    _immunosuppressants = value.split(',')
                        .map((e) => e.trim())
                        .where((e) => e.isNotEmpty)
                        .toList();
                  });
                } else {
                  setState(() {
                    _immunosuppressants = [];
                  });
                }
              },
            ),
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
          const Text('Palenie tytoniu:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Column(
            children: [
              _buildRadioOption('Nigdy', 'Nigdy', _smoking, (value) => setState(() => _smoking = value)),
              _buildRadioOption('Bardzo rzadko', 'Bardzo rzadko', _smoking, (value) => setState(() => _smoking = value)),
              _buildRadioOption('Rzadko', 'Rzadko', _smoking, (value) => setState(() => _smoking = value)),
              _buildRadioOption('Okazjonalnie', 'Okazjonalnie', _smoking, (value) => setState(() => _smoking = value)),
              _buildRadioOption('Często', 'Często', _smoking, (value) => setState(() => _smoking = value)),
              _buildRadioOption('Codziennie', 'Codziennie', _smoking, (value) => setState(() => _smoking = value)),
            ],
          ),

          const SizedBox(height: 20),
          Text('Poziom stresu: ${_stressLevel ?? 5}/10', style: const TextStyle(fontWeight: FontWeight.bold)),
          Slider(
            value: _stressLevel?.toDouble() ?? 5.0,
            min: 0,
            max: 10,
            divisions: 10,
            label: '${_stressLevel ?? 5}',
            onChanged: (value) {
              setState(() {
                _stressLevel = value.round();
              });
            },
          ),

          const SizedBox(height: 20),
          const Text('Intensywność opalania:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Column(
            children: [
              _buildRadioOption('Nigdy', 'Nigdy', _tanning, (value) => setState(() => _tanning = value)),
              _buildRadioOption('Bardzo rzadko', 'Bardzo rzadko', _tanning, (value) => setState(() => _tanning = value)),
              _buildRadioOption('Rzadko', 'Rzadko', _tanning, (value) => setState(() => _tanning = value)),
              _buildRadioOption('Regularnie', 'Regularnie', _tanning, (value) => setState(() => _tanning = value)),
              _buildRadioOption('Często', 'Często', _tanning, (value) => setState(() => _tanning = value)),
              _buildRadioOption('Bardzo często / solarium', 'Bardzo często / solarium', _tanning, (value) => setState(() => _tanning = value)),
            ],
          ),

          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 8),
          CheckboxListTile(
            title: const Text('Ciąża'),
            subtitle: const Text('Zaznacz, jeśli jesteś w ciąży lub planujesz ciążę'),
            value: _pregnancy ?? false,
            onChanged: _gender == 'Mężczyzna' ? null : (value) {
              setState(() {
                _pregnancy = value;
              });
            },
            enabled: _gender != 'Mężczyzna',
          ),
        ],
      ),
    );
  }

  Widget _buildRadioOption(String title, String value, String? groupValue, Function(String?) onChanged) {
    return ListTile(
      title: Text(title),
      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
      leading: Radio<String>(
        value: value,
        groupValue: groupValue,
        onChanged: onChanged,
      ),
      dense: true,
    );
  }

  // Page 8: Cosmetic Exposure
  Widget _buildCosmeticExposureForm() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Częstotliwość używania kosmetyków:', style: TextStyle(fontWeight: FontWeight.bold)),
          DropdownButtonFormField<String>(
            value: _productUsageFrequency,
            items: const [
              DropdownMenuItem(value: 'daily', child: Text('Codziennie')),
              DropdownMenuItem(value: 'weekly', child: Text('Kilka razy w tygodniu')),
              DropdownMenuItem(value: 'occasionally', child: Text('Okazjonalnie')),
            ],
            onChanged: (value) {
              setState(() {
                _productUsageFrequency = value;
              });
            },
            decoration: const InputDecoration(
              hintText: 'Wybierz częstotliwość',
            ),
          ),
          
          const SizedBox(height: 16),
          const Text('Typowe miejsca aplikacji kosmetyków:', style: TextStyle(fontWeight: FontWeight.bold)),
          CheckboxListTile(
            title: const Text('Twarz'),
            value: _typicalApplicationAreas.contains('face'),
            onChanged: (value) {
              setState(() {
                if (value == true) {
                  _typicalApplicationAreas.add('face');
                } else {
                  _typicalApplicationAreas.remove('face');
                }
              });
            },
          ),
          CheckboxListTile(
            title: const Text('Ciało'),
            value: _typicalApplicationAreas.contains('body'),
            onChanged: (value) {
              setState(() {
                if (value == true) {
                  _typicalApplicationAreas.add('body');
                } else {
                  _typicalApplicationAreas.remove('body');
                }
              });
            },
          ),
          CheckboxListTile(
            title: const Text('Dłonie'),
            value: _typicalApplicationAreas.contains('hands'),
            onChanged: (value) {
              setState(() {
                if (value == true) {
                  _typicalApplicationAreas.add('hands');
                } else {
                  _typicalApplicationAreas.remove('hands');
                }
              });
            },
          ),
          CheckboxListTile(
            title: const Text('Szyja/dekolt'),
            value: _typicalApplicationAreas.contains('neck'),
            onChanged: (value) {
              setState(() {
                if (value == true) {
                  _typicalApplicationAreas.add('neck');
                } else {
                  _typicalApplicationAreas.remove('neck');
                }
              });
            },
          ),
          
          const SizedBox(height: 16),
          const Text('Preferowane typy produktów:', style: TextStyle(fontWeight: FontWeight.bold)),
          CheckboxListTile(
            title: const Text('Produkty pozostawiające (kremy, serum)'),
            value: _preferredProductTypes.contains('leave-on'),
            onChanged: (value) {
              setState(() {
                if (value == true) {
                  _preferredProductTypes.add('leave-on');
                } else {
                  _preferredProductTypes.remove('leave-on');
                }
              });
            },
          ),
          CheckboxListTile(
            title: const Text('Produkty zmywalne (żele, szampony)'),
            value: _preferredProductTypes.contains('rinse-off'),
            onChanged: (value) {
              setState(() {
                if (value == true) {
                  _preferredProductTypes.add('rinse-off');
                } else {
                  _preferredProductTypes.remove('rinse-off');
                }
              });
            },
          ),
        ],
      ),
    );
  }

  // Page 9: User Preferences
  Widget _buildUserPreferencesForm() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Preferencje składników:', style: TextStyle(fontWeight: FontWeight.bold)),
          CheckboxListTile(
            title: const Text('Preferuję naturalne składniki'),
            value: _preferNatural ?? false,
            onChanged: (value) {
              setState(() {
                _preferNatural = value;
              });
            },
          ),
          CheckboxListTile(
            title: const Text('Tylko produkty wegańskie'),
            value: _veganOnly ?? false,
            onChanged: (value) {
              setState(() {
                _veganOnly = value;
              });
            },
          ),
          CheckboxListTile(
            title: const Text('Bez substancji zapachowych'),
            value: _fragranceFree ?? false,
            onChanged: (value) {
              setState(() {
                _fragranceFree = value;
              });
            },
          ),
          
          const SizedBox(height: 16),
          const Text('Kategorie do unikania:', style: TextStyle(fontWeight: FontWeight.bold)),
          CheckboxListTile(
            title: const Text('Parabeny'),
            value: _avoidCategories.contains('parabens'),
            onChanged: (value) {
              setState(() {
                if (value == true) {
                  _avoidCategories.add('parabens');
                } else {
                  _avoidCategories.remove('parabens');
                }
              });
            },
          ),
          CheckboxListTile(
            title: const Text('Siarczany (SLS/SLES)'),
            value: _avoidCategories.contains('sulfates'),
            onChanged: (value) {
              setState(() {
                if (value == true) {
                  _avoidCategories.add('sulfates');
                } else {
                  _avoidCategories.remove('sulfates');
                }
              });
            },
          ),
          CheckboxListTile(
            title: const Text('Silikony'),
            value: _avoidCategories.contains('silicones'),
            onChanged: (value) {
              setState(() {
                if (value == true) {
                  _avoidCategories.add('silicones');
                } else {
                  _avoidCategories.remove('silicones');
                }
              });
            },
          ),
          CheckboxListTile(
            title: const Text('Olej mineralny'),
            value: _avoidCategories.contains('mineral_oil'),
            onChanged: (value) {
              setState(() {
                if (value == true) {
                  _avoidCategories.add('mineral_oil');
                } else {
                  _avoidCategories.remove('mineral_oil');
                }
              });
            },
          ),
          
          const SizedBox(height: 16),
          const Text('Preferowane certyfikaty:', style: TextStyle(fontWeight: FontWeight.bold)),
          CheckboxListTile(
            title: const Text('Ecocert'),
            value: _certificationPreferences.contains('ecocert'),
            onChanged: (value) {
              setState(() {
                if (value == true) {
                  _certificationPreferences.add('ecocert');
                } else {
                  _certificationPreferences.remove('ecocert');
                }
              });
            },
          ),
          CheckboxListTile(
            title: const Text('Cosmos'),
            value: _certificationPreferences.contains('cosmos'),
            onChanged: (value) {
              setState(() {
                if (value == true) {
                  _certificationPreferences.add('cosmos');
                } else {
                  _certificationPreferences.remove('cosmos');
                }
              });
            },
          ),
          CheckboxListTile(
            title: const Text('Natrue'),
            value: _certificationPreferences.contains('natrue'),
            onChanged: (value) {
              setState(() {
                if (value == true) {
                  _certificationPreferences.add('natrue');
                } else {
                  _certificationPreferences.remove('natrue');
                }
              });
            },
          ),
        ],
      ),
    );
  }

  // Page 10: Environment and Goals
  Widget _buildEnvironmentAndGoalsForm() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Typ klimatu:', style: TextStyle(fontWeight: FontWeight.bold)),
          DropdownButtonFormField<String>(
            value: _climateType,
            items: const [
              DropdownMenuItem(value: 'dry', child: Text('Suchy')),
              DropdownMenuItem(value: 'humid', child: Text('Wilgotny')),
              DropdownMenuItem(value: 'temperate', child: Text('Umiarkowany')),
              DropdownMenuItem(value: 'cold', child: Text('Zimny')),
            ],
            onChanged: (value) {
              setState(() {
                _climateType = value;
              });
            },
            decoration: const InputDecoration(
              hintText: 'Wybierz typ klimatu',
            ),
          ),
          
          const SizedBox(height: 16),
          const Text('Ekspozycja na zanieczyszczenia:', style: TextStyle(fontWeight: FontWeight.bold)),
          DropdownButtonFormField<String>(
            value: _pollutionExposure,
            items: const [
              DropdownMenuItem(value: 'high', child: Text('Wysoka (duże miasto)')),
              DropdownMenuItem(value: 'moderate', child: Text('Umiarkowana')),
              DropdownMenuItem(value: 'low', child: Text('Niska (tereny wiejskie)')),
            ],
            onChanged: (value) {
              setState(() {
                _pollutionExposure = value;
              });
            },
            decoration: const InputDecoration(
              hintText: 'Wybierz poziom',
            ),
          ),
          
          const SizedBox(height: 16),
          const Text('Ekspozycja na słońce:', style: TextStyle(fontWeight: FontWeight.bold)),
          DropdownButtonFormField<String>(
            value: _sunExposure,
            items: const [
              DropdownMenuItem(value: 'high_outdoor', child: Text('Wysoka (praca na zewnątrz)')),
              DropdownMenuItem(value: 'moderate', child: Text('Umiarkowana')),
              DropdownMenuItem(value: 'minimal_indoor', child: Text('Minimalna (praca w pomieszczeniach)')),
            ],
            onChanged: (value) {
              setState(() {
                _sunExposure = value;
              });
            },
            decoration: const InputDecoration(
              hintText: 'Wybierz poziom',
            ),
          ),
          
          const SizedBox(height: 16),
          const Text('Twardość wody:', style: TextStyle(fontWeight: FontWeight.bold)),
          DropdownButtonFormField<String>(
            value: _waterHardness,
            items: const [
              DropdownMenuItem(value: 'hard', child: Text('Twarda')),
              DropdownMenuItem(value: 'soft', child: Text('Miękka')),
              DropdownMenuItem(value: 'moderate', child: Text('Średnia')),
            ],
            onChanged: (value) {
              setState(() {
                _waterHardness = value;
              });
            },
            decoration: const InputDecoration(
              hintText: 'Wybierz twardość wody',
            ),
          ),
          
          const SizedBox(height: 16),
          const Text('Główne problemy kosmetyczne:', style: TextStyle(fontWeight: FontWeight.bold)),
          CheckboxListTile(
            title: const Text('Anti-aging'),
            value: _primaryConcerns.contains('anti_aging'),
            onChanged: (value) {
              setState(() {
                if (value == true) {
                  _primaryConcerns.add('anti_aging');
                } else {
                  _primaryConcerns.remove('anti_aging');
                }
              });
            },
          ),
          CheckboxListTile(
            title: const Text('Trądzik'),
            value: _primaryConcerns.contains('acne'),
            onChanged: (value) {
              setState(() {
                if (value == true) {
                  _primaryConcerns.add('acne');
                } else {
                  _primaryConcerns.remove('acne');
                }
              });
            },
          ),
          CheckboxListTile(
            title: const Text('Nawilżenie'),
            value: _primaryConcerns.contains('hydration'),
            onChanged: (value) {
              setState(() {
                if (value == true) {
                  _primaryConcerns.add('hydration');
                } else {
                  _primaryConcerns.remove('hydration');
                }
              });
            },
          ),
          CheckboxListTile(
            title: const Text('Rozjaśnianie/wyrównanie kolorytu'),
            value: _primaryConcerns.contains('brightening'),
            onChanged: (value) {
              setState(() {
                if (value == true) {
                  _primaryConcerns.add('brightening');
                } else {
                  _primaryConcerns.remove('brightening');
                }
              });
            },
          ),
          CheckboxListTile(
            title: const Text('Ochrona przeciwsłoneczna'),
            value: _primaryConcerns.contains('sun_protection'),
            onChanged: (value) {
              setState(() {
                if (value == true) {
                  _primaryConcerns.add('sun_protection');
                } else {
                  _primaryConcerns.remove('sun_protection');
                }
              });
            },
          ),
        ],
      ),
    );
  }
}