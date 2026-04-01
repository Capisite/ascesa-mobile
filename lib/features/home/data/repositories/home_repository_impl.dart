import 'package:ascesa/features/home/data/datasources/home_local_data_source.dart';
import 'package:ascesa/features/home/data/datasources/home_remote_data_source.dart';
import 'package:ascesa/features/home/domain/entities/category.dart';
import 'package:ascesa/features/home/domain/repositories/home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;
  final HomeLocalDataSource localDataSource;

  HomeRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<List<Category>> getCategories() async {
    try {
      final remoteCategories = await remoteDataSource.getCategories();
      await localDataSource.cacheCategories(remoteCategories);
      return remoteCategories;
    } catch (e) {
      // If remote fails, try to get from local cache
      final localCategories = await localDataSource.getCachedCategories();
      if (localCategories.isNotEmpty) {
        return localCategories;
      }
      rethrow; // If local is also empty or failed, rethrow the original error
    }
  }
}
