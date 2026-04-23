import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ascesa/core/services/notification_service.dart';
import 'package:ascesa/core/services/geofencing_service.dart';
import 'package:ascesa/features/benefits/domain/entities/partner.dart';

/// Serviço de proximidade em foreground.
/// Usa o stream de localização do Geolocator para verificar
/// a distância até os parceiros e disparar notificações.
/// 
/// Funciona enquanto o app está aberto — complementa o geofencing
/// nativo que cobre o cenário de background.
class ProximityService {
  static ProximityService? _instance;
  static ProximityService get instance => _instance ??= ProximityService._();
  
  ProximityService._();

  StreamSubscription<Position>? _positionSubscription;
  List<Partner> _partners = [];
  
  // Controle de cooldown: evita notificação repetida para o mesmo parceiro
  final Map<String, DateTime> _notifiedPartners = {};
  static const Duration _cooldownDuration = Duration(minutes: 30);
  
  // Raio de proximidade em metros
  static const double _proximityRadiusMeters = 100.0;
  
  bool _isRunning = false;
  bool get isRunning => _isRunning;

  /// Inicia o monitoramento de proximidade em foreground.
  /// Verifica a permissão de localização antes de iniciar o stream.
  Future<void> start(List<Partner> partners) async {
    if (_isRunning) {
      // Atualiza a lista de parceiros sem reiniciar o stream
      _partners = partners;
      debugPrint("[ProximityService] Lista de parceiros atualizada (${partners.length})");
      return;
    }

    // Verifica permissão antes de abrir o stream.
    // Sem isso, Geolocator lança uma exceção que pode crashar o app.
    try {
      final LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        debugPrint("[ProximityService] Permissão de localização negada. Monitoramento não iniciado.");
        return;
      }
    } catch (e) {
      debugPrint("[ProximityService] Erro ao verificar permissão: $e");
      return;
    }

    _partners = partners;
    _isRunning = true;

    debugPrint("[ProximityService] Iniciando monitoramento com ${partners.length} parceiros");

    try {
      _positionSubscription = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 50, // Verifica a cada 50m de movimento
        ),
      ).listen(
        (Position position) async {
          await _checkProximity(position.latitude, position.longitude);
          
          // Verifica se precisa atualizar a lista de 20 geofences mais próximos
          if (GeofencingService.shouldUpdateGeofences(position)) {
            debugPrint("[ProximityService] Movimento detectado. Atualizando top 20 geofences.");
            GeofencingService.registerPartners(_partners, userPosition: position);
          }
        },
        onError: (error) {
          debugPrint("[ProximityService] Erro no stream de localização: $error");
          _isRunning = false;
        },
      );
    } catch (e) {
      debugPrint("[ProximityService] Falha ao iniciar stream de localização: $e");
      _isRunning = false;
    }
  }

  /// Para o monitoramento.
  void stop() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
    _isRunning = false;
    debugPrint("[ProximityService] Monitoramento de proximidade parado.");
  }

  /// Verifica a distância do usuário a todos os parceiros.
  Future<void> _checkProximity(double userLat, double userLng) async {
    final now = DateTime.now();
    
    for (var partner in _partners) {
      for (var address in partner.addressess) {
        if (address.location == null || address.location!.coordinates.length < 2) {
          continue;
        }

        final partnerLat = address.location!.coordinates[1];
        final partnerLng = address.location!.coordinates[0];
        
        final distance = _calculateDistanceInMeters(
          userLat, userLng, partnerLat, partnerLng,
        );

        if (distance <= _proximityRadiusMeters) {
          final partnerId = partner.id;
          
          // Verifica cooldown
          if (_notifiedPartners.containsKey(partnerId)) {
            final lastNotified = _notifiedPartners[partnerId]!;
            if (now.difference(lastNotified) < _cooldownDuration) {
              continue; // Ainda em cooldown, não notifica de novo
            }
          }

          // Dispara notificação
          _notifiedPartners[partnerId] = now;
          
          final distanceFormatted = distance < 1000 
              ? '${distance.toInt()}m' 
              : '${(distance / 1000).toStringAsFixed(1)}km';
          
          debugPrint("[ProximityService] PARCEIRO PRÓXIMO: ${partner.name} a $distanceFormatted");
          
          // await + try/catch: evita unhandled future que mata o app
          // quando a permissão de notificação/overlay está negada.
          try {
            await NotificationService.showNotification(
              id: partnerId.hashCode,
              title: '📍 ${partner.name} está próximo!',
              body: 'Você está a $distanceFormatted. Confira os benefícios exclusivos!',
              payload: partnerId,
            );
          } catch (e) {
            debugPrint('[ProximityService] Erro ao notificar parceiro ${partner.name}: $e');
          }
        }
      }
    }
  }

  /// Calcula a distância entre dois pontos usando a fórmula de Haversine.
  static double _calculateDistanceInMeters(
    double lat1, double lon1, double lat2, double lon2,
  ) {
    const double earthRadiusMeters = 6371000;
    
    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);
    
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) * cos(_degreesToRadians(lat2)) *
        sin(dLon / 2) * sin(dLon / 2);
    
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    
    return earthRadiusMeters * c;
  }

  static double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }
}
