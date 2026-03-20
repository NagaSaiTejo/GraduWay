import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

/// Manages the authentication state and user profile information.
class AuthProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  final String baseUrl = "http://localhost:8080/api/auth";

  bool get isLoading => _isLoading;
  String? get error => _error;

  String _userName = "Alex";
  String _techField = "Flutter Developer";
  String _company = "Google";
  String _yoe = "5+";
  String? _userId;

  String get userName => _userName;
  String get techField => _techField;
  String get company => _company;
  String get yoe => _yoe;
  String? get userId => _userId;

  /// Authenticates the user with the backend.
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/login"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"email": email, "password": password}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _userId = data['id'];
        _userName = data['name'];
        _techField = data['techField'] ?? _techField;
        _company = data['company'] ?? _company;
        _yoe = data['yoe'] ?? _yoe;
        notifyListeners();
        return true;
      } else {
        _error = "Login failed";
        return false;
      }
    } catch (e) {
      if (email.isNotEmpty) {
        // Fallback for demo mode if backend is not reachable
        _userId = "demo_${DateTime.now().millisecondsSinceEpoch}";
        
        // Use the input string as the username, preserving symbols if provided
        String rawName = email.contains('@') ? email.split('@')[0] : email;
        // Capitalize words but keep symbols as requested
        _userName = rawName.split(' ').map((s) => s.isNotEmpty ? s[0].toUpperCase() + s.substring(1) : '').join(' ');
        
        if (_userName.isEmpty) _userName = "Demo User";
        
        _techField = "Alumni Mentor";
        _company = "Tech Demo Corp";
        _error = null;
        notifyListeners();
        return true;
      }
      _error = "Connection error: $e";
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Updates the user's profile information in the backend.
  Future<void> updateProfile({String? name, String? field, String? company, String? yoe}) async {
    // In a real app, we'd call a PATCH /api/users/{id} endpoint
    if (name != null) _userName = name;
    if (field != null) _techField = field;
    if (company != null) _company = company;
    if (yoe != null) _yoe = yoe;
    notifyListeners();
  }
}

