import 'package:flutter_project/features/benefits/data/datasources/benefits_local_data_source.dart';
import 'package:flutter_project/features/benefits/data/datasources/benefits_remote_data_source.dart';
import 'package:flutter_project/features/benefits/domain/entities/partner.dart';
import 'package:flutter_project/features/benefits/domain/repositories/benefits_repository.dart';

class BenefitsRepositoryImpl implements BenefitsRepository {
  final BenefitsRemoteDataSource remoteDataSource;
  final BenefitsLocalDataSource localDataSource;

  BenefitsRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<List<Partner>> getPartners() async {
    try {
      final remotePartners = await remoteDataSource.getPartners();
      await localDataSource.cachePartners(remotePartners);
      return remotePartners;
    } catch (e) {
      final localPartners = await localDataSource.getCachedPartners();
      if (localPartners.isNotEmpty) {
        return localPartners;
      }
      rethrow;
    }
  }
}
