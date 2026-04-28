import 'package:ascesa/features/benefits/data/datasources/benefits_local_data_source.dart';
import 'package:ascesa/features/benefits/data/datasources/benefits_remote_data_source.dart';
import 'package:ascesa/features/benefits/domain/entities/partner.dart';
import 'package:ascesa/features/benefits/domain/repositories/benefits_repository.dart';

import 'package:ascesa/features/benefits/domain/entities/partner_catalog_page.dart';

class BenefitsRepositoryImpl implements BenefitsRepository {
  final BenefitsRemoteDataSource remoteDataSource;
  final BenefitsLocalDataSource localDataSource;

  BenefitsRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<PartnerCatalogPage> getPartnersCatalog({
    String? name,
    String? categoryId,
    int page = 1,
    int size = 20,
  }) async {
    return await remoteDataSource.getPartnersCatalog(
      name: name,
      categoryId: categoryId,
      page: page,
      size: size,
    );
  }

  @override
  Future<List<Partner>> getMapPartners({
    String? name,
    String? categoryId,
  }) async {
    try {
      final remotePartners = await remoteDataSource.getMapPartners(
        name: name,
        categoryId: categoryId,
      );
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
