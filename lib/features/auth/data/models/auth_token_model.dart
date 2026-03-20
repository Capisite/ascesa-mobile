import 'package:flutter_project/features/auth/data/models/user_model.dart';
import 'package:flutter_project/features/auth/domain/entities/auth_token.dart';

class AuthTokenModel extends AuthToken {
  AuthTokenModel({
    required super.accessToken,
    required super.user,
  });

  factory AuthTokenModel.fromJson(Map<String, dynamic> json) {
    return AuthTokenModel(
      accessToken: json['accessToken'] as String,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'user': (user as UserModel).toJson(),
    };
  }
}
