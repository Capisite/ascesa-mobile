import 'package:flutter/material.dart';
import 'package:ascesa/core/theme/app_colors.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:dio/dio.dart';
import 'package:ascesa/core/constants/api_constants.dart';

import 'package:ascesa/features/auth/domain/entities/user.dart';

class VirtualIdCardDialog extends StatefulWidget {
  final User user;
  final String? token;
  const VirtualIdCardDialog({super.key, required this.user, this.token});

  @override
  State<VirtualIdCardDialog> createState() => _VirtualIdCardDialogState();
}

class _VirtualIdCardDialogState extends State<VirtualIdCardDialog> {
  String? _cardToken;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchCardToken();
  }

  Future<void> _fetchCardToken() async {
    if (widget.token == null) {
      setState(() {
        _loading = false;
        _error = 'Token indisponível';
      });
      return;
    }

    try {
      final dio = Dio();
      dio.options.headers['Authorization'] = 'Bearer ${widget.token}';
      
      final response = await dio.get('${ApiConstants.baseUrl}/digital-cards/my');
      
      if (response.statusCode == 200 && response.data != null) {
        setState(() {
          _cardToken = response.data['token'];
          _loading = false;
        });
      } else {
        setState(() {
          _error = 'Erro ao carregar';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Sem conexão';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    final String validationUrl = _cardToken != null 
        ? 'https://ascesa.com.br/validar-carteirinha/$_cardToken'
        : 'https://ascesa.com.br/validar-carteirinha/${user.id}';


    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Sua Carteirinha',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.greenDark,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textLight),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ID Card Graphic
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.greenDark, // Dark green card background
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.greenDark.withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Header with Logo
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset(
                        'assets/images/logo.png',
                        height: 24,
                        color: Colors.white,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(
                              Icons.forest,
                              color: Colors.white,
                              size: 24,
                            ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          user.associate ? 'ATIVO' : 'PENDENTE',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Photo and Basic Info
                  Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const ClipOval(
                          child: Center(
                            child: Icon(
                              Icons.person,
                              color: AppColors.greenLight,
                              size: 30,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.name.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Status: ${user.status}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // QR Code Area
            const Text(
              'Apresente este código',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: _loading
                  ? const SizedBox(
                      width: 150,
                      height: 150,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.greenDark,
                        ),
                      ),
                    )
                  : _error != null
                      ? SizedBox(
                          width: 150,
                          height: 150,
                          child: Center(
                            child: Text(
                              _error!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        )
                      : QrImageView(
                          data: validationUrl,
                          version: QrVersions.auto,
                          size: 150.0,
                        ),
            ),
            const SizedBox(height: 12),
            Text(
              _loading 
                  ? 'Gerando token seguro...' 
                  : _error != null 
                      ? 'Falha na verificação' 
                      : 'Válido por 24 horas',
              style: const TextStyle(fontSize: 10, color: AppColors.textLight),
            ),
          ],
        ),
      ),
    );
  }
}
