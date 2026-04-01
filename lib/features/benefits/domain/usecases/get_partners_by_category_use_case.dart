import 'package:ascesa/features/benefits/domain/entities/partner.dart';
import 'package:ascesa/features/benefits/domain/repositories/benefits_repository.dart';

class GetPartnersByCategoryUseCase {
  final BenefitsRepository repository;

  GetPartnersByCategoryUseCase({required this.repository});

  Future<List<Partner>> execute() async {
    return await repository.getPartners();
  }
}
