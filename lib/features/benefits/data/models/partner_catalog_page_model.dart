import 'package:ascesa/features/benefits/domain/entities/partner_catalog_page.dart';
import 'package:ascesa/features/benefits/data/models/partner_model.dart';

class PartnerCatalogPageModel extends PartnerCatalogPage {
  PartnerCatalogPageModel({
    required super.data,
    required super.total,
    required super.page,
    required super.size,
  });

  factory PartnerCatalogPageModel.fromJson(Map<String, dynamic> json) {
    return PartnerCatalogPageModel(
      data: (json['items'] ?? json['data'] as List? ?? [])
          .map<PartnerModel>((item) => PartnerModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      size: json['size'] ?? 20,
    );
  }
}
