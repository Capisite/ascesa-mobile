import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ascesa/features/auth/domain/entities/user.dart';
import 'package:ascesa/core/services/biometric_service.dart';

class AuthLocalDataSource {
  static const String _userKey = 'user_data';
  static const String _tokenKey = 'auth_token';
  final BiometricService _biometricService = BiometricService();

  Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      final map = jsonDecode(userJson);
      return User.fromJson(Map<String, dynamic>.from(map));
    }
    return null;
  }

  Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    await prefs.remove(_tokenKey);
    await _biometricService.clearCredentials();
  }

  Future<void> clearCredentials() async {
    await _biometricService.clearCredentials();
  }

  // Biometrics
  Future<bool> isBiometricsEnabled() => _biometricService.isBiometricsEnabled();
  Future<void> setBiometricsEnabled(bool enabled) => _biometricService.setBiometricsEnabled(enabled);
  Future<void> saveCredentials(String email, String password) => _biometricService.saveCredentials(email, password);
  Future<Map<String, String>?> getCredentials() => _biometricService.getCredentials();
}
