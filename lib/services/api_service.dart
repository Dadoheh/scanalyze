import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../env/env.dart';
import '../models/user_profile.dart';

class ApiService {
  static Future<UserProfile> getUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    final response = await http.get(
      Uri.parse('${Env.apiBaseUrl}/user/profile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      }
    );

    if (response.statusCode == 200) {
      //return jsonDecode(utf8.decode(response.bodyBytes));
      final profileData = jsonDecode(utf8.decode(response.bodyBytes));
      return UserProfile.fromJson(profileData);
    } else {
      throw Exception('Nie udało się pobrać profilu');
    }
  }

  static Future<void> updateUserProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    final response = await http.post(
      Uri.parse('${Env.apiBaseUrl}/user/profile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(profile.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Nie udało się zaktualizować profilu');
    }
  }
}