import 'package:ascesa/features/benefits/domain/entities/partner.dart';

class PartnerCatalogPage {
  final List<Partner> data;
  final int total;
  final int page;
  final int size;

  PartnerCatalogPage({
    required this.data,
    required this.total,
    required this.page,
    required this.size,
  });
}
