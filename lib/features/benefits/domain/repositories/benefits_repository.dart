import 'package:ascesa/features/benefits/domain/entities/partner.dart';
import 'package:ascesa/features/benefits/domain/entities/partner_catalog_page.dart';

abstract class BenefitsRepository {
  Future<PartnerCatalogPage> getPartnersCatalog({
    String? name,
    String? categoryId,
    int page = 1,
    int size = 20,
  });

  Future<List<Partner>> getMapPartners({
    String? name,
    String? categoryId,
  });
}
