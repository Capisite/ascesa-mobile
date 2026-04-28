import 'package:ascesa/features/benefits/domain/entities/partner.dart';
import 'package:ascesa/features/benefits/domain/repositories/benefits_repository.dart';

class GetMapPartnersUseCase {
  final BenefitsRepository repository;

  GetMapPartnersUseCase({required this.repository});

  Future<List<Partner>> execute({
    String? name,
    String? categoryId,
  }) async {
    return await repository.getMapPartners(
      name: name,
      categoryId: categoryId,
    );
  }
}
