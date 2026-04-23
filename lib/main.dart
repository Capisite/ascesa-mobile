import 'package:flutter/material.dart';
import 'package:ascesa/core/services/notification_service.dart';
import 'package:ascesa/core/services/geofencing_service.dart';
import 'package:ascesa/features/auth/presentation/pages/login_page.dart';
import 'package:permission_handler/permission_handler.dart';

/// GlobalKey para acessar o NavigatorState de qualquer lugar do app.
/// Usado pelo NotificationService para navegar ao clicar na notificação.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── 1. Solicita permissões ANTES de inicializar serviços que dependem delas ──
  // Todas as requests são fire-and-forget — o app funciona mesmo se negadas.
  await _requestPermissions();

  // ── 2. Inicializa serviços de forma segura ──
  // Cada init() é protegido por try/catch internamente para não crashar o app.
  await _initServices();

  runApp(const MyApp());
}

/// Solicita as permissões necessárias de forma não-bloqueante.
/// O app continua normalmente mesmo se o usuário negar alguma.
Future<void> _requestPermissions() async {
  try {
    final locationStatus = await Permission.location.request();
    debugPrint("[Permissions] Location: $locationStatus");

    final notificationStatus = await Permission.notification.request();
    debugPrint("[Permissions] Notification: $notificationStatus");

    // locationAlways DEVE ser solicitado APÓS base location ser concedida
    if (locationStatus.isGranted) {
      final alwaysStatus = await Permission.locationAlways.request();
      debugPrint("[Permissions] LocationAlways: $alwaysStatus");
    }

    // Isenção de otimização de bateria — essencial para geofencing background
    final batteryStatus = await Permission.ignoreBatteryOptimizations.request();
    debugPrint("[Permissions] IgnoreBatteryOptimizations: $batteryStatus");
  } catch (e) {
    debugPrint("[Permissions] Erro ao solicitar permissões: $e");
  }
}

/// Inicializa serviços de background de forma segura.
/// Erros são capturados para não crashar o app na inicialização.
Future<void> _initServices() async {
  try {
    await NotificationService.init();
    debugPrint("[Services] NotificationService inicializado.");
  } catch (e) {
    debugPrint("[Services] Falha ao inicializar NotificationService: $e");
  }

  try {
    await GeofencingService.init();
    debugPrint("[Services] GeofencingService inicializado.");
  } catch (e) {
    debugPrint("[Services] Falha ao inicializar GeofencingService: $e");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
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
