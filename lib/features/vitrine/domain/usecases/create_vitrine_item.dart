import 'package:ascesa/features/vitrine/domain/repositories/vitrine_repository.dart';

class CreateVitrineItem {
  final VitrineRepository repository;

  CreateVitrineItem(this.repository);

  Future<void> call(Map<String, dynamic> data) async {
    return await repository.createVitrineItem(data);
  }
}
