import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ascesa/core/theme/app_colors.dart';
import 'package:ascesa/core/services/settings_service.dart';
import 'package:ascesa/features/benefits/domain/entities/partner.dart';
import 'package:ascesa/features/benefits/presentation/controllers/benefits_controller.dart';
import 'package:ascesa/features/benefits/presentation/widgets/convenio_card.dart';

class BenefitsMapPage extends StatefulWidget {
  final BenefitsController benefitsController;
  final Partner? initialPartner;

  const BenefitsMapPage({
    super.key,
    required this.benefitsController,
    this.initialPartner,
  });

  @override
  State<BenefitsMapPage> createState() => _BenefitsMapPageState();
}

class _PartnerAddressWithDistance {
  final Partner partner;
  final PartnerAddress address;
  final double distance;
  final double lat;
  final double lng;

  _PartnerAddressWithDistance({
    required this.partner,
    required this.address,
    required this.distance,
    required this.lat,
    required this.lng,
  });
}

class _BenefitsMapPageState extends State<BenefitsMapPage> {
  final MapController _mapController = MapController();
  final SettingsService _settingsService = SettingsService();
  List<Marker> _markers = [];
  Partner? _selectedPartner;
  PartnerAddress? _selectedAddress;
  LatLng? _currentUserPosition;
  StreamSubscription<Position>? _positionSubscription;
  bool _isPerformanceModeEnabled = false;

  static const LatLng _initialPosition = LatLng(-15.7942, -47.8822); // Brasília default

  @override
  void initState() {
    super.initState();
    if (widget.initialPartner != null) {
      _selectedPartner = widget.initialPartner;
    }
    _loadSettingsAndMarkers();
    _determineInitialPosition();
    _initLocationStream();
  }

  Future<void> _loadSettingsAndMarkers() async {
    _isPerformanceModeEnabled = await _settingsService.isPerformanceModeEnabled();
    _loadMarkers();
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    super.dispose();
  }

  Future<void> _determineInitialPosition() async {
    // If we have an initial partner, we'll center on it instead of user location
    if (widget.initialPartner != null) {
      for (var address in widget.initialPartner!.addressess) {
        if (address.location != null && address.location!.coordinates.length >= 2) {
          final lat = address.location!.coordinates[1];
          final lng = address.location!.coordinates[0];
          final pos = LatLng(lat, lng);
          
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _mapController.move(pos, 15.0);
          });
          break;
        }
      }
    }

    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    
    if (permission == LocationPermission.deniedForever) return;
    
    final lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null && mounted) {
        final pos = LatLng(lastKnown.latitude, lastKnown.longitude);
        setState(() {
          _currentUserPosition = pos;
        });
        _loadMarkers();
        if (widget.initialPartner == null) {
          _mapController.move(pos, 14.0);
        }
      }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      final pos = LatLng(position.latitude, position.longitude);
      if (mounted) {
        setState(() {
          _currentUserPosition = pos;
        });
        _loadMarkers();
        if (widget.initialPartner == null) {
          _mapController.move(pos, 14.0);
        }
      }
    } catch (e) {
      debugPrint('Erro ao obter localização inicial: $e');
    }
  }

  void _initLocationStream() {
    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((Position position) {
      if (mounted) {
        final newPos = LatLng(position.latitude, position.longitude);
        setState(() {
          _currentUserPosition = newPos;
        });
        _loadMarkers();
        // Auto-follow: only if no partner is initially selected or we aren't in "selection mode"
        if (widget.initialPartner == null) {
          _mapController.move(newPos, _mapController.camera.zoom);
        }
      }
    });
  }

  void _loadMarkers() {
    List<Partner> partners = widget.benefitsController.partners;
    final List<Marker> newMarkers = [];

    // Se o modo de performance estiver ativado e tivermos a localização do usuário,
    // filtramos pelos 20 mais próximos.
    if (_isPerformanceModeEnabled && _currentUserPosition != null) {
      // Cria uma lista flat de endereços para ordenar por distância
      List<_PartnerAddressWithDistance> sortedList = [];
      
      for (var partner in partners) {
        for (var address in partner.addressess) {
          if (address.location != null && address.location!.coordinates.length >= 2) {
            final lat = address.location!.coordinates[1];
            final lng = address.location!.coordinates[0];
            
            final distance = Geolocator.distanceBetween(
              _currentUserPosition!.latitude,
              _currentUserPosition!.longitude,
              lat,
              lng,
            );
            
            sortedList.add(_PartnerAddressWithDistance(
              partner: partner,
              address: address,
              distance: distance,
              lat: lat,
              lng: lng,
            ));
          }
        }
      }

      sortedList.sort((a, b) => a.distance.compareTo(b.distance));
      
      // Pega os 20 mais próximos
      final top20 = sortedList.take(20).toList();
      
      for (var item in top20) {
        newMarkers.add(_buildMarker(item.partner, item.address, item.lat, item.lng));
      }
    } else {
      // Modo normal ou sem localização: renderiza todos
      for (var partner in partners) {
        for (var address in partner.addressess) {
          if (address.location != null && address.location!.coordinates.length >= 2) {
            final lat = address.location!.coordinates[1];
            final lng = address.location!.coordinates[0];
            newMarkers.add(_buildMarker(partner, address, lat, lng));
          }
        }
      }
    }

    setState(() {
      _markers = newMarkers;
    });
  }

  Marker _buildMarker(Partner partner, PartnerAddress address, double lat, double lng) {
    return Marker(
      point: LatLng(lat, lng),
      width: 40,
      height: 40,
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedPartner = partner;
            _selectedAddress = address;
          });
        },
        child: const Icon(
          Icons.location_on,
          color: AppColors.greenPrimary,
          size: 40,
        ),
      ),
    );
  }

  void _onMyLocationPressed() {
    if (_currentUserPosition != null) {
      _mapController.move(_currentUserPosition!, 15.0);
    } else {
      _determineInitialPosition();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mapa de Parceiros',
          style: TextStyle(
            color: AppColors.greenDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.greenDark),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location, color: AppColors.greenDark),
            onPressed: _onMyLocationPressed,
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _initialPosition,
              initialZoom: 12.0,
              onTap: (_, __) {
                setState(() {
                  _selectedPartner = null;
                  _selectedAddress = null;
                });
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.ascesa.app',
              ),
              MarkerLayer(
                markers: _markers,
              ),
              if (_currentUserPosition != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _currentUserPosition!,
                      width: 25,
                      height: 25,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              RichAttributionWidget(
                attributions: [
                  TextSourceAttribution(
                    'OpenStreetMap contributors',
                    onTap: () => {},
                  ),
                ],
              ),
            ],
          ),
          if (_selectedPartner != null)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Container(
                constraints: const BoxConstraints(maxHeight: 200),
                child: ConvenioCard(
                  brandName: _selectedPartner!.name,
                  category: _selectedPartner!.categoryName ?? 'Parceiro',
                  discount: _selectedPartner!.title ?? 'Confira os benefícios',
                  brandColor: AppColors.greenPrimary,
                  logoUrl: _selectedPartner!.logoUrl,
                  address: _formatAddress(_selectedAddress),
                  onOpenDiscount: () => widget.benefitsController.openPartner(
                    _selectedPartner!.id, context,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatAddress(PartnerAddress? address) {
    if (address == null) return '';
    final List<String> parts = [];
    if (address.street != null && address.street!.isNotEmpty) {
      String streetPart = address.street!;
      if (address.number != null && address.number!.isNotEmpty) {
        streetPart += ', ${address.number}';
      }
      parts.add(streetPart);
    }
    if (address.neighborhood != null && address.neighborhood!.isNotEmpty) {
      parts.add(address.neighborhood!);
    }
    if (address.county != null && address.county!.isNotEmpty) {
      String cityPart = address.county!;
      if (address.state != null && address.state!.isNotEmpty) {
        cityPart += ' / ${address.state}';
      }
      parts.add(cityPart);
    }
    return parts.join(' - ');
  }
}

