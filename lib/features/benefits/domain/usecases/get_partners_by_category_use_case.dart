import 'package:ascesa/features/benefits/domain/entities/partner.dart';
import 'package:ascesa/features/benefits/domain/repositories/benefits_repository.dart';

import 'package:ascesa/features/benefits/domain/entities/partner_catalog_page.dart';

class GetPartnersByCategoryUseCase {
  final BenefitsRepository repository;

  GetPartnersByCategoryUseCase({required this.repository});

  Future<PartnerCatalogPage> execute({
    String? name,
    String? categoryId,
    int page = 1,
    int size = 20,
  }) async {
    return await repository.getPartnersCatalog(
      name: name,
      categoryId: categoryId,
      page: page,
      size: size,
    );
  }
}
