import 'package:ascesa/core/network/auth_interceptor.dart';
import 'package:ascesa/features/support/data/models/support_message_model.dart';
import 'package:ascesa/features/support/data/models/support_ticket_model.dart';
import 'package:dio/dio.dart';
import 'package:ascesa/core/constants/api_constants.dart';

abstract class SupportRemoteDataSource {
  Future<Map<String, dynamic>> getConversation({int page = 1, int limit = 50});
  Future<Map<String, dynamic>> sendMessage(String content);
}

class SupportRemoteDataSourceImpl implements SupportRemoteDataSource {
  final Dio _dio;
  final String token;

  SupportRemoteDataSourceImpl({Dio? dio, required this.token}) : _dio = dio ?? Dio(
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

  @override
  Future<Map<String, dynamic>> getConversation({int page = 1, int limit = 50}) async {
    try {
      final response = await _dio.get(
        ApiConstants.supportConversationEndpoint,
        queryParameters: {'page': page, 'limit': limit},
      );

      final data = response.data;
      return {
        'ticket': data['ticket'] != null ? SupportTicketModel.fromJson(data['ticket']) : null,
        'messages': (data['messages'] as List)
            .map((m) => SupportMessageModel.fromJson(m))
            .toList(),
        'meta': data['meta'],
      };
    } catch (e) {
      throw Exception('Erro ao buscar conversa: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> sendMessage(String content) async {
    try {
      final response = await _dio.post(
        ApiConstants.supportMessageEndpoint,
        data: {'content': content},
      );

      final data = response.data;
      return {
        'message': data['message'],
        'ticket': SupportTicketModel.fromJson(data['ticket']),
        'supportMessage': SupportMessageModel.fromJson(data['supportMessage']),
      };
    } catch (e) {
      throw Exception('Erro ao enviar mensagem: $e');
    }
  }
}
