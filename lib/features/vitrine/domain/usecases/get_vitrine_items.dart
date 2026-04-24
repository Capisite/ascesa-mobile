import 'package:ascesa/features/vitrine/domain/entities/vitrine_item.dart';
import 'package:ascesa/features/vitrine/domain/repositories/vitrine_repository.dart';

class GetVitrineItems {
  final VitrineRepository repository;

  GetVitrineItems(this.repository);

  Future<List<VitrineItem>> call({int page = 1, int limit = 12, String? category}) async {
    return await repository.getVitrineItems(page: page, limit: limit, category: category);
  }
}
