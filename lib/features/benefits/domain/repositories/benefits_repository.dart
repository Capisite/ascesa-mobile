import 'package:ascesa/features/benefits/domain/entities/partner.dart';

abstract class BenefitsRepository {
  Future<List<Partner>> getPartners();
}
