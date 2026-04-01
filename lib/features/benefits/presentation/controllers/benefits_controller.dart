import 'package:flutter/material.dart';
import 'package:ascesa/features/benefits/domain/entities/partner.dart';
import 'package:ascesa/features/benefits/domain/usecases/get_partners_by_category_use_case.dart';
import 'package:ascesa/core/services/geofencing_service.dart';

class BenefitsController extends ChangeNotifier {
  final GetPartnersByCategoryUseCase getPartnersUseCase;

  bool _isLoading = false;
  String? _errorMessage;
  List<Partner> _allPartners = [];
  String? _selectedCategoryId;

  BenefitsController({required this.getPartnersUseCase});

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  List<Partner> get partners {
    if (_selectedCategoryId == null || _selectedCategoryId!.isEmpty) {
      return _allPartners;
    }
    return _allPartners.where((p) => p.categoryId == _selectedCategoryId || p.categoryName == _selectedCategoryId).toList();
  }

  String? get selectedCategoryId => _selectedCategoryId;

  Future<void> fetchAllPartners() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _allPartners = await getPartnersUseCase.execute();
      
      _isLoading = false;
      notifyListeners();

      // Register partners for geofencing (asynchronous, don't wait if it fails for UI purposes)
      try {
        await GeofencingService.registerPartners(_allPartners);
      } catch (geofenceError) {
        debugPrint("Erro ao registrar geofencing: $geofenceError");
      }
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  void setFilter(String? categoryId) {
    _selectedCategoryId = categoryId;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
  
  void reset() {
    _allPartners = [];
    _selectedCategoryId = null;
    _errorMessage = null;
    notifyListeners();
  }
}
