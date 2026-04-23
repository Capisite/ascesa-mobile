import 'dart:io';
import 'package:flutter/material.dart';
import 'package:ascesa/core/theme/app_colors.dart';
import 'package:ascesa/features/auth/presentation/widgets/custom_text_field.dart';
import 'package:ascesa/features/auth/presentation/widgets/custom_dropdown.dart';
import 'package:ascesa/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

import 'package:ascesa/features/auth/presentation/widgets/register_steps/step1_personal_data.dart';
import 'package:ascesa/features/auth/presentation/widgets/register_steps/step2_contact_access.dart';
import 'package:ascesa/features/auth/presentation/widgets/register_steps/step3_address_filiation.dart';
import 'package:ascesa/features/auth/presentation/widgets/register_steps/step4_dependents.dart';
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  int _currentStep = 0;
  final int _totalSteps = 4;
  final PageController _pageController = PageController();
  final AuthRemoteDataSource _authDataSource = AuthRemoteDataSource();
  bool _isLoading = false;

  // Controllers - Step 1
  final _nameController = TextEditingController();
  final _cpfController = TextEditingController();
  final _rgController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _registrationNumberController = TextEditingController();
  String? _selectedGender;
  String? _selectedMaritalStatus;
  String? _companyRelationship;
  final _companyNameController = TextEditingController();
  final _affiliatedCompanyNameController = TextEditingController();
  File? _profilePhotoFile;
  final ImagePicker _imagePicker = ImagePicker();

  // Controllers - Step 2
  final _cepController = TextEditingController();
  final _streetController = TextEditingController();
  final _addressNumberController = TextEditingController();
  final _addressComplementController = TextEditingController();
  final _districtController = TextEditingController();
  final _cityController = TextEditingController();
  String? _selectedState;
  final _businessPhoneController = TextEditingController();
  final _mobilePhoneController = TextEditingController();
  final _fatherNameController = TextEditingController();
  final _motherNameController = TextEditingController();

  final List<String> _states = const [
    'AC', 'AL', 'AP', 'AM', 'BA', 'CE', 'DF', 'ES', 'GO', 'MA',
    'MT', 'MS', 'MG', 'PA', 'PB', 'PR', 'PE', 'PI', 'RJ', 'RN',
    'RS', 'RO', 'RR', 'SC', 'SP', 'SE', 'TO'
  ];

  // Controllers - Step 3
  final List<Map<String, String>> _dependents = [];
  final _depNameController = TextEditingController();
  final _depBirthDateController = TextEditingController();
  final _depCpfController = TextEditingController();
  String? _depSelectedGender;

  // Controllers - Step 4
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _cpfFormatter = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: {"#": RegExp(r'[0-9]')},
  );
  final _dateFormatter = MaskTextInputFormatter(
    mask: '##/##/####',
    filter: {"#": RegExp(r'[0-9]')},
  );
  final _rgFormatter = MaskTextInputFormatter(
    mask: '#.###.###',
    filter: {"#": RegExp(r'[0-9]')},
  );
  final _phoneFormatter = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {"#": RegExp(r'[0-9]')},
  );
  final _cepFormatter = MaskTextInputFormatter(
    mask: '#####-###',
    filter: {"#": RegExp(r'[0-9]')},
  );
  // Extra date and cpf formatter for dependents
  final _dependentDateFormatter = MaskTextInputFormatter(
    mask: '##/##/####',
    filter: {"#": RegExp(r'[0-9]')},
  );
  final _dependentCpfFormatter = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: {"#": RegExp(r'[0-9]')},
  );

  @override
  void initState() {
    super.initState();
    _cepController.addListener(_onCepChanged);
  }

  void _onCepChanged() {
    final cep = _cepController.text.replaceAll(RegExp(r'\D'), '');
    if (cep.length == 8) {
      _searchCep();
    }
  }

  Future<void> _searchCep() async {
    final cep = _cepController.text.replaceAll(RegExp(r'\D'), '');
    if (cep.length != 8) return;

    try {
      final dio = Dio();
      final response = await dio.get('https://viacep.com.br/ws/$cep/json/');

      if (response.data != null && response.data['erro'] != true) {
        setState(() {
          _streetController.text = response.data['logradouro'] ?? '';
          _districtController.text = response.data['bairro'] ?? '';
          _cityController.text = response.data['localidade'] ?? '';
          final uf = response.data['uf'];
          if (_states.contains(uf)) {
            _selectedState = uf;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao buscar CEP. Verifique sua conexão.')),
        );
      }
    }
  }

  @override
  void dispose() {
    _cepController.removeListener(_onCepChanged);
    _pageController.dispose();
    _nameController.dispose();
    _cpfController.dispose();
    _rgController.dispose();
    _birthDateController.dispose();
    _registrationNumberController.dispose();
    _companyNameController.dispose();
    _affiliatedCompanyNameController.dispose();
    _cepController.dispose();
    _streetController.dispose();
    _addressNumberController.dispose();
    _addressComplementController.dispose();
    _districtController.dispose();
    _cityController.dispose();
    _businessPhoneController.dispose();
    _mobilePhoneController.dispose();
    _fatherNameController.dispose();
    _motherNameController.dispose();
    _depNameController.dispose();
    _depBirthDateController.dispose();
    _depCpfController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentStep++;
      });
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentStep--;
      });
    }
  }

  String _formatDateToBackend(String date) {
    if (date.isEmpty) return '';
    final parts = date.split('/');
    if (parts.length != 3) return date;
    return '${parts[2]}-${parts[1]}-${parts[0]}';
  }

  String _mapGender(String? gender) {
    switch (gender) {
      case 'Masculino':
        return 'MALE';
      case 'Feminino':
        return 'FEMALE';
      case 'Outro':
        return 'OTHER';
      case 'Não informado':
        return 'NOT_INFORMED';
      default:
        return 'NOT_INFORMED';
    }
  }

  String _mapMaritalStatus(String? status) {
    switch (status) {
      case 'Solteiro(a)':
        return 'SINGLE';
      case 'Casado(a)':
        return 'MARRIED';
      case 'Divorciado(a)':
        return 'DIVORCED';
      case 'Viúvo(a)':
        return 'WIDOWED';
      case 'Separado(a)':
        return 'SEPARATED';
      case 'União estável':
        return 'STABLE_UNION';
      default:
        return 'SINGLE';
    }
  }

  String _translateError(String error) {
    final lowerError = error.toLowerCase();
    if (lowerError.contains('email already exists')) {
      return 'Este e-mail já está cadastrado.';
    }
    if (lowerError.contains('cpf already exists')) {
      return 'Este CPF já está cadastrado.';
    }
    if (lowerError.contains('registration number already exists')) {
      return 'Esta matrícula já está cadastrada.';
    }
    if (lowerError.contains('error creating user')) {
      return 'Ocorreu um erro ao criar sua conta.';
    }
    if (lowerError.contains('internal server error')) {
      return 'Erro no servidor. Tente mais tarde.';
    }
    
    // Remove default "Exception: " prefix and handle unknown errors
    String cleanError = error.replaceAll('Exception: ', '');
    if (cleanError.isEmpty || cleanError == 'null') {
      return 'Ocorreu um erro inesperado. Tente novamente.';
    }
    
    return cleanError;
  }

  Future<void> _pickProfilePhoto(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        imageQuality: 80,
      );
      if (image != null) {
        final file = File(image.path);
        final int sizeInBytes = file.lengthSync();
        if (sizeInBytes > 1 * 1024 * 1024) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('A foto deve ter no máximo 1MB.')),
            );
          }
          return;
        }
        setState(() {
          _profilePhotoFile = file;
        });
      }
    } catch (e) {
      debugPrint('Erro ao selecionar foto: $e');
    }
  }

  void _showPhotoPickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ListTile(
                title: Text(
                  'Selecione a fonte da foto',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Galeria'),
                onTap: () {
                  Navigator.pop(context);
                  _pickProfilePhoto(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: const Text('Câmera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickProfilePhoto(ImageSource.camera);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Future<void> _submitRegistration() async {

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('As senhas não coincidem.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final formData = FormData.fromMap({
        'name': _nameController.text,
        'email': _emailController.text,
        'password': _passwordController.text,
        'cpf': _cpfController.text.replaceAll(RegExp(r'\D'), ''),
        'rg': _rgController.text,
        'birthDate': _formatDateToBackend(_birthDateController.text),
        'registrationNumber': _registrationNumberController.text,
        'phone': _mobilePhoneController.text.replaceAll(RegExp(r'\D'), ''),
        'gender': _mapGender(_selectedGender),
        'maritalStatus': _mapMaritalStatus(_selectedMaritalStatus),
        'zipCode': _cepController.text.replaceAll(RegExp(r'\D'), ''),
        'street': _streetController.text,
        'addressNumber': _addressNumberController.text,
        'addressComplement': _addressComplementController.text,
        'district': _districtController.text,
        'city': _cityController.text,
        'state': _selectedState,
        'businessPhone': _businessPhoneController.text.replaceAll(RegExp(r'\D'), ''),
        'mobilePhone': _mobilePhoneController.text.replaceAll(RegExp(r'\D'), ''),
        'fatherName': _fatherNameController.text,
        'motherName': _motherNameController.text,
      });

      if (_companyRelationship == 'COOPERATIVE_EMPLOYEE' && _companyNameController.text.isNotEmpty) {
        formData.fields.add(MapEntry('companyName', _companyNameController.text));
      } else if (_companyRelationship == 'AFFILIATED_MEMBER' && _affiliatedCompanyNameController.text.isNotEmpty) {
        formData.fields.add(MapEntry('affiliatedCompanyName', _affiliatedCompanyNameController.text));
      }

      for (var i = 0; i < _dependents.length; i++) {
        final dep = _dependents[i];
        formData.fields.addAll([
          MapEntry('dependents[$i][name]', dep['nome'] ?? ''),
          MapEntry('dependents[$i][birthDate]', dep['nasc'] ?? ''),
          MapEntry('dependents[$i][cpf]', dep['cpf']?.replaceAll(RegExp(r'\D'), '') ?? ''),
          MapEntry('dependents[$i][gender]', _mapGender(dep['sexo'])),
        ]);
      }

      if (_profilePhotoFile != null) {
        formData.files.add(MapEntry(
          'profilePhoto',
          await MultipartFile.fromFile(_profilePhotoFile!.path),
        ));
      }

      await _authDataSource.register(formData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cadastro realizado com sucesso!'),
            backgroundColor: AppColors.greenPrimary,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_translateError(e.toString())),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.greenDark),
          onPressed: () {
            if (_currentStep > 0) {
              _previousStep();
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Custom Progress Bar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 8.0,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (_currentStep + 1) / _totalSteps,
                  backgroundColor: AppColors.bgLight,
                  color: AppColors.greenDark,
                  minHeight: 8,
                ),
              ),
            ),

            if (_isLoading)
              const LinearProgressIndicator(color: AppColors.greenPrimary),

            Expanded(
              child: PageView(
                controller: _pageController,
                physics:
                    const NeverScrollableScrollPhysics(), // Only navigate via buttons
                children: [
                  _buildStep1(),
                  _buildStep2(),
                  _buildStep3(),
                  _buildStep4(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep1() {
    return Step1PersonalData(
      nameController: _nameController,
      cpfController: _cpfController,
      rgController: _rgController,
      birthDateController: _birthDateController,
      registrationNumberController: _registrationNumberController,
      companyNameController: _companyNameController,
      affiliatedCompanyNameController: _affiliatedCompanyNameController,
      selectedGender: _selectedGender,
      onGenderChanged: (val) => setState(() => _selectedGender = val),
      selectedMaritalStatus: _selectedMaritalStatus,
      onMaritalStatusChanged: (val) => setState(() => _selectedMaritalStatus = val),
      companyRelationship: _companyRelationship,
      onCompanyRelationshipChanged: (val) => setState(() => _companyRelationship = val),
      profilePhotoFile: _profilePhotoFile,
      onPickProfilePhoto: _showPhotoPickerOptions,
      cpfFormatter: _cpfFormatter,
      rgFormatter: _rgFormatter,
      dateFormatter: _dateFormatter,
      onNext: _nextStep,
    );
  }

  Widget _buildStep2() {
    return Step2ContactAccess(
      emailController: _emailController,
      passwordController: _passwordController,
      confirmPasswordController: _confirmPasswordController,
      mobilePhoneController: _mobilePhoneController,
      businessPhoneController: _businessPhoneController,
      phoneFormatter: _phoneFormatter,
      onPrevious: _previousStep,
      onNext: _nextStep,
    );
  }

  Widget _buildStep3() {
    return Step3AddressFiliation(
      cepController: _cepController,
      addressNumberController: _addressNumberController,
      streetController: _streetController,
      districtController: _districtController,
      addressComplementController: _addressComplementController,
      cityController: _cityController,
      fatherNameController: _fatherNameController,
      motherNameController: _motherNameController,
      selectedState: _selectedState,
      onStateChanged: (val) => setState(() => _selectedState = val),
      onSearchCep: _searchCep,
      cepFormatter: _cepFormatter,
      states: _states,
      onPrevious: _previousStep,
      onNext: _nextStep,
    );
  }

  Widget _buildStep4() {
    return Step4Dependents(
      depNameController: _depNameController,
      depBirthDateController: _depBirthDateController,
      depCpfController: _depCpfController,
      depSelectedGender: _depSelectedGender,
      onDepGenderChanged: (val) => setState(() => _depSelectedGender = val),
      dependents: _dependents,
      onAddDependent: () {
        if (_depNameController.text.isNotEmpty) {
          setState(() {
            _dependents.add({
              'nome': _depNameController.text,
              'nasc': _formatDateToBackend(_depBirthDateController.text),
              'cpf': _depCpfController.text,
              'sexo': _depSelectedGender ?? 'Outro',
            });
            _depNameController.clear();
            _depBirthDateController.clear();
            _depCpfController.clear();
            _depSelectedGender = null;
          });
        }
      },
      onRemoveDependent: (idx) {
        setState(() {
          _dependents.removeAt(idx);
        });
      },
      dependentDateFormatter: _dependentDateFormatter,
      dependentCpfFormatter: _dependentCpfFormatter,
      isLoading: _isLoading,
      onPrevious: _previousStep,
      onSubmit: _submitRegistration,
    );
  }
}
