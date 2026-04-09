import 'package:flutter/material.dart';
import 'package:ascesa/core/theme/app_colors.dart';
import 'package:ascesa/features/auth/presentation/pages/register_page.dart';
import 'package:ascesa/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:ascesa/features/home/presentation/widgets/virtual_id_card_dialog.dart';
import 'package:ascesa/features/auth/domain/entities/user.dart';
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
  
  late final AuthController _authController;
  final AuthLocalDataSource _localDataSource = AuthLocalDataSource();
  final BiometricService _biometricService = BiometricService();
  User? _cachedUser;
  bool _showFullForm = true;

  @override
  void initState() {
    super.initState();
    final remoteDataSource = AuthRemoteDataSource();
    final repository = AuthRepositoryImpl(remoteDataSource: remoteDataSource);
    final loginUseCase = LoginUseCase(repository: repository);
    _authController = AuthController(loginUseCase: loginUseCase);
    
    _authController.addListener(_onAuthStateChanged);
    _checkInitialState();
  }

  Future<void> _checkInitialState() async {
    final enabled = await _localDataSource.isBiometricsEnabled();
    final cachedUser = await _localDataSource.getUser();
    final credentials = await _localDataSource.getCredentials();
    
    debugPrint('--- [DEBUG CACHE LOGIN] ---');
    debugPrint('Biometrics enabled: $enabled');
    debugPrint('CachedUser: ${cachedUser?.name} (is null? ${cachedUser == null})');
    debugPrint('Credentials exists: ${credentials != null}');

    setState(() {
      _useBiometrics = enabled;
      _cachedUser = cachedUser;
      if (cachedUser != null && credentials != null) {
        _showFullForm = false;
      }
    });
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
          content: Text(_translateError(_authController.errorMessage!)),
          backgroundColor: Colors.red,
        ),
      );
      _authController.clearError();
    }
  }

  String _translateError(String error) {
    final lowerError = error.toLowerCase();
    
    if (lowerError.contains('invalid credentials') || lowerError.contains('incorrect password')) {
      return 'E-mail ou senha inválidos.';
    }
    
    if (lowerError.contains('password must be longer than')) {
      // Tenta extrair o número se existir, ex: "password must be longer than 6 characters"
      final match = RegExp(r'\d+').firstMatch(error);
      if (match != null) {
        return 'A senha deve ter pelo menos ${match.group(0)} caracteres.';
      }
      return 'A senha é muito curta.';
    }

    if (lowerError.contains('user not found')) {
      return 'Usuário não encontrado.';
    }

    if (lowerError.contains('email must be a valid email')) {
      return 'Por favor, insira um e-mail válido.';
    }

    // Fallback para erros desconhecidos (mantém o original ou traduz genérico)
    return error;
  }

  Future<void> _handleLogin() async {
    if (_useBiometrics || !_showFullForm) {
      final credentials = await _localDataSource.getCredentials();
      if (credentials != null) {
        if (!_showFullForm) {
          // Se o formulário não está sendo exibido, faz o bypass da biometria
          _emailController.text = credentials['email']!;
          _passwordController.text = credentials['password']!;
        } else if (_useBiometrics &&
            ((_emailController.text.isEmpty && _passwordController.text.isEmpty) ||
             (_emailController.text == credentials['email']))) {
          // Exige biometria apenas se estiver mostrando o formulário e a opção estiver marcada
          final authenticated = await _biometricService.authenticate();
          if (authenticated) {
            _emailController.text = credentials['email']!;
            _passwordController.text = credentials['password']!;
          } else {
            return;
          }
        }
      }
    }

    if (_formKey.currentState!.validate()) {
      final email = _emailController.text;
      final password = _passwordController.text;
      
      final success = await _authController.login(email, password);

      if (success && mounted) {
        // ALWAYS save user so it's available for the virtual ID card
        await _localDataSource.saveUser(_authController.user!);

        if (_useBiometrics) {
          await _localDataSource.setBiometricsEnabled(true);
          await _localDataSource.saveCredentials(email, password);
        } else {
          await _localDataSource.setBiometricsEnabled(false);
          await _localDataSource.clearCredentials(); // Clear ONLY credentials, keep the user
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
      floatingActionButton: _cachedUser != null
          ? FloatingActionButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => VirtualIdCardDialog(user: _cachedUser!),
                );
              },
              backgroundColor: AppColors.greenPrimary,
              child: const Icon(Icons.badge, color: Colors.white),
            )
          : null,
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
              Center(
                child: Text(
                  !_showFullForm && _cachedUser != null
                      ? 'Bem-vindo(a) de volta,\n${_cachedUser!.name}!'
                      : 'Já é associado?',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: AppColors.greenDark, // Using a darker green
                  ),
                ),
              ),
              const SizedBox(height: 32),

              if (_showFullForm) ...[
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
              ],
              
              if (!_showFullForm) ...[
                Center(
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        _showFullForm = true;
                        _emailController.clear();
                        _passwordController.clear();
                      });
                    },
                    child: const Text('Entrar com outra conta', style: TextStyle(color: AppColors.greenPrimary)),
                  ),
                ),
                const SizedBox(height: 16),
              ],

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
