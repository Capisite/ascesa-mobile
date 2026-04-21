import 'package:ascesa/features/faq/domain/entities/faq.dart';
import 'package:ascesa/features/faq/domain/repositories/faq_repository.dart';

class GetFaqs {
  final FaqRepository repository;

  GetFaqs(this.repository);

  Future<List<Faq>> call() async {
    return await repository.getFaqs();
  }
}
