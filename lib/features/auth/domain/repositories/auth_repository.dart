import 'package:flutter_project/features/auth/domain/entities/auth_token.dart';

abstract class AuthRepository {
  Future<AuthToken> login(String email, String password);
}
