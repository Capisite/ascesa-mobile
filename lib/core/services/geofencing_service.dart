import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:geofence_foreground_service/geofence_foreground_service.dart';
import 'package:geofence_foreground_service/models/zone.dart';
import 'package:geofence_foreground_service/constants/geofence_event_type.dart';
import 'package:latlng/latlng.dart';
import 'package:ascesa/core/services/notification_service.dart';
import 'package:ascesa/features/benefits/domain/entities/partner.dart';

class GeofencingService {
  static final GeofenceForegroundService _geofenceService =
      GeofenceForegroundService();

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

  static Future<void> registerPartners(List<Partner> partners) async {
    // Garantir que o serviço está rodando antes de adicionar zonas
    await startService();

    // Limpar zonas antigas para evitar duplicidade ou exceder limites do OS
    try {
      await _geofenceService.removeAllGeoFences();
      debugPrint("Zonas antigas removidas.");
    } catch (e) {
      debugPrint("Erro ao remover zonas: $e");
    }
    
    // O sistema operacional limita a exatamente 100 geofences TOTAL por app.
    int registeredCount = 0;
    const int maxGeofences = 100;

    if (partners.isEmpty) {
      debugPrint("Nenhum parceiro para registrar.");
      return;
    }

    for (var partner in partners) {
      if (registeredCount >= maxGeofences) break;

      for (var address in partner.addressess) {
        if (registeredCount >= maxGeofences) break;

        if (address.location != null && address.location!.coordinates.length >= 2) {
          final lat = address.location!.coordinates[1];
          final lng = address.location!.coordinates[0];
          
          final zoneId = 'zone_${partner.id}_${address.nameUnit ?? registeredCount}';
          debugPrint("Registrando zona: $zoneId (${partner.name}) lat=$lat, lng=$lng");
          
          try {
            final bool success = await _geofenceService.addGeofenceZone(
              zone: Zone(
                id: zoneId,
                radius: 1000, // 1km em metros
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
              debugPrint("Zona registrada com sucesso: $zoneId");
            } else {
              debugPrint("Falha ao registrar zona para: ${partner.name}");
            }
          } catch (e) {
            debugPrint("Erro ao registrar zona $zoneId: $e");
          }
        }
      }
    }
    debugPrint("Total de zonas registradas com sucesso: $registeredCount");
  }
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

