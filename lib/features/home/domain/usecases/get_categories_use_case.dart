import 'package:flutter_project/features/home/domain/entities/category.dart';
import 'package:flutter_project/features/home/domain/repositories/home_repository.dart';

class GetCategoriesUseCase {
  final HomeRepository repository;

  GetCategoriesUseCase({required this.repository});

  Future<List<Category>> execute() async {
    final categories = await repository.getCategories();
    // Sort by order if needed, but endpoint Usually returns sorted data
    categories.sort((a, b) => a.order.compareTo(b.order));
    return categories;
  }
}
