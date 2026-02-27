import 'package:flutter/material.dart';
import 'package:flutter_project/core/theme/app_colors.dart';
import 'package:flutter_project/features/auth/presentation/pages/register_page.dart';
import 'package:flutter_project/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:flutter_project/features/main/presentation/pages/main_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _rememberMe = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 48),
              // Ascesa Logo
              Center(
                child: Image.asset(
                  'assets/images/logo.png',
                  height: 100,
                  color: AppColors
                      .greenPrimary, // Colorindo o logo branco para verde escuro
                  errorBuilder: (context, error, stackTrace) => const Column(
                    children: [
                      Icon(
                        Icons.image_not_supported,
                        size: 64,
                        color: AppColors.greenPrimary,
                      ),
                      Text(
                        'Logo não encontrado',
                        style: TextStyle(color: AppColors.textLight),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 48),
              const Center(
                child: Text(
                  'Já é associado?',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: AppColors.greenDark, // Using a darker green
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Email Field
              TextFormField(
                decoration: InputDecoration(
                  hintText: 'E-mail',
                  hintStyle: const TextStyle(color: AppColors.textLight),
                  prefixIcon: const Icon(
                    Icons.email_outlined,
                    color: AppColors.textLight,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.greenPrimary),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              // Password Field
              TextFormField(
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Senha',
                  hintStyle: const TextStyle(color: AppColors.textLight),
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                    color: AppColors.textLight,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.greenPrimary),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Options
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: _rememberMe,
                        onChanged: (value) {
                          setState(() {
                            _rememberMe = value ?? false;
                          });
                        },
                        activeColor: AppColors.greenPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const Text(
                        'Lembrar de mim',
                        style: TextStyle(color: AppColors.textMuted),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ForgotPasswordPage(),
                        ),
                      );
                    },
                    child: const Text(
                      'Esqueceu sua senha?',
                      style: TextStyle(
                        color: Colors.blueAccent,
                      ), // Blue as in the mock
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Login Button
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const MainPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.greenDark, // Very dark green
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Entrar',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 32),

              const Divider(color: AppColors.border),
              const SizedBox(height: 32),

              // Register Link
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegisterPage(),
                      ),
                    );
                  },
                  child: const Text(
                    'Associar-se agora',
                    style: TextStyle(
                      color: Colors.blueAccent,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
