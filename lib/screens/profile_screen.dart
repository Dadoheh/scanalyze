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
      // Pobierz email zalogowanego użytkownika
      final prefs = await SharedPreferences.getInstance();
      _userEmail = prefs.getString('user_email') ?? '';

      // Pobierz profil z API
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
          _buildInfoSection('Dane podstawowe', [
            _buildInfoItem('Email', _userEmail),
            _buildInfoItem('Wiek', '${_profile!.age} lat'),
            _buildInfoItem('Płeć', _profile!.gender ?? 'Nie podano'),
            _buildInfoItem('Wzrost', '${_profile!.height} cm'),
            _buildInfoItem('Waga', '${_profile!.weight} kg'),
          ]),

          _buildInfoSection('Rodzaj skóry', [
            _buildInfoItem('Typ skóry', _profile!.skinType ?? 'Nie określono'),
            _buildInfoItem('Skóra wrażliwa', _profile!.sensitiveSkin == true ? 'Tak' : 'Nie'),
            _buildInfoItem('Skóra atopowa', _profile!.atopicSkin == true ? 'Tak' : 'Nie'),
            _buildInfoItem('Skłonność do trądziku', _profile!.acneProne == true ? 'Tak' : 'Nie'),
          ]),

          if (_profile!.cosmeticAllergies != null && _profile!.cosmeticAllergies!.isNotEmpty)
            _buildInfoSection('Alergie kosmetyczne', [
              _buildInfoItem('Występujące alergie', _profile!.cosmeticAllergies!.join(', ')),
            ]),

          if (_profile!.generalAllergies != null && _profile!.generalAllergies!.isNotEmpty)
            _buildInfoItem('Inne alergie', _profile!.generalAllergies!.join(', ')),

          _buildInfoSection('Schorzenia dermatologiczne', [
            _buildInfoItem('Trądzik pospolity', _profile!.acneVulgaris == true ? 'Tak' : 'Nie'),
            _buildInfoItem('Łuszczyca', _profile!.psoriasis == true ? 'Tak' : 'Nie'),
            _buildInfoItem('Egzema/AZS', _profile!.eczema == true ? 'Tak' : 'Nie'),
            _buildInfoItem('Trądzik różowaty', _profile!.rosacea == true ? 'Tak' : 'Nie'),
          ]),

          _buildInfoSection('Stosowane leki', [
            _buildInfoItem('Leki fotouczulające', _profile!.photosensitizingDrugs == true ? 'Tak' : 'Nie'),
            _buildInfoItem('Leki moczopędne', _profile!.diuretics == true ? 'Tak' : 'Nie'),
            if (_profile!.otherMedications != null && _profile!.otherMedications!.isNotEmpty)
              _buildInfoItem('Inne leki', _profile!.otherMedications!),
            if (_profile!.medicalProcedures != null && _profile!.medicalProcedures!.isNotEmpty)
              _buildInfoItem('Przebyte zabiegi', _profile!.medicalProcedures!),
          ]),

          _buildInfoSection('Styl życia', [
            _buildInfoItem('Palenie tytoniu', _profile!.smoking == true ? 'Tak' : 'Nie'),
            _buildInfoItem('Poziom stresu', _profile!.stressLevel ?? 'Nie określono'),
            _buildInfoItem('Częste opalanie', _profile!.tanning == true ? 'Tak' : 'Nie'),
            if (_profile!.gender == 'Kobieta')
              _buildInfoItem('Ciąża', _profile!.pregnancy == true ? 'Tak' : 'Nie'),
          ]),
        ],
      ),
    );
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