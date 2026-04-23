import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Callback global para quando o usuário clica na notificação
  static void Function(String? payload)? onNotificationTapped;

  static Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );

    // Create the channel explicitly on Android
    final androidImplementation =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidImplementation != null) {
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'geofence_notifications',
        'Alertas de Parceiros',
        description: 'Notificações quando você estiver perto de um parceiro',
        importance: Importance.max,
        playSound: true,
      );
      await androidImplementation.createNotificationChannel(channel);
    }

    // Verifica se o app foi aberto via notificação (app estava fechado)
    final launchDetails = await _notificationsPlugin.getNotificationAppLaunchDetails();
    if (launchDetails != null && 
        launchDetails.didNotificationLaunchApp &&
        launchDetails.notificationResponse != null) {
      // Atrasa para garantir que o app inicializou completamente
      Future.delayed(const Duration(seconds: 2), () {
        _onNotificationResponse(launchDetails.notificationResponse!);
      });
    }
  }

  static void _onNotificationResponse(NotificationResponse response) {
    debugPrint("[NotificationService] Notificação clicada! Payload: ${response.payload}");
    if (response.payload != null && onNotificationTapped != null) {
      onNotificationTapped!(response.payload);
    }
  }

  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'geofence_notifications',
        'Alertas de Parceiros',
        channelDescription: 'Notificações quando você estiver perto de um parceiro',
        importance: Importance.max,
        priority: Priority.high,
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notificationsPlugin.show(
        id,
        title,
        body,
        notificationDetails,
        payload: payload,
      );
    } catch (e) {
      // Captura erros do plugin (permissão negada, overlay bloqueado, etc.)
      // para evitar unhandled future que mata o app.
      debugPrint('[NotificationService] Falha ao exibir notificação: $e');
    }
  }
}
