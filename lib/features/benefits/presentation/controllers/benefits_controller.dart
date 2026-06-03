import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ascesa/features/benefits/domain/entities/partner.dart';
import 'package:ascesa/features/benefits/domain/usecases/get_partners_by_category_use_case.dart';
import 'package:ascesa/features/benefits/domain/usecases/get_map_partners_use_case.dart';
import 'package:ascesa/features/benefits/data/datasources/benefits_remote_data_source.dart';
import 'package:ascesa/core/services/geofencing_service.dart';
import 'package:ascesa/core/services/proximity_service.dart';

class BenefitsController extends ChangeNotifier {
  final GetPartnersByCategoryUseCase getPartnersUseCase;
  final GetMapPartnersUseCase getMapPartnersUseCase;
  final BenefitsRemoteDataSource remoteDataSource;

  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;

  List<Partner> _catalogPartners = [];
  List<Partner> _mapPartners = [];

  String? _selectedCategoryId;
  String _searchQuery = '';
  bool _hasPortalSessionHint = false;

  int _currentPage = 1;
  bool _hasMore = true;

  BenefitsController({
    required this.getPartnersUseCase,
    required this.getMapPartnersUseCase,
    required this.remoteDataSource,
  });

  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get errorMessage => _errorMessage;
  bool get hasMore => _hasMore;

  List<Partner> get partners => _catalogPartners;
  List<Partner> get mapPartners => _mapPartners;

  String? get selectedCategoryId => _selectedCategoryId;
  String get searchQuery => _searchQuery;

  Future<void> fetchPartners({bool reset = false}) async {
    if (reset) {
      _currentPage = 1;
      _hasMore = true;
      _catalogPartners = [];
      _isLoading = true;
      _errorMessage = null;
    } else {
      if (!_hasMore || _isLoading || _isLoadingMore) return;
      _isLoadingMore = true;
    }
    notifyListeners();

    try {
      final pageData = await getPartnersUseCase.execute(
        name: _searchQuery,
        categoryId: _selectedCategoryId,
        page: _currentPage,
        size: 20,
      );

      if (reset) {
        _catalogPartners = pageData.data;
      } else {
        _catalogPartners.addAll(pageData.data);
      }

      _hasMore = pageData.data.length == 20;
      if (_hasMore) _currentPage++;

      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> fetchMapPartners() async {
    try {
      _mapPartners = await getMapPartnersUseCase.execute(
        name: _searchQuery,
        categoryId: _selectedCategoryId,
      );
      notifyListeners();

      // Register partners for geofencing and proximity after fetching map data
      _registerGeofencingAndProximity(_mapPartners);
    } catch (e) {
      debugPrint("Erro ao buscar parceiros do mapa: $e");
    }
  }

  Future<void> _registerGeofencingAndProximity(List<Partner> partnersToTrack) async {
      try {
        Position? currentPosition;
        try {
          final permission = await Geolocator.checkPermission();
          if (permission == LocationPermission.whileInUse ||
              permission == LocationPermission.always) {
            currentPosition = await Geolocator.getCurrentPosition();
          }
        } catch (e) {
          debugPrint("Erro ao obter localização atual para geofencing: $e");
        }
        
        await GeofencingService.registerPartners(partnersToTrack, userPosition: currentPosition);
      } catch (geofenceError) {
        debugPrint("Erro ao registrar geofencing: $geofenceError");
      }

      try {
        await ProximityService.instance.start(partnersToTrack);
      } catch (proximityError) {
        debugPrint("Erro ao iniciar proximity service: $proximityError");
      }
  }

  void setFilter(String? categoryId) {
    if (_selectedCategoryId == categoryId) return;
    _selectedCategoryId = categoryId;
    fetchPartners(reset: true);
    fetchMapPartners();
  }

  void setSearchQuery(String query) {
    if (_searchQuery == query) return;
    _searchQuery = query;
    fetchPartners(reset: true);
    fetchMapPartners();
  }

  Partner? findPartnerById(String partnerId) {
    try {
      return _mapPartners.firstWhere((p) => p.id == partnerId);
    } catch (_) {
      try {
        return _catalogPartners.firstWhere((p) => p.id == partnerId);
      } catch (_) {
        return null;
      }
    }
  }

  Partner? findPartnerByZoneId(String zoneId) {
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
    _catalogPartners = [];
    _mapPartners = [];
    _selectedCategoryId = null;
    _searchQuery = '';
    _errorMessage = null;
    _hasPortalSessionHint = false;
    _currentPage = 1;
    _hasMore = true;
    notifyListeners();
  }
}
