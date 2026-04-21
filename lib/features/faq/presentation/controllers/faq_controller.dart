import 'package:flutter/material.dart';
import 'package:ascesa/features/faq/domain/entities/faq.dart';
import 'package:ascesa/features/faq/domain/usecases/get_faqs.dart';

class FaqController extends ChangeNotifier {
  final GetFaqs getFaqsUseCase;

  List<Faq> _faqs = [];
  Map<String, List<Faq>> _groupedFaqs = {};
  bool _isLoading = false;
  String? _errorMessage;

  FaqController({required this.getFaqsUseCase});

  List<Faq> get faqs => _faqs;
  Map<String, List<Faq>> get groupedFaqs => _groupedFaqs;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchFaqs() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await getFaqsUseCase.call();
      _faqs = results;
      
      // Group by category
      _groupedFaqs = {};
      for (var faq in _faqs) {
        final category = faq.category ?? 'Geral';
        if (!_groupedFaqs.containsKey(category)) {
          _groupedFaqs[category] = [];
        }
        _groupedFaqs[category]!.add(faq);
      }

      // Sort within categories by displayOrder
      _groupedFaqs.forEach((key, list) {
        list.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
      });

    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
