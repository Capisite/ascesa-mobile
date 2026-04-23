import 'package:flutter/material.dart';
import 'package:ascesa/core/theme/app_colors.dart';
import 'package:ascesa/features/auth/presentation/widgets/custom_text_field.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class Step2ContactAccess extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final TextEditingController mobilePhoneController;
  final TextEditingController businessPhoneController;
  final MaskTextInputFormatter phoneFormatter;

  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const Step2ContactAccess({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.mobilePhoneController,
    required this.businessPhoneController,
    required this.phoneFormatter,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Contato e acesso',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.greenDark,
            ),
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.bgLight, thickness: 1),
          const SizedBox(height: 16),

          CustomTextField(
            label: 'E-mail',
            hintText: 'Ex: antonio@email.com',
            keyboardType: TextInputType.emailAddress,
            controller: emailController,
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  label: 'Senha',
                  hintText: 'Senha',
                  obscureText: true,
                  controller: passwordController,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomTextField(
                  label: 'Confirme sua Senha',
                  hintText: 'Senha',
                  obscureText: true,
                  controller: confirmPasswordController,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  label: 'Celular',
                  hintText: '(00) 00000-0000',
                  keyboardType: TextInputType.phone,
                  inputFormatters: [phoneFormatter],
                  controller: mobilePhoneController,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomTextField(
                  label: 'Tel comercial',
                  hintText: '(00) 0000-0000',
                  keyboardType: TextInputType.phone,
                  inputFormatters: [phoneFormatter],
                  controller: businessPhoneController,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: onPrevious,
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.bgLight,
                  foregroundColor: AppColors.greenDark,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text(
                  'Anterior',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
              ElevatedButton(
                onPressed: onNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.greenDark,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                child: const Text(
                  'Próximo',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
