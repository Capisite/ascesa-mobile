import 'package:flutter/material.dart';
import 'package:ascesa/core/services/notification_service.dart';
import 'package:ascesa/core/services/geofencing_service.dart';
import 'package:ascesa/features/auth/presentation/pages/login_page.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services
  await NotificationService.init();
  await GeofencingService.init();

  // Request mandatory permissions for background monitoring
  final locationStatus = await Permission.location.request();
  final notificationStatus = await Permission.notification.request();
  
  debugPrint("[Permissions] Location: $locationStatus");
  debugPrint("[Permissions] Notification: $notificationStatus");
  
  // On Android, locationAlways MUST be requested AFTER base location is granted
  if (await Permission.location.isGranted) {
    final alwaysStatus = await Permission.locationAlways.request();
    debugPrint("[Permissions] LocationAlways: $alwaysStatus");
  }

  // Solicita isenção de otimização de bateria — essencial para geofencing background
  final batteryStatus = await Permission.ignoreBatteryOptimizations.request();
  debugPrint("[Permissions] IgnoreBatteryOptimizations: $batteryStatus");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ascesa Mobile',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1B5E20)),
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}
