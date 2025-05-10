import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';

import '../env/env.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  bool isLoading = false;

  Future<void> registerUser() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => isLoading = true);

    try {
      final url = Uri.parse(Env.registerUrl);
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        Fluttertoast.showToast(msg: 'Zarejestrowano pomyślnie!');
        Navigator.pop(context); // wróć do logowania
      } else {
        Fluttertoast.showToast(msg: 'Błąd rejestracji: ${response.body}');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Błąd połączenia z API');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rejestracja')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) => value!.isEmpty ? 'Wprowadź email' : null,
                onSaved: (value) => email = value!.trim(),
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Hasło'),
                obscureText: true,
                validator: (value) =>
                    value!.length < 6 ? 'Min. 6 znaków' : null,
                onSaved: (value) => password = value!.trim(),
              ),
              const SizedBox(height: 20),
              isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: registerUser,
                      child: const Text('Zarejestruj się'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
