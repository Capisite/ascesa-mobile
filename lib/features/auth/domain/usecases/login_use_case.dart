import 'package:flutter_project/features/auth/domain/entities/auth_token.dart';
import 'package:flutter_project/features/auth/domain/repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase({required this.repository});

  Future<AuthToken> execute(String email, String password) {
    return repository.login(email, password);
  }
}
