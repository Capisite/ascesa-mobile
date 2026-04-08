import 'package:flutter/material.dart';
import 'package:ascesa/core/theme/app_colors.dart';
import 'package:ascesa/features/auth/presentation/widgets/custom_text_field.dart';
import 'package:ascesa/features/auth/presentation/widgets/custom_dropdown.dart';
import 'package:ascesa/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

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
  String? _selectedCompany;

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
  bool _lgpdEmail = false;
  bool _lgpdSocial = false;
  bool _lgpdSms = false;
  bool _termsConfirmed = false;

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
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _cpfController.dispose();
    _rgController.dispose();
    _birthDateController.dispose();
    _registrationNumberController.dispose();
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

  Future<void> _submitRegistration() async {
    if (!_termsConfirmed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Você precisa aceitar os termos de uso.')),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('As senhas não coincidem.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userData = {
        'name': _nameController.text,
        'email': _emailController.text,
        'password': _passwordController.text,
        'cpf': _cpfController.text.replaceAll(RegExp(r'\D'), ''),
        'rg': _rgController.text,
        'birthDate': _formatDateToBackend(_birthDateController.text),
        'registrationNumber': _registrationNumberController.text,
        'phone': _mobilePhoneController.text.replaceAll(RegExp(r'\D'), ''),
        'gender': _mapGender(_selectedGender),
        'maritalStatus': _selectedMaritalStatus,
        'companyName': _selectedCompany,
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
        'dependents': _dependents.map((d) => {
          'name': d['nome'],
          'birthDate': d['nasc'],
          'cpf': d['cpf']?.replaceAll(RegExp(r'\D'), ''),
          'gender': _mapGender(d['sexo']),
        }).toList(),
        'notes': 'LGPD: Email($_lgpdEmail), Social($_lgpdSocial), SMS($_lgpdSms)',
      };

      await _authDataSource.register(userData);

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
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0), // Reduced from 24
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Dados Pessoais',
            style: TextStyle(
              fontSize: 18, // Reduced from 20
              fontWeight: FontWeight.bold,
              color: AppColors.greenDark,
            ),
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.bgLight, thickness: 1),
          const SizedBox(height: 16),

          CustomTextField(
            label: 'Nome completo',
            hintText: 'Ex: Antonio Carlos',
            controller: _nameController,
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  label: 'CPF',
                  hintText: '000.000.000-00',
                  keyboardType: TextInputType.number,
                  inputFormatters: [_cpfFormatter],
                  controller: _cpfController,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomTextField(
                  label: 'RG',
                  hintText: '0.000.000',
                  keyboardType: TextInputType.number,
                  inputFormatters: [_rgFormatter],
                  controller: _rgController,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  label: 'Data de Nascimento',
                  hintText: 'DD/MM/AAAA',
                  keyboardType: TextInputType.number,
                  inputFormatters: [_dateFormatter],
                  controller: _birthDateController,
                  suffixIcon: const Icon(
                    Icons.calendar_today_outlined,
                    color: AppColors.textLight,
                    size: 18, // Reduced from 20
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomTextField(
                  label: 'Matrícula',
                  hintText: 'Digite a matrícula',
                  controller: _registrationNumberController,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: CustomDropdown(
                  label: 'Sexo',
                  hintText: 'Selecione', // Reduced hint text
                  items: const ['Masculino', 'Feminino', 'Outro', 'Não informado'],
                  value: _selectedGender,
                  onChanged: (val) => setState(() => _selectedGender = val),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomDropdown(
                  label: 'Estado Civil',
                  hintText: 'Selecione', // Reduced hint text
                  items: const [
                    'Solteiro',
                    'Casado',
                    'Divorciado',
                    'Viúvo',
                  ],
                  value: _selectedMaritalStatus,
                  onChanged: (val) => setState(() => _selectedMaritalStatus = val),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          CustomDropdown(
            label: 'Empresa na qual Trabalha',
            hintText: 'Selecione um campo',
            items: const ['Sicoob Banco', 'Sicoob Confederação', 'Outras'],
            value: _selectedCompany,
            onChanged: (val) => setState(() => _selectedCompany = val),
          ),
          const SizedBox(height: 24),

          Align(alignment: Alignment.centerRight, child: _buildNextButton()),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Endereço e Contatos',
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
            label: 'CEP',
            hintText: '00000-000',
            suffixIcon: const Icon(
              Icons.search,
              color: AppColors.textLight,
              size: 18,
            ), // Reduced icon size
            keyboardType: TextInputType.number,
            inputFormatters: [_cepFormatter],
            controller: _cepController,
          ),
          const SizedBox(height: 12),

          CustomTextField(
            label: 'Rua / Logradouro',
            hintText: 'Ex: Quadra F Santa Maria da Codipe',
            controller: _streetController,
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                flex: 1,
                child: CustomTextField(
                  label: 'Número',
                  hintText: 'Ex: 123',
                  controller: _addressNumberController,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: CustomTextField(
                  label: 'Complemento',
                  hintText: 'Ex: Casa A',
                  controller: _addressComplementController,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                flex: 1,
                child: CustomTextField(
                  label: 'Bairro',
                  hintText: 'Ex: Santa Maria',
                  controller: _districtController,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 1,
                child: CustomTextField(
                  label: 'Cidade',
                  hintText: 'Ex: Teresina',
                  controller: _cityController,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          CustomDropdown(
            label: 'Estado',
            hintText: 'Selecione o Estado',
            items: _states,
            value: _selectedState,
            onChanged: (val) => setState(() => _selectedState = val),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  label: 'Tel comercial',
                  hintText: '(00) 0000-0000',
                  keyboardType: TextInputType.phone,
                  inputFormatters: [_phoneFormatter],
                  controller: _businessPhoneController,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomTextField(
                  label: 'Tel celular',
                  hintText: '(00) 00000-0000',
                  keyboardType: TextInputType.phone,
                  inputFormatters: [_phoneFormatter],
                  controller: _mobilePhoneController,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          CustomTextField(
            label: 'Nome do Pai',
            hintText: 'Ex: Joaquim De Souza',
            controller: _fatherNameController,
          ),
          const SizedBox(height: 12),

          CustomTextField(
            label: 'Nome da Mãe',
            hintText: 'Ex: Maria Rosa',
            controller: _motherNameController,
          ),
          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [_buildPreviousButton(), _buildNextButton()],
          ),
        ],
      ),
    );
  }

  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Dependentes (Opcional)',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.greenDark,
            ),
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.bgLight, thickness: 1),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(16), // Reduced
            decoration: BoxDecoration(
              color: AppColors.bgLight.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CustomTextField(
                  label: 'Nome do Dependente',
                  hintText: 'Ex: Lucas Araujo',
                  controller: _depNameController,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        label: 'Data de Nascimento',
                        hintText: 'DD/MM/AAAA',
                        keyboardType: TextInputType.number,
                        inputFormatters: [_dependentDateFormatter],
                        controller: _depBirthDateController,
                        suffixIcon: const Icon(
                          Icons.calendar_today_outlined,
                          color: AppColors.textLight,
                          size: 18, // Reduced from 20
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomTextField(
                        label: 'CPF do Dependente',
                        hintText: '000.000.000-00',
                        keyboardType: TextInputType.number,
                        inputFormatters: [_dependentCpfFormatter],
                        controller: _depCpfController,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                CustomDropdown(
                  label: 'Sexo do Dependente',
                  hintText: 'Selecione', // Reduced hint text
                  items: const ['Masculino', 'Feminino', 'Outro'],
                  value: _depSelectedGender,
                  onChanged: (val) => setState(() => _depSelectedGender = val),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () {
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.greenDark,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20, // Reduced
                        vertical: 12, // Reduced
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Salvar Dependente',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ), // Reduced
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Display list of dependents
          if (_dependents.isNotEmpty)
            Container(
              decoration: BoxDecoration(
                color: AppColors.bgLight.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: const BoxDecoration(
                      color: AppColors.greenDark,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Nome',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Nascimento',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'CPF',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            'Ações',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ..._dependents.asMap().entries.map((entry) {
                    int idx = entry.key;
                    var dep = entry.value;
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: idx == _dependents.length - 1
                            ? const BorderRadius.vertical(
                                bottom: Radius.circular(12),
                              )
                            : BorderRadius.zero,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              dep['nome'] ?? '',
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              dep['nasc'] ?? '',
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              dep['cpf'] ?? '',
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                                size: 20,
                              ),
                              onPressed: () {
                                setState(() {
                                  _dependents.removeAt(idx);
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),

          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [_buildPreviousButton(), _buildNextButton()],
          ),
        ],
      ),
    );
  }

  Widget _buildStep4() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Acesso e Termos',
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
            label: 'E-mail Corporativo',
            hintText: 'Ex: antonio@email.com',
            keyboardType: TextInputType.emailAddress,
            controller: _emailController,
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  label: 'Senha',
                  hintText: 'Senha',
                  obscureText: true,
                  controller: _passwordController,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomTextField(
                  label: 'Confirme sua Senha',
                  hintText: 'Senha',
                  obscureText: true,
                  controller: _confirmPasswordController,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // LGPD
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FFF4), // Very light green
              border: Border.all(
                color: AppColors.greenLight.withValues(alpha: 0.3),
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Considerando o disposto na LGPD - LEI Nº 13.709, DE 14 DE AGOSTO DE 2018, favor preencher o campo abaixo:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.greenDark,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Autorizo que a Ascesa envie, para meu conhecimento, informações sobre a administração e gestão da Associação e campanhas promocionais relacionadas aos parceiros da Ascesa. Favor, escolha o(s) meio(s):',
                  style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                ),
                const SizedBox(height: 12),
                _buildCheckboxRow('Email', _lgpdEmail, (v) => setState(() => _lgpdEmail = v!)),
                _buildCheckboxRow('Mídias Sociais (Whatsapp e Facebook)', _lgpdSocial, (v) => setState(() => _lgpdSocial = v!)),
                _buildCheckboxRow('SMS', _lgpdSms, (v) => setState(() => _lgpdSms = v!)),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Confirmação
          const Text(
            'Confirmação',
            style: TextStyle(
              fontSize: 14, // Reduced from 16
              fontWeight: FontWeight.bold,
              color: AppColors.greenDark,
            ),
          ),
          const SizedBox(height: 12), // Reduced from 16
          Container(
            padding: const EdgeInsets.all(12), // Reduced from 16
            decoration: BoxDecoration(
              color: AppColors.bgLight.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 20, // Reduced from 24
                  height: 20, // Reduced from 24
                  child: Checkbox(
                    value: _termsConfirmed,
                    onChanged: (val) => setState(() => _termsConfirmed = val ?? false),
                    activeColor: AppColors.greenPrimary,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Confirmo a veracidade das informações acima e estou de acordo com a política de acesso e termos de uso da ASCESA e estou de acordo com a cobrança de R\$20 mensais.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ), // Reduced from 13
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildPreviousButton(),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitRegistration,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.greenDark,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32, // Reduced from 40
                    vertical: 12, // Reduced from 16
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: _isLoading 
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text(
                      'Salvar',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ), // Reduced from 16
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCheckboxRow(String label, bool value, ValueChanged<bool?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(
              value: value,
              onChanged: onChanged,
              activeColor: AppColors.greenPrimary,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildNextButton() {
    return ElevatedButton(
      onPressed: _nextStep,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.greenDark,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
          horizontal: 32,
          vertical: 12,
        ), // Reduced
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 0,
      ),
      child: const Text(
        'Próximo',
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold), // Reduced
      ),
    );
  }

  Widget _buildPreviousButton() {
    return TextButton(
      onPressed: _previousStep,
      style: TextButton.styleFrom(
        backgroundColor: AppColors.bgLight,
        foregroundColor: AppColors.greenDark,
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 12,
        ), // Reduced
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: const Text(
        'Anterior',
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold), // Reduced
      ),
    );
  }
}
