import 'package:flutter_project/features/home/domain/entities/category.dart';

abstract class HomeRepository {
  Future<List<Category>> getCategories();
}
