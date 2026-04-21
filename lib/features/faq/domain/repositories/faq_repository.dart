import 'package:ascesa/features/faq/domain/entities/faq.dart';

abstract class FaqRepository {
  Future<List<Faq>> getFaqs();
}
