import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_project/core/theme/app_colors.dart';
import 'package:flutter_project/features/benefits/domain/entities/partner.dart';
import 'package:flutter_project/features/benefits/presentation/controllers/benefits_controller.dart';
import 'package:flutter_project/features/benefits/presentation/widgets/convenio_card.dart';

class BenefitsMapPage extends StatefulWidget {
  final BenefitsController benefitsController;

  const BenefitsMapPage({
    super.key,
    required this.benefitsController,
  });

  @override
  State<BenefitsMapPage> createState() => _BenefitsMapPageState();
}

class _BenefitsMapPageState extends State<BenefitsMapPage> {
  final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();
  Set<Marker> _markers = {};
  Partner? _selectedPartner;

  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(-15.7942, -47.8822), // Brasília default
    zoom: 12.0,
  );

  @override
  void initState() {
    super.initState();
    _determinePosition();
    _loadMarkers();
  }

  Future<void> _determinePosition() async {
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
    
    // Tentar obter a última posição conhecida primeiro para agilizar
    final lastKnown = await Geolocator.getLastKnownPosition();
    if (lastKnown != null && mounted) {
      final GoogleMapController controller = await _controller.future;
      controller.moveCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(lastKnown.latitude, lastKnown.longitude),
          14.0,
        ),
      );
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(position.latitude, position.longitude),
          14.0,
        ),
      );
    } catch (e) {
      debugPrint('Erro ao obter localização precisa: $e');
      // Não trava a tela se der erro, apenas mantém a última posição ou a inicial
    }
  }

  void _loadMarkers() {
    final partners = widget.benefitsController.partners;
    final Set<Marker> newMarkers = {};

    for (var partner in partners) {
      for (var address in partner.addressess) {
        if (address.location != null && address.location!.coordinates.length >= 2) {
          // GeoJSON is [longitude, latitude]
          final lat = address.location!.coordinates[1];
          final lng = address.location!.coordinates[0];

          newMarkers.add(
            Marker(
              markerId: MarkerId('${partner.id}_${address.nameUnit ?? ''}'),
              position: LatLng(lat, lng),
              infoWindow: InfoWindow(
                title: partner.name,
                snippet: partner.title ?? 'Ver detalhes',
              ),
              onTap: () {
                setState(() {
                  _selectedPartner = partner;
                });
              },
            ),
          );
        }
      }
    }

    setState(() {
      _markers = newMarkers;
    });
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
            icon: const Icon(Icons.my_location, color: AppColors.greenPrimary),
            onPressed: _determinePosition,
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: _initialPosition,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            markers: _markers,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
            onTap: (_) {
              setState(() {
                _selectedPartner = null;
              });
            },
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
                  coverUrl: _selectedPartner!.cover,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
