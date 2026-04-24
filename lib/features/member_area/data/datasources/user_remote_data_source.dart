import 'package:dio/dio.dart';
import 'package:ascesa/core/constants/api_constants.dart';
import 'package:ascesa/core/network/auth_interceptor.dart';

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
  ) {
    if (dio == null) {
      _dio.interceptors.add(AuthInterceptor());
    }
  }

  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await _dio.get(ApiConstants.updateUserEndpoint);
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Erro ao buscar perfil');
    } catch (e) {
      throw Exception('Erro inesperado: $e');
    }
  }

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

  Future<Map<String, dynamic>> updateProfilePhoto(String filePath) async {
    try {
      final formData = FormData.fromMap({
        'profilePhoto': await MultipartFile.fromFile(filePath),
      });
      final response = await _dio.patch(
        ApiConstants.updateUserEndpoint,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Erro ao atualizar foto');
    } catch (e) {
      throw Exception('Erro inesperado: $e');
    }
  }
}
