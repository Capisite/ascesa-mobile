import 'package:flutter/material.dart';
import 'package:flutter_project/features/auth/domain/entities/user.dart';
import 'package:flutter_project/features/member_area/domain/usecases/update_user_use_case.dart';
import 'package:flutter_project/features/auth/data/datasources/auth_local_data_source.dart';

class UserProfileController extends ChangeNotifier {
  final UpdateUserUseCase updateUserUseCase;
  final AuthLocalDataSource authLocalDataSource;
  User _user;

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  UserProfileController({
    required this.updateUserUseCase,
    required this.authLocalDataSource,
    required User user,
  }) : _user = user;

  User get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  Future<void> updateProfile({
    required String name,
    required String email,
    required String phone,
    String? fatherName,
    String? motherName,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final updatedUser = _user.copyWith(
        name: name,
        email: email,
        phone: phone,
        fatherName: fatherName,
        motherName: motherName,
      );

      _user = await updateUserUseCase.execute(updatedUser);
      await authLocalDataSource.saveUser(_user);
      _successMessage = 'Perfil atualizado com sucesso!';
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
}
