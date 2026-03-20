import 'package:flutter/material.dart';
import 'package:flutter_project/features/auth/domain/entities/user.dart';
import 'package:flutter_project/features/auth/domain/usecases/login_use_case.dart';

class AuthController extends ChangeNotifier {
  final LoginUseCase loginUseCase;

  bool _isLoading = false;
  String? _errorMessage;
  String? _accessToken;
  User? _user;

  AuthController({required this.loginUseCase});

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get accessToken => _accessToken;
  User? get user => _user;

  void logout() {
    _accessToken = null;
    _user = null;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final authToken = await loginUseCase.execute(email, password);
      _accessToken = authToken.accessToken;
      _user = authToken.user;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
