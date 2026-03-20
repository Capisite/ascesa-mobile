import 'package:flutter_project/features/auth/domain/entities/user.dart';

class AuthToken {
  final String accessToken;
  final User user;

  AuthToken({
    required this.accessToken,
    required this.user,
  });
}
