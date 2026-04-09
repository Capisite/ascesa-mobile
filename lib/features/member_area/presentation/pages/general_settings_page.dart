import 'package:flutter/material.dart';
import 'package:ascesa/core/theme/app_colors.dart';
import 'package:ascesa/core/services/settings_service.dart';
import 'package:ascesa/features/auth/presentation/pages/login_page.dart';

class GeneralSettingsPage extends StatefulWidget {
  const GeneralSettingsPage({super.key});

  @override
  State<GeneralSettingsPage> createState() => _GeneralSettingsPageState();
}

class _GeneralSettingsPageState extends State<GeneralSettingsPage> {
  final SettingsService _settingsService = SettingsService();
  bool _isPerformanceModeEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final enabled = await _settingsService.isPerformanceModeEnabled();
    if (mounted) {
      setState(() {
        _isPerformanceModeEnabled = enabled;
      });
    }
  }

  Future<void> _togglePerformanceMode(bool value) async {
    await _settingsService.setPerformanceModeEnabled(value);
    setState(() {
      _isPerformanceModeEnabled = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.greenDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Configurações Gerais',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.greenDark,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ajuste as preferências do aplicativo e gerencie sua sessão.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textMuted,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 32),
            
            _buildSectionTitle('Preferências'),
            _buildPerformanceModeItem(),
            
            const SizedBox(height: 32),
            _buildSectionTitle('Sessão'),
            _buildLogoutItem(
              onTap: () {
                _showLogoutConfirmDialog();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceModeItem() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.textMuted.withValues(alpha: 0.1)),
      ),
      child: SwitchListTile(
        value: _isPerformanceModeEnabled,
        onChanged: _togglePerformanceMode,
        activeColor: AppColors.greenPrimary,
        title: const Text(
          'Modo de Performance',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.greenDark,
          ),
        ),
        subtitle: const Text(
          'Limita o mapa aos 20 locais mais próximos para melhorar a velocidade.',
          style: TextStyle(fontSize: 12, color: AppColors.textMuted),
        ),
        secondary: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.greenPrimary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.speed_rounded, color: AppColors.greenPrimary, size: 22),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.textLight,
          letterSpacing: 1.2,
        ),
      ),
    );
  }


  Widget _buildLogoutItem({required VoidCallback onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 22),
        ),
        title: const Text(
          'Sair da conta',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.redAccent,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: Colors.redAccent,
          size: 20,
        ),
      ),
    );
  }

  void _showLogoutConfirmDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Sair da conta'),
        content: const Text('Tem certeza que deseja encerrar sua sessão?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () {
              // Limpa a pilha de navegação e volta para a tela de login
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (route) => false,
              );
            },
            child: const Text('Sair', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
