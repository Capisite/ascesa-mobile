import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _performanceModeKey = 'performance_mode_enabled';

  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();

  /// Verifica se o Modo de Performance está ativado.
  Future<bool> isPerformanceModeEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_performanceModeKey) ?? false;
  }

  /// Ativa ou desativa o Modo de Performance.
  Future<void> setPerformanceModeEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_performanceModeKey, enabled);
  }
}
