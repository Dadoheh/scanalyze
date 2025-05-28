import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../env/env.dart';
import '../models/user_profile.dart';
import 'dart:typed_data' as td;


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

  // Probably to remove
  static Future<Map<String, dynamic>> uploadProductImage(dynamic imageData) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      throw Exception('Brak autentykacji');
    }

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('${Env.apiBaseUrl}/product/analyze'),
    );

    request.headers.addAll({
      'Authorization': 'Bearer $token',
    });

    if (kIsWeb) {
      // Dla web - imageData to Uint8List
      request.files.add(http.MultipartFile.fromBytes(
        'image',
        imageData, // Web przekaże tutaj bajty
        filename: 'image.jpg',
        contentType: MediaType.parse('image/jpeg'),
      ));
    } else {
      // Dla mobile - imageData to File z dart:io
      final path = imageData.path;
      final extension = path.toLowerCase().split('.').last;
      final contentType = extension == 'png' ? 'image/png' : 'image/jpeg';

      request.files.add(await http.MultipartFile.fromPath(
        'image',
        path,
        contentType: MediaType.parse(contentType),
      ));
    }

    try {
      final response = await request.send();
      final responseData = await http.Response.fromStream(response);

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(responseData.bodyBytes));
      } else {
        throw Exception('Nie udało się przesłać zdjęcia: ${responseData.body}');
      }
    } catch (e) {
      throw Exception('Błąd podczas przesyłania: $e');
    }
  }

  static Future<Map<String, dynamic>> uploadImageWithMetadata(
      Uint8List imageBytes, {
        required String fileName,
        required String mimeType,
      }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      throw Exception('Brak autentykacji');
    }

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('${Env.apiBaseUrl}/product/analyze'),
    );

    request.headers.addAll({
      'Authorization': 'Bearer $token',
    });

    request.files.add(http.MultipartFile.fromBytes(
      'image',
      imageBytes,
      filename: fileName,
      contentType: MediaType.parse(mimeType),
    ));

    try {
      final response = await request.send();
      final responseData = await http.Response.fromStream(response);

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(responseData.bodyBytes));
      } else {
        throw Exception('Nie udało się przesłać zdjęcia: ${responseData.body}');
      }
    } catch (e) {
      throw Exception('Błąd podczas przesyłania: $e');
    }
  }

  static Future<Map<String, dynamic>> extractText(
    Uint8List imageBytes, {
    required String fileName,
    required String mimeType,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      throw Exception('Brak autentykacji');
    }

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('${Env.apiBaseUrl}/product/extract-text'),
    );

    request.headers.addAll({
      'Authorization': 'Bearer $token',
    });

    request.files.add(http.MultipartFile.fromBytes(
      'image',
      imageBytes,
      filename: fileName,
      contentType: MediaType.parse(mimeType),
    ));

    try {
      final response = await request.send();
      final responseData = await http.Response.fromStream(response);

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(responseData.bodyBytes));
      } else {
        throw Exception('Błąd podczas ekstrakcji tekstu: ${responseData.body}');
      }
    } catch (e) {
      throw Exception('Błąd połączenia: $e');
    }
  }

  static Future<Map<String, dynamic>> analyzeIngredients(Map<String, dynamic> ingredientsData) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      throw Exception('Brak autentykacji');
    }

    final response = await http.post(
      Uri.parse('${Env.apiBaseUrl}/product/analyze-ingredients'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(ingredientsData),
    );

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Błąd podczas analizy składników: ${response.body}');
    }
  }

}
