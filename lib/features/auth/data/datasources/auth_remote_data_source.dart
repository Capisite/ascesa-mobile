import 'package:dio/dio.dart';
import 'package:flutter_project/core/constants/api_constants.dart';

class AuthRemoteDataSource {
  final Dio _dio;

  AuthRemoteDataSource({Dio? dio}) : _dio = dio ?? Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  Future<Response> login(Map<String, dynamic> credentials) async {
    try {
      final response = await _dio.post(
        ApiConstants.loginEndpoint,
        data: credentials,
      );
      return response;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Erro ao realizar login');
    } catch (e) {
      throw Exception('Erro inesperado: $e');
    }
  }

  Future<Response> register(Map<String, dynamic> userData) async {
    try {
      final response = await _dio.post(
        ApiConstants.registerEndpoint,
        data: userData,
      );
      return response;
    } on DioException catch (e) {
      // Re-lança o erro para ser tratado na UI ou no Controller
      throw Exception(e.response?.data['message'] ?? 'Erro ao realizar cadastro');
    } catch (e) {
      throw Exception('Erro inesperado: $e');
    }
  }
}