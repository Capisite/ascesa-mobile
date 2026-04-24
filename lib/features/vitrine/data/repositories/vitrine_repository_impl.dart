import 'package:ascesa/features/vitrine/domain/entities/vitrine_item.dart';
import 'package:ascesa/features/vitrine/domain/repositories/vitrine_repository.dart';
import 'package:ascesa/features/vitrine/data/datasources/vitrine_remote_data_source.dart';

class VitrineRepositoryImpl implements VitrineRepository {
  final VitrineRemoteDataSource remoteDataSource;

  VitrineRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<VitrineItem>> getVitrineItems({int page = 1, int limit = 12, String? category}) async {
    return await remoteDataSource.getVitrineItems(page: page, limit: limit, category: category);
  }
}
