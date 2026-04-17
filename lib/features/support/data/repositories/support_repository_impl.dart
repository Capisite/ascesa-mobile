import 'package:ascesa/features/support/domain/repositories/support_repository.dart';
import 'package:ascesa/features/support/data/datasources/support_remote_data_source.dart';
import 'package:ascesa/features/support/domain/entities/support_message.dart';
import 'package:ascesa/features/support/domain/entities/support_ticket.dart';

class SupportRepositoryImpl implements SupportRepository {
  final SupportRemoteDataSource remoteDataSource;

  SupportRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Map<String, dynamic>> getConversation({int page = 1, int limit = 50}) async {
    return await remoteDataSource.getConversation(page: page, limit: limit);
  }

  @override
  Future<Map<String, dynamic>> sendMessage(String content) async {
    return await remoteDataSource.sendMessage(content);
  }
}
