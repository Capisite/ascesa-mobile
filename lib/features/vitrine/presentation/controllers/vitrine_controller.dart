import 'package:flutter/material.dart';
import 'package:ascesa/features/vitrine/domain/entities/vitrine_item.dart';
import 'package:ascesa/features/vitrine/domain/usecases/get_vitrine_items.dart';
import 'package:ascesa/features/vitrine/domain/usecases/create_vitrine_item.dart';

class VitrineController extends ChangeNotifier {
  final GetVitrineItems getVitrineItemsUseCase;
  final CreateVitrineItem? createVitrineItemUseCase;

  List<VitrineItem> _items = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;
  int _currentPage = 1;
  bool _hasMore = true;
  String? _selectedCategory;
  bool _isCreating = false;
  String? _createError;

  VitrineController({
    required this.getVitrineItemsUseCase,
    this.createVitrineItemUseCase,
  });

  List<VitrineItem> get items => _items;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get errorMessage => _errorMessage;
  bool get hasMore => _hasMore;
  String? get selectedCategory => _selectedCategory;
  bool get isCreating => _isCreating;
  String? get createError => _createError;

  Future<void> fetchItems({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _items = [];
      _hasMore = true;
    }

    if (!_hasMore || _isLoading || _isLoadingMore) return;

    if (_currentPage == 1) {
      _isLoading = true;
    } else {
      _isLoadingMore = true;
    }
    
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await getVitrineItemsUseCase.call(
        page: _currentPage, 
        limit: 10,
        category: _selectedCategory,
      );
      
      if (results.length < 10) {
        _hasMore = false;
      }

      if (refresh) {
        _items = results;
      } else {
        _items.addAll(results);
      }
      
      _currentPage++;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  void setCategory(String? category) {
    if (_selectedCategory == category) return;
    _selectedCategory = category;
    fetchItems(refresh: true);
  }

  Future<bool> createItem(Map<String, dynamic> data) async {
    if (createVitrineItemUseCase == null) return false;

    _isCreating = true;
    _createError = null;
    notifyListeners();

    try {
      await createVitrineItemUseCase!.call(data);
      _isCreating = false;
      notifyListeners();
      return true;
    } catch (e) {
      _createError = e.toString();
      _isCreating = false;
      notifyListeners();
      return false;
    }
  }
}
