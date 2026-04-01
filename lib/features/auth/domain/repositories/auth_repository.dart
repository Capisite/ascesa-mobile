import 'package:ascesa/features/auth/domain/entities/auth_token.dart';

abstract class AuthRepository {
  Future<AuthToken> login(String email, String password);
}
