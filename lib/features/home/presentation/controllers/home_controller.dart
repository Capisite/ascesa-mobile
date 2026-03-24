import 'package:flutter/material.dart';
import 'package:flutter_project/features/home/domain/entities/category.dart';
import 'package:flutter_project/features/home/domain/usecases/get_categories_use_case.dart';

class HomeController extends ChangeNotifier {
  final GetCategoriesUseCase getCategoriesUseCase;

  bool _isLoading = false;
  String? _errorMessage;
  List<Category> _categories = [];

  HomeController({required this.getCategoriesUseCase});

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Category> get categories => _categories;

  Future<void> fetchCategories() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _categories = await getCategoriesUseCase.execute();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
