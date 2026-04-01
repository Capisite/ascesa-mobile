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
    final bool isRunning = await _geofenceService.isForegroundServiceRunning();
    
    if (!isRunning) {
      await _geofenceService.startGeofencingService(
        notificationChannelId: 'geofence_notifications',
        contentTitle: "Monitorando Parceiros",
        contentText: "O Ascesa está monitorando benefícios próximos a você.",
        callbackDispatcher: callbackDispatcher,
      );
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
          debugPrint("Registrando zona: $zoneId (${partner.name})");
          
          final bool success = await _geofenceService.addGeofenceZone(
            zone: Zone(
              id: zoneId,
              radius: 1000, 
              coordinates: [
                LatLng.degree(lat, lng),
              ],
            ),
          );

          if (success) {
            registeredCount++;
          } else {
            debugPrint("Falha ao registrar zona para: ${partner.name}");
          }
        }
      }
    }
    debugPrint("Total de zonas registradas com sucesso: $registeredCount");
  }
}

@pragma('vm:entry-point')
void callbackDispatcher() async {
  debugPrint("CALLBACK DISPATCHER INICIADO");
  GeofenceForegroundService().handleTrigger(
    backgroundTriggerHandler: (zoneId, eventType) async {
      debugPrint(">>> GATILHO DETECTADO EM BACKGROUND: ID=$zoneId, EVENTO=$eventType");
      
      if (eventType == GeofenceEventType.enter || eventType == GeofenceEventType.dwell) {
        debugPrint("ENTROU/PERMANECEU NA ZONA: $zoneId - EXIBINDO NOTIFICAÇÃO");
        
        try {
          // Inicializa o serviço de notificações no Isolate de background
          await NotificationService.init();
          
          await NotificationService.showNotification(
            id: zoneId.hashCode,
            title: "Parceiro Ascesa Próximo!",
            body: "Você está perto de um local com benefícios exclusivos. Abra o app para conferir!",
          );
          debugPrint("Notificação enviada com sucesso.");
        } catch (e) {
          debugPrint("Erro ao enviar notificação no background: $e");
        }
      }
      return true;
    },
  );
}
