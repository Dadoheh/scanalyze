import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';
import '../services/api_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserProfile? _profile;
  bool _isLoading = true;
  String _userEmail = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      _userEmail = prefs.getString('user_email') ?? '';

      final profile = await ApiService.getUserProfile();
      setState(() {
        _profile = profile as UserProfile?;
        _isLoading = false;
      });
    } catch (e) {
      print('Błąd podczas pobierania profilu: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mój profil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              await Navigator.pushNamed(context, '/profile-form');
              _loadUserData(); // Odśwież dane po powrocie z formularza
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _profile == null
          ? _buildEmptyProfile()
          : _buildProfileDetails(),
    );
  }

  Widget _buildEmptyProfile() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Brak danych profilu',
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              await Navigator.pushNamed(context, '/profile-form');
              _loadUserData();
            },
            child: const Text('Uzupełnij dane profilu'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileDetails() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfileHeader(),
          const Divider(height: 32),
          
          // Dane podstawowe
          _buildInfoSection('Dane podstawowe', [
            _buildInfoItem('Email', _userEmail),
            _buildInfoItem('Wiek', '${_profile!.age} lat'),
            _buildInfoItem('Płeć', _profile!.gender ?? 'Nie podano'),
            _buildInfoItem('Wzrost', '${_profile!.height} cm'),
            _buildInfoItem('Waga', '${_profile!.weight} kg'),
          ]),

          // Rodzaj skóry
          _buildInfoSection('Rodzaj skóry', [
            _buildInfoItem('Typ skóry', _profile!.skinType ?? 'Nie określono'),
            _buildInfoItem('Skóra wrażliwa', _profile!.sensitiveSkin == true ? 'Tak' : 'Nie'),
            _buildInfoItem('Skóra atopowa', _profile!.atopicSkin == true ? 'Tak' : 'Nie'),
            _buildInfoItem('Skłonność do trądziku', _profile!.acneProne == true ? 'Tak' : 'Nie'),
            _buildInfoItem('Uszkodzona bariera skóry', _profile!.barrierDysfunction == true ? 'Tak' : 'Nie'),
            _buildInfoItem('Łojotokowe zapalenie skóry', _profile!.seborrheicDermatitis == true ? 'Tak' : 'Nie'),
          ]),

          // Alergie i nietolerancje
          if (_profile!.cosmeticAllergies != null && _profile!.cosmeticAllergies!.isNotEmpty ||
              _profile!.generalAllergies != null && _profile!.generalAllergies!.isNotEmpty ||
              _profile!.knownIntolerances != null && _profile!.knownIntolerances!.isNotEmpty ||
              _profile!.dermatologistRecommendedAvoid != null && _profile!.dermatologistRecommendedAvoid!.isNotEmpty)
            _buildInfoSection('Alergie i nietolerancje', [
              if (_profile!.cosmeticAllergies != null && _profile!.cosmeticAllergies!.isNotEmpty)
                _buildInfoItem('Alergie kosmetyczne', _profile!.cosmeticAllergies!.join(', ')),
              if (_profile!.knownIntolerances != null && _profile!.knownIntolerances!.isNotEmpty)
                _buildInfoItem('Znane nietolerancje', _profile!.knownIntolerances!.join(', ')),
              if (_profile!.generalAllergies != null && _profile!.generalAllergies!.isNotEmpty)
                _buildInfoItem('Inne alergie', _profile!.generalAllergies!.join(', ')),
              if (_profile!.dermatologistRecommendedAvoid != null && _profile!.dermatologistRecommendedAvoid!.isNotEmpty)
                _buildInfoItem('Zalecenia dermatologa (unikać)', _profile!.dermatologistRecommendedAvoid!.join(', ')),
            ]),

          // Schorzenia dermatologiczne
          _buildInfoSection('Schorzenia dermatologiczne', [
            _buildInfoItem('Trądzik pospolity', _profile!.acneVulgaris == true ? 'Tak' : 'Nie'),
            _buildInfoItem('Łuszczyca', _profile!.psoriasis == true ? 'Tak' : 'Nie'),
            _buildInfoItem('Egzema/AZS', _profile!.eczema == true ? 'Tak' : 'Nie'),
            _buildInfoItem('Trądzik różowaty', _profile!.rosacea == true ? 'Tak' : 'Nie'),
            _buildInfoItem('Zapalenie okolic oczu', _profile!.periorbitalDermatitis == true ? 'Tak' : 'Nie'),
            _buildInfoItem('Kontaktowe zapalenie skóry', _profile!.contactDermatitis == true ? 'Tak' : 'Nie'),
            _buildInfoItem('Zaburzenia rogowacenia', _profile!.keratinizationDisorders == true ? 'Tak' : 'Nie'),
          ]),

          // Stosowane leki
          _buildInfoSection('Stosowane leki', [
            _buildInfoItem('Terapia retinoidami', _profile!.retinoidTherapy == true ? 'Tak' : 'Nie'),
            if (_profile!.corticosteroidUse != null)
              _buildInfoItem('Kortykosteroidy', _getCorticosteroidLabel(_profile!.corticosteroidUse!)),
            if (_profile!.hormonalTherapy != null)
              _buildInfoItem('Terapia hormonalna', _getHormonalTherapyLabel(_profile!.hormonalTherapy!)),
            if (_profile!.photosensitizingMedications != null && _profile!.photosensitizingMedications!.isNotEmpty)
              _buildInfoItem('Leki fotouczulające', _profile!.photosensitizingMedications!.join(', ')),
            if (_profile!.diureticMedications != null && _profile!.diureticMedications!.isNotEmpty)
              _buildInfoItem('Leki moczopędne', _profile!.diureticMedications!.join(', ')),
            if (_profile!.immunosuppressants != null && _profile!.immunosuppressants!.isNotEmpty)
              _buildInfoItem('Leki immunosupresyjne', _profile!.immunosuppressants!.join(', ')),
            if (_profile!.otherMedications != null && _profile!.otherMedications!.isNotEmpty)
              _buildInfoItem('Inne leki', _profile!.otherMedications!),
            if (_profile!.medicalProcedures != null && _profile!.medicalProcedures!.isNotEmpty)
              _buildInfoItem('Przebyte zabiegi', _profile!.medicalProcedures!),
          ]),

          // Styl życia
          _buildInfoSection('Styl życia', [
            _buildInfoItem('Palenie tytoniu', _profile!.smoking ?? 'Nie określono'),
            _buildInfoItem('Poziom stresu', _profile!.stressLevel != null ? '${_profile!.stressLevel}/10' : 'Nie określono'),
            _buildInfoItem('Opalanie', _profile!.tanning ?? 'Nie określono'),
            if (_profile!.gender == 'Kobieta')
              _buildInfoItem('Ciąża', _profile!.pregnancy == true ? 'Tak' : 'Nie'),
          ]),

          // Ekspozycja na kosmetyki
          if (_profile!.productUsageFrequency != null ||
              _profile!.typicalApplicationAreas != null && _profile!.typicalApplicationAreas!.isNotEmpty ||
              _profile!.preferredProductTypes != null && _profile!.preferredProductTypes!.isNotEmpty)
            _buildInfoSection('Ekspozycja na kosmetyki', [
              if (_profile!.productUsageFrequency != null)
                _buildInfoItem('Częstotliwość używania', _getUsageFrequencyLabel(_profile!.productUsageFrequency!)),
              if (_profile!.typicalApplicationAreas != null && _profile!.typicalApplicationAreas!.isNotEmpty)
                _buildInfoItem('Miejsca aplikacji', _profile!.typicalApplicationAreas!.map((e) => _getApplicationAreaLabel(e)).join(', ')),
              if (_profile!.preferredProductTypes != null && _profile!.preferredProductTypes!.isNotEmpty)
                _buildInfoItem('Typy produktów', _profile!.preferredProductTypes!.map((e) => _getProductTypeLabel(e)).join(', ')),
              if (_profile!.bodyBackgroundExposure != null)
                _buildInfoItem('Powierzchnia ciała (BSA)', '${_profile!.bodyBackgroundExposure} m²'),
            ]),

          // Preferencje użytkownika
          if (_profile!.preferNatural == true || _profile!.veganOnly == true || _profile!.fragranceFree == true ||
              _profile!.avoidCategories != null && _profile!.avoidCategories!.isNotEmpty ||
              _profile!.certificationPreferences != null && _profile!.certificationPreferences!.isNotEmpty)
            _buildInfoSection('Preferencje', [
              if (_profile!.preferNatural == true)
                _buildInfoItem('Preferowane', 'Naturalne składniki'),
              if (_profile!.veganOnly == true)
                _buildInfoItem('Wymagane', 'Tylko produkty wegańskie'),
              if (_profile!.fragranceFree == true)
                _buildInfoItem('Wymagane', 'Bez substancji zapachowych'),
              if (_profile!.avoidCategories != null && _profile!.avoidCategories!.isNotEmpty)
                _buildInfoItem('Unikać kategorii', _profile!.avoidCategories!.map((e) => _getCategoryLabel(e)).join(', ')),
              if (_profile!.certificationPreferences != null && _profile!.certificationPreferences!.isNotEmpty)
                _buildInfoItem('Preferowane certyfikaty', _profile!.certificationPreferences!.map((e) => e.toUpperCase()).join(', ')),
            ]),

          // Środowisko i cele
          if (_profile!.climateType != null || _profile!.pollutionExposure != null ||
              _profile!.sunExposure != null || _profile!.waterHardness != null ||
              _profile!.primaryConcerns != null && _profile!.primaryConcerns!.isNotEmpty)
            _buildInfoSection('Środowisko i cele', [
              if (_profile!.climateType != null)
                _buildInfoItem('Typ klimatu', _getClimateLabel(_profile!.climateType!)),
              if (_profile!.pollutionExposure != null)
                _buildInfoItem('Zanieczyszczenia', _getPollutionLabel(_profile!.pollutionExposure!)),
              if (_profile!.sunExposure != null)
                _buildInfoItem('Ekspozycja na słońce', _getSunExposureLabel(_profile!.sunExposure!)),
              if (_profile!.waterHardness != null)
                _buildInfoItem('Twardość wody', _getWaterHardnessLabel(_profile!.waterHardness!)),
              if (_profile!.primaryConcerns != null && _profile!.primaryConcerns!.isNotEmpty)
                _buildInfoItem('Główne problemy', _profile!.primaryConcerns!.map((e) => _getConcernLabel(e)).join(', ')),
            ]),
        ],
      ),
    );
  }

  // Helper methods for label translations
  String _getCorticosteroidLabel(String value) {
    switch (value) {
      case 'topical': return 'Miejscowo (maści, kremy)';
      case 'systemic': return 'Ogólnoustrojowo (tabletki)';
      case 'both': return 'Oba rodzaje';
      default: return value;
    }
  }

  String _getHormonalTherapyLabel(String value) {
    switch (value) {
      case 'birth_control': return 'Antykoncepcja hormonalna';
      case 'hrt': return 'Hormonalna terapia zastępcza';
      case 'other': return 'Inna terapia hormonalna';
      default: return value;
    }
  }

  String _getUsageFrequencyLabel(String value) {
    switch (value) {
      case 'daily': return 'Codziennie';
      case 'weekly': return 'Kilka razy w tygodniu';
      case 'occasionally': return 'Okazjonalnie';
      default: return value;
    }
  }

  String _getApplicationAreaLabel(String value) {
    switch (value) {
      case 'face': return 'Twarz';
      case 'body': return 'Ciało';
      case 'hands': return 'Dłonie';
      case 'neck': return 'Szyja/dekolt';
      default: return value;
    }
  }

  String _getProductTypeLabel(String value) {
    switch (value) {
      case 'leave-on': return 'Pozostawiające';
      case 'rinse-off': return 'Zmywalne';
      default: return value;
    }
  }

  String _getCategoryLabel(String value) {
    switch (value) {
      case 'parabens': return 'Parabeny';
      case 'sulfates': return 'Siarczany';
      case 'silicones': return 'Silikony';
      case 'mineral_oil': return 'Olej mineralny';
      default: return value;
    }
  }

  String _getClimateLabel(String value) {
    switch (value) {
      case 'dry': return 'Suchy';
      case 'humid': return 'Wilgotny';
      case 'temperate': return 'Umiarkowany';
      case 'cold': return 'Zimny';
      default: return value;
    }
  }

  String _getPollutionLabel(String value) {
    switch (value) {
      case 'high': return 'Wysoka';
      case 'moderate': return 'Umiarkowana';
      case 'low': return 'Niska';
      default: return value;
    }
  }

  String _getSunExposureLabel(String value) {
    switch (value) {
      case 'high_outdoor': return 'Wysoka (praca na zewnątrz)';
      case 'moderate': return 'Umiarkowana';
      case 'minimal_indoor': return 'Minimalna (praca w pomieszczeniach)';
      default: return value;
    }
  }

  String _getWaterHardnessLabel(String value) {
    switch (value) {
      case 'hard': return 'Twarda';
      case 'soft': return 'Miękka';
      case 'moderate': return 'Średnia';
      default: return value;
    }
  }

  String _getConcernLabel(String value) {
    switch (value) {
      case 'anti_aging': return 'Anti-aging';
      case 'acne': return 'Trądzik';
      case 'hydration': return 'Nawilżenie';
      case 'brightening': return 'Rozjaśnianie';
      case 'sun_protection': return 'Ochrona UV';
      default: return value;
    }
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        const CircleAvatar(
          radius: 50,
          backgroundColor: Colors.blue,
          child: Icon(Icons.person, size: 50, color: Colors.white),
        ),
        const SizedBox(height: 16),
        Text(
          _userEmail,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 8),
        ...children,
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}