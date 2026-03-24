import 'package:dio/dio.dart';
import 'package:flutter_project/core/constants/api_constants.dart';

class UserRemoteDataSource {
  final Dio _dio;
  final String token;

  UserRemoteDataSource({Dio? dio, required this.token}) : _dio = dio ?? Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    ),
  );

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> userData) async {
    try {
      final response = await _dio.patch(
        ApiConstants.updateUserEndpoint,
        data: userData,
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Erro ao atualizar perfil');
    } catch (e) {
      throw Exception('Erro inesperado: $e');
    }
  }
}
