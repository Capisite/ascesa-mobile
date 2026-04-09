import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:geofence_foreground_service/geofence_foreground_service.dart';
import 'package:geofence_foreground_service/models/zone.dart';
import 'package:geofence_foreground_service/constants/geofence_event_type.dart';
import 'package:latlng/latlng.dart';
import 'package:ascesa/core/services/notification_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ascesa/features/benefits/domain/entities/partner.dart';

class GeofencingService {
  static final GeofenceForegroundService _geofenceService =
      GeofenceForegroundService();

  static Position? _lastRegistrationPosition;
  
  // Limite recomendado para iOS e melhor performance de bateria
  static const int maxGeofences = 20;
  // Distância em metros para considerar uma "viagem longa" e atualizar a lista
  static const double movementThresholdMeters = 5000; 

  static Future<void> init() async {
    // Initial setup if needed, but startGeofencingService handles most of it.
  }

  static Future<void> startService() async {
    try {
      final bool isRunning = await _geofenceService.isForegroundServiceRunning();
      debugPrint("Geofencing service running: $isRunning");
      
      if (!isRunning) {
        final bool started = await _geofenceService.startGeofencingService(
          notificationChannelId: 'geofence_notifications',
          contentTitle: "Monitorando Parceiros",
          contentText: "O Ascesa está monitorando benefícios próximos a você.",
          serviceId: 525600,
          callbackDispatcher: callbackDispatcher,
        );
        debugPrint("Geofencing service started: $started");
      }
    } catch (e) {
      debugPrint("Erro ao iniciar geofencing service: $e");
    }
  }

  /// Verifica se o usuário se moveu o suficiente para atualizar a lista de geofences.
  static bool shouldUpdateGeofences(Position currentPosition) {
    if (_lastRegistrationPosition == null) return true;

    final distance = Geolocator.distanceBetween(
      _lastRegistrationPosition!.latitude,
      _lastRegistrationPosition!.longitude,
      currentPosition.latitude,
      currentPosition.longitude,
    );

    return distance >= movementThresholdMeters;
  }

  static Future<void> registerPartners(List<Partner> partners, {Position? userPosition}) async {
    // Garantir que o serviço está rodando antes de adicionar zonas
    await startService();

    // Limpar zonas antigas para evitar duplicidade ou exceder limites do OS
    try {
      await _geofenceService.removeAllGeoFences();
      debugPrint("Zonas antigas removidas.");
    } catch (e) {
      debugPrint("Erro ao remover zonas: $e");
    }
    
    _lastRegistrationPosition = userPosition;

    if (partners.isEmpty) {
      debugPrint("Nenhum parceiro para registrar.");
      return;
    }

    // ACHATAR E FILTRAR: Criar lista de todos os endereços com geolocalização válida
    List<_AddressWithDistance> allAddresses = [];
    for (var partner in partners) {
      for (var address in partner.addressess) {
        if (address.location != null && address.location!.coordinates.length >= 2) {
          final lat = address.location!.coordinates[1];
          final lng = address.location!.coordinates[0];
          
          double distance = 0;
          if (userPosition != null) {
            distance = Geolocator.distanceBetween(
              userPosition.latitude,
              userPosition.longitude,
              lat,
              lng,
            );
          }

          allAddresses.add(_AddressWithDistance(
            partner: partner,
            address: address,
            lat: lat,
            lng: lng,
            distance: distance,
          ));
        }
      }
    }

    // ORDENAR: Ordenar por distância se a posição do usuário estiver disponível
    if (userPosition != null) {
      allAddresses.sort((a, b) => a.distance.compareTo(b.distance));
      debugPrint("Ordenando endereços por distância do usuário.");
    }

    // LIMITAR: Pegar apenas os 20 mais próximos
    final topAddresses = allAddresses.take(maxGeofences).toList();
    debugPrint("Registrando os ${topAddresses.length} endereços mais próximos (limite: $maxGeofences).");

    int registeredCount = 0;
    for (var item in topAddresses) {
      final partner = item.partner;
      final address = item.address;
      final lat = item.lat;
      final lng = item.lng;
      
      final zoneId = 'zone_${partner.id}_${address.nameUnit ?? registeredCount}';
      debugPrint("Registrando zona: $zoneId (${partner.name}) a ${item.distance.toInt()}m");
      
      try {
        final bool success = await _geofenceService.addGeofenceZone(
          zone: Zone(
            id: zoneId,
            radius: 100, // 100 metros
            coordinates: [
              LatLng.degree(lat, lng),
            ],
            triggers: [
              GeofenceEventType.enter,
              GeofenceEventType.exit,
              GeofenceEventType.dwell,
            ],
            initialTrigger: GeofenceEventType.enter,
            dwellLoiteringDelay: const Duration(minutes: 1),
          ),
        );

        if (success) {
          registeredCount++;
        } else {
          debugPrint("Falha ao registrar zona para: ${partner.name}");
        }
      } catch (e) {
        debugPrint("Erro ao registrar zona $zoneId: $e");
      }
    }
    debugPrint("Total de zonas registradas com sucesso: $registeredCount");
  }
}

/// Classe auxiliar interna para facilitar a ordenação por distância.
class _AddressWithDistance {
  final Partner partner;
  final dynamic address; // Usa dynamic ou Address se disponível
  final double lat;
  final double lng;
  final double distance;

  _AddressWithDistance({
    required this.partner,
    required this.address,
    required this.lat,
    required this.lng,
    required this.distance,
  });
}

@pragma('vm:entry-point')
void callbackDispatcher() async {
  // ESSENCIAL: inicializar binding do Flutter no isolate de background
  // Sem isso, plugins como flutter_local_notifications falham silenciosamente.
  WidgetsFlutterBinding.ensureInitialized();
  
  debugPrint("=== CALLBACK DISPATCHER INICIADO (background isolate) ===");
  
  GeofenceForegroundService().handleTrigger(
    backgroundTriggerHandler: (zoneId, eventType) async {
      debugPrint(">>> GATILHO DETECTADO: ID=$zoneId, EVENTO=$eventType");
      
      if (eventType == GeofenceEventType.enter || eventType == GeofenceEventType.dwell) {
        debugPrint("ENTROU/PERMANECEU NA ZONA: $zoneId - EXIBINDO NOTIFICAÇÃO");
        
        try {
          // Inicializa o serviço de notificações no Isolate de background
          await NotificationService.init();
          
          await NotificationService.showNotification(
            id: zoneId.hashCode,
            title: "📍 Parceiro Ascesa Próximo!",
            body: "Você está perto de um local com benefícios exclusivos. Abra o app para conferir!",
            payload: zoneId,
          );
          debugPrint("Notificação enviada com sucesso para zona: $zoneId");
        } catch (e, stackTrace) {
          debugPrint("Erro ao enviar notificação no background: $e");
          debugPrint("StackTrace: $stackTrace");
        }
      }
      return Future.value(true);
    },
  );
}

