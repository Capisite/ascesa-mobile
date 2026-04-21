import 'package:ascesa/features/faq/domain/entities/faq.dart';
import 'package:ascesa/features/faq/domain/repositories/faq_repository.dart';
import 'package:ascesa/features/faq/data/datasources/faq_remote_data_source.dart';

class FaqRepositoryImpl implements FaqRepository {
  final FaqRemoteDataSource remoteDataSource;

  FaqRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Faq>> getFaqs() async {
    return await remoteDataSource.getFaqs();
  }
}
