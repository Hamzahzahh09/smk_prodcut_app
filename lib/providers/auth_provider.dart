import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smk_product_app/config/env.dart';
import 'package:http/http.dart' as http;
import 'package:smk_product_app/models/user.dart';

class AuthProvider extends ChangeNotifier {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

   String? _token;
  String? get token => _token;

  AuthProvider() {
    _loadAuthStatus();
  }

  Future<void> _loadAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    // load token juga biar setelah restart masih kebaca
    _token = await _storage.read(key: 'token');

    notifyListeners();
  }

   Future<bool> login(String email, String password) async {
    final body = {'email': email, 'password': password};

    try {
      final response = await http.post(
        Uri.parse('${Env.baseUrl}/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final ResponseLogin responseData = responseLoginFromJson(response.body);

        _token = responseData.token;
        await _storage.write(key: 'token', value: _token);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);

        _isLoggedIn = true;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("error: $e");
      return false;
    }
  }

  Future<bool> register(String name, String email, String password, String confirm_password) async {
    try {
      final body = {
          'name': name,
          'email': email,
          'password': password,
          'confirm_password': confirm_password,
        };
      final response = await http.post(
        Uri.parse('${Env.baseUrl}/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      if (response.statusCode == 201) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print("error: $e");
      return false;
    }
  }

  Future<void> logout() async {
    _isLoggedIn = false;
    _token = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');

    await _storage.delete(key: 'token');

    notifyListeners();
  }
}
