import 'package:flutter/material.dart';
import 'package:ascesa/features/auth/domain/entities/user.dart';
import 'package:ascesa/features/member_area/domain/usecases/update_user_use_case.dart';
import 'package:ascesa/features/member_area/domain/usecases/get_user_profile_use_case.dart';
import 'package:ascesa/features/auth/data/datasources/auth_local_data_source.dart';

class UserProfileController extends ChangeNotifier {
  final UpdateUserUseCase updateUserUseCase;
  final GetUserProfileUseCase getUserProfileUseCase;
  final AuthLocalDataSource authLocalDataSource;
  User _user;

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  UserProfileController({
    required this.updateUserUseCase,
    required this.getUserProfileUseCase,
    required this.authLocalDataSource,
    required User user,
  }) : _user = user;

  User get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  /// Busca os dados mais recentes do usuário no backend via GET /users/me
  Future<void> fetchProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await getUserProfileUseCase.execute();
      await authLocalDataSource.saveUser(_user);
    } catch (e) {
      // Silencia o erro de fetch — exibe os dados em cache
      debugPrint('[UserProfileController] fetchProfile erro: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile({
    required String name,
    required String email,
    String? phone,
    String? mobilePhone,
    String? businessPhone,
    String? fatherName,
    String? motherName,
    String? zipCode,
    String? street,
    String? addressNumber,
    String? addressComplement,
    String? district,
    String? city,
    String? state,
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
        mobilePhone: mobilePhone,
        businessPhone: businessPhone,
        fatherName: fatherName,
        motherName: motherName,
        zipCode: zipCode,
        street: street,
        addressNumber: addressNumber,
        addressComplement: addressComplement,
        district: district,
        city: city,
        state: state,
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

  Future<void> updateProfilePhoto(String filePath) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      _user = await updateUserUseCase.updatePhoto(_user, filePath);
      await authLocalDataSource.saveUser(_user);
      _successMessage = 'Foto de perfil atualizada!';
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
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
