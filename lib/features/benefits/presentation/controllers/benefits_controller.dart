import 'package:flutter/material.dart';
import 'package:ascesa/features/benefits/domain/entities/partner.dart';
import 'package:ascesa/features/benefits/domain/usecases/get_partners_by_category_use_case.dart';
import 'package:ascesa/core/services/geofencing_service.dart';
import 'package:ascesa/core/services/proximity_service.dart';

class BenefitsController extends ChangeNotifier {
  final GetPartnersByCategoryUseCase getPartnersUseCase;

  bool _isLoading = false;
  String? _errorMessage;
  List<Partner> _allPartners = [];
  String? _selectedCategoryName;
  String _searchQuery = '';

  BenefitsController({required this.getPartnersUseCase});

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  List<Partner> get partners {
    List<Partner> filtered = _allPartners;
    
    // Filter by Category
    if (_selectedCategoryName != null && _selectedCategoryName!.isNotEmpty) {
      filtered = filtered.where((p) => p.categoryName == _selectedCategoryName).toList();
    }
    
    // Filter by Search Query
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((p) {
        final nameMatch = p.name.toLowerCase().contains(query);
        final titleMatch = p.title?.toLowerCase().contains(query) ?? false;
        return nameMatch || titleMatch;
      }).toList();
    }
    
    return filtered;
  }

  String? get selectedCategoryName => _selectedCategoryName;
  String get searchQuery => _searchQuery;

  Future<void> fetchAllPartners() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _allPartners = await getPartnersUseCase.execute();
      
      _isLoading = false;
      notifyListeners();

      // Register partners for geofencing (background) + proximity (foreground)
      try {
        await GeofencingService.registerPartners(_allPartners);
      } catch (geofenceError) {
        debugPrint("Erro ao registrar geofencing: $geofenceError");
      }

      // Inicia o monitoramento de proximidade em foreground (mais confiável)
      try {
        ProximityService.instance.start(_allPartners);
      } catch (proximityError) {
        debugPrint("Erro ao iniciar proximity service: $proximityError");
      }
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  void setFilter(String? categoryName) {
    _selectedCategoryName = categoryName;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Busca um parceiro pelo ID. Usado para navegar ao mapa via notificação.
  Partner? findPartnerById(String partnerId) {
    try {
      return _allPartners.firstWhere((p) => p.id == partnerId);
    } catch (_) {
      return null;
    }
  }

  /// Busca um parceiro por um fragmento do zone ID do geofencing.
  /// O zoneId tem formato: zone_{partnerId}_{addressName}
  Partner? findPartnerByZoneId(String zoneId) {
    // Extrai o partnerId do zoneId: zone_{partnerId}_{rest}
    final parts = zoneId.split('_');
    if (parts.length >= 2) {
      final partnerId = parts[1];
      return findPartnerById(partnerId);
    }
    return null;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
  
  void reset() {
    _allPartners = [];
    _selectedCategoryName = null;
    _searchQuery = '';
    _errorMessage = null;
    notifyListeners();
  }
}
