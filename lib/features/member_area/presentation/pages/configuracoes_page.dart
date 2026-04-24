import 'package:flutter/material.dart';
import 'package:ascesa/core/theme/app_colors.dart';
import 'package:ascesa/features/member_area/presentation/pages/user_profile_page.dart';
import 'package:ascesa/features/member_area/presentation/controllers/user_profile_controller.dart';
import 'package:ascesa/features/member_area/presentation/pages/dependents_page.dart';
import 'package:ascesa/features/member_area/presentation/pages/general_settings_page.dart';
import 'package:ascesa/features/support/presentation/controllers/support_controller.dart';
import 'package:ascesa/features/support/presentation/pages/support_page.dart';

class ConfiguracoesPage extends StatelessWidget {
  final UserProfileController userProfileController;
  final SupportController supportController;
  final String token;
  final String userId;
  final VoidCallback? onMenuPressed;
  
  const ConfiguracoesPage({
    super.key, 
    required this.userProfileController,
    required this.supportController,
    required this.token,
    required this.userId,
    this.onMenuPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: onMenuPressed != null
            ? IconButton(
                icon: const Icon(Icons.menu, color: AppColors.greenDark),
                onPressed: onMenuPressed,
              )
            : null,
        title: const Text(
          'Configurações',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.greenDark,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Gerencie sua conta e as configurações do aplicativo.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textMuted,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            
            // Perfil resumido
            ListenableBuilder(
              listenable: userProfileController,
              builder: (context, _) {
                final user = userProfileController.user;
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.bgLight.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: AppColors.greenPrimary.withValues(alpha: 0.1),
                        backgroundImage: user.profilePhotoUrl != null
                            ? NetworkImage(user.profilePhotoUrl!)
                            : null,
                        child: user.profilePhotoUrl == null
                            ? Text(
                                user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.greenPrimary,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.greenDark,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              user.email,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textMuted,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }
            ),
            
            const SizedBox(height: 32), 
            
            _buildSettingsItem(
              icon: Icons.person_outline,
              label: 'Usuário',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserProfilePage(controller: userProfileController),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildSettingsItem(
              icon: Icons.people_outline,
              label: 'Dependentes',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DependentsPage(token: token)),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildSettingsItem(
              icon: Icons.settings_suggest_outlined,
              label: 'Geral',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const GeneralSettingsPage()),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildSettingsItem(
              icon: Icons.headset_mic_outlined,
              label: 'Suporte',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SupportPage(
                      controller: supportController,
                      userId: userId,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
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
            color: AppColors.greenPrimary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.greenPrimary, size: 22),
        ),
        title: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.greenDark,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: AppColors.textLight,
          size: 20,
        ),
      ),
    );
  }
}
