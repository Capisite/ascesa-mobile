import 'package:flutter/material.dart';
import 'package:ascesa/core/theme/app_colors.dart';
import 'package:ascesa/features/auth/presentation/pages/register_page.dart';
import 'package:ascesa/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:ascesa/features/main/presentation/pages/main_page.dart';
import 'package:ascesa/features/auth/presentation/controllers/auth_controller.dart';
import 'package:ascesa/features/auth/domain/usecases/login_use_case.dart';
import 'package:ascesa/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:ascesa/features/auth/data/datasources/auth_remote_data_source.dart';

import 'package:ascesa/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:ascesa/core/services/biometric_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _useBiometrics = false;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  // Dependency Injection (Simplificada para este exemplo)
  late final AuthController _authController;
  final AuthLocalDataSource _localDataSource = AuthLocalDataSource();
  final BiometricService _biometricService = BiometricService();

  @override
  void initState() {
    super.initState();
    final remoteDataSource = AuthRemoteDataSource();
    final repository = AuthRepositoryImpl(remoteDataSource: remoteDataSource);
    final loginUseCase = LoginUseCase(repository: repository);
    _authController = AuthController(loginUseCase: loginUseCase);
    
    _authController.addListener(_onAuthStateChanged);
    _checkBiometricLogin();
  }

  Future<void> _checkBiometricLogin() async {
    final enabled = await _localDataSource.isBiometricsEnabled();
    setState(() {
      _useBiometrics = enabled;
    });

    if (enabled) {
      final credentials = await _localDataSource.getCredentials();
      if (credentials != null) {
        final authenticated = await _biometricService.authenticate();
        if (authenticated) {
          _emailController.text = credentials['email']!;
          _passwordController.text = credentials['password']!;
          _handleLogin(isBiometric: true);
        }
      }
    }
  }

  @override
  void dispose() {
    _authController.removeListener(_onAuthStateChanged);
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onAuthStateChanged() {
    if (_authController.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_authController.errorMessage!),
          backgroundColor: Colors.red,
        ),
      );
      _authController.clearError();
    }
  }

  Future<void> _handleLogin({bool isBiometric = false}) async {
    if (isBiometric || _formKey.currentState!.validate()) {
      final email = _emailController.text;
      final password = _passwordController.text;
      
      final success = await _authController.login(email, password);

      if (success && mounted) {
        if (_useBiometrics) {
          await _localDataSource.setBiometricsEnabled(true);
          await _localDataSource.saveCredentials(email, password);
        } else {
          await _localDataSource.setBiometricsEnabled(false);
          await _localDataSource.clearUser(); // Limpa credenciais também
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MainPage(
              user: _authController.user!,
              token: _authController.accessToken!,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Form(
            key: _formKey,
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
                controller: _emailController,
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira seu e-mail';
                  }
                  if (!value.contains('@')) {
                    return 'E-mail inválido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Password Field
              TextFormField(
                controller: _passwordController,
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira sua senha';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Options
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: _useBiometrics,
                        onChanged: (value) {
                          setState(() {
                            _useBiometrics = value ?? false;
                          });
                        },
                        activeColor: AppColors.greenPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const Text(
                        'Usar biometria',
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
              ListenableBuilder(
                listenable: _authController,
                builder: (context, child) {
                  return ElevatedButton(
                    onPressed: _authController.isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.greenDark,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _authController.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Entrar',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  );
                },
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
    ),
  );
}
}
