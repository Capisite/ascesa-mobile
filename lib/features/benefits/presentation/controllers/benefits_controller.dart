import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ascesa/features/benefits/domain/entities/partner.dart';
import 'package:ascesa/features/benefits/domain/usecases/get_partners_by_category_use_case.dart';
import 'package:ascesa/features/benefits/data/datasources/benefits_remote_data_source.dart';
import 'package:ascesa/core/services/geofencing_service.dart';
import 'package:ascesa/core/services/proximity_service.dart';

class BenefitsController extends ChangeNotifier {
  final GetPartnersByCategoryUseCase getPartnersUseCase;
  final BenefitsRemoteDataSource remoteDataSource;

  bool _isLoading = false;
  String? _errorMessage;
  List<Partner> _allPartners = [];
  String? _selectedCategoryName;
  String _searchQuery = '';
  bool _hasPortalSessionHint = false;

  BenefitsController({
    required this.getPartnersUseCase,
    required this.remoteDataSource,
  });

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
        Position? currentPosition;
        try {
          currentPosition = await Geolocator.getCurrentPosition();
        } catch (e) {
          debugPrint("Erro ao obter localização atual para geofencing: $e");
        }
        
        await GeofencingService.registerPartners(_allPartners, userPosition: currentPosition);
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

  /// Obtém a URL de acesso autenticado para um parceiro e abre no navegador.
  /// Equivalente ao handleOpenPartner do front-end web.
  Future<void> openPartner(String partnerId, BuildContext context) async {
    try {
      final result = await remoteDataSource.getPartnerAccess(
        partnerId,
        hasPortalSessionHint: _hasPortalSessionHint,
      );

      final String? url = result['url'];
      final String? mode = result['mode'];

      if (mode == 'DIRECT_LINK') {
        _hasPortalSessionHint = true;
      }

      if (url != null && url.isNotEmpty) {
        final uri = Uri.parse(url);
        if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Não foi possível abrir o link')),
            );
          }
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Link de desconto não disponível')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        final message = e.toString().replaceFirst('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    }
  }
  
  void reset() {
    _allPartners = [];
    _selectedCategoryName = null;
    _searchQuery = '';
    _errorMessage = null;
    _hasPortalSessionHint = false;
    notifyListeners();
  }
}
