import 'package:flutter_project/features/benefits/domain/entities/partner.dart';
import 'package:flutter_project/features/benefits/domain/repositories/benefits_repository.dart';

class GetPartnersByCategoryUseCase {
  final BenefitsRepository repository;

  GetPartnersByCategoryUseCase({required this.repository});

  Future<List<Partner>> execute() async {
    return await repository.getPartners();
  }
}
