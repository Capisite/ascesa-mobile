import 'package:flutter_project/features/benefits/domain/entities/partner.dart';

abstract class BenefitsRepository {
  Future<List<Partner>> getPartners();
}
