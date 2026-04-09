import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:ascesa/main.dart' show navigatorKey;
import 'package:ascesa/features/auth/presentation/pages/login_page.dart';

class AuthInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      final context = navigatorKey.currentState?.context;
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sessão expirada. Por favor, faça login novamente.'),
            backgroundColor: Colors.red,
          ),
        );
      }

      navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    }
    super.onError(err, handler);
  }
}
