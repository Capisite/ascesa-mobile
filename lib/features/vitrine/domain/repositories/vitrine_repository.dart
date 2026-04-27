import 'package:ascesa/features/vitrine/domain/entities/vitrine_item.dart';

abstract class VitrineRepository {
  Future<List<VitrineItem>> getVitrineItems({int page = 1, int limit = 12, String? category});
  Future<void> createVitrineItem(Map<String, dynamic> data);
}
