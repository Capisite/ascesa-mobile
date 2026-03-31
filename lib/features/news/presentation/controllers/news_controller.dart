import 'package:flutter/material.dart';
import 'package:flutter_project/features/news/domain/entities/news.dart';
import 'package:flutter_project/features/news/domain/usecases/get_news.dart';

class NewsController extends ChangeNotifier {
  final GetNews getNewsUseCase;

  bool _isLoading = false;
  String? _errorMessage;
  List<News> _news = [];

  NewsController({required this.getNewsUseCase});

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<News> get news => _news;

  Future<void> fetchNews() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _news = await getNewsUseCase.call();
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
