import 'package:flutter/material.dart';
import 'package:flutter_project/core/theme/app_colors.dart';
import 'package:flutter_project/features/auth/presentation/widgets/custom_text_field.dart';
import 'package:flutter_project/features/auth/presentation/widgets/custom_dropdown.dart';
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

  final _cpfFormatter = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: {"#": RegExp(r'[0-9]')},
  );
  final _dateFormatter = MaskTextInputFormatter(
    mask: '##/##/####',
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

          const CustomTextField(
            label: 'Nome completo',
            hintText: 'Ex: Antonio Carlos',
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
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: const CustomTextField(
                  label: 'RG',
                  hintText: 'Digite o RG',
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
                  suffixIcon: const Icon(
                    Icons.calendar_today_outlined,
                    color: AppColors.textLight,
                    size: 18, // Reduced from 20
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: const CustomTextField(
                  label: 'Matrícula',
                  hintText: 'Digite a matrícula',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: const CustomDropdown(
                  label: 'Sexo',
                  hintText: 'Selecione', // Reduced hint text
                  items: ['Masculino', 'Feminino', 'Outro'],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: const CustomDropdown(
                  label: 'Estado Civil',
                  hintText: 'Selecione', // Reduced hint text
                  items: [
                    'Solteiro(a)',
                    'Casado(a)',
                    'Divorciado(a)',
                    'Viúvo(a)',
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          const CustomDropdown(
            label: 'Empresa na qual Trabalha',
            hintText: 'Selecione um campo',
            items: ['Empresa 1', 'Empresa 2'],
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
          ),
          const SizedBox(height: 12),

          const CustomTextField(
            label: 'Endereço completo (logradouro, número e complemento)',
            hintText: 'Ex: Quadra F Santa Maria da Codipe Teresina',
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
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomTextField(
                  label: 'Tel celular',
                  hintText: '(00) 00000-0000',
                  keyboardType: TextInputType.phone,
                  inputFormatters: [_phoneFormatter],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          const CustomTextField(
            label: 'Nome do Pai',
            hintText: 'Ex: Joaquim De Souza',
          ),
          const SizedBox(height: 12),

          const CustomTextField(
            label: 'Nome da Mãe',
            hintText: 'Ex: Maria Rosa',
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

  final List<Map<String, String>> _dependents =
      []; // Lista para armazenar dependentes

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
                const CustomTextField(
                  label: 'Nome do Dependente',
                  hintText: 'Ex: Lucas Soares',
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
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const CustomDropdown(
                  label: 'Sexo do Dependente',
                  hintText: 'Selecione', // Reduced hint text
                  items: ['Masculino', 'Feminino', 'Outro'],
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _dependents.add({
                          'nome': 'Lucas Teste',
                          'nasc': '2000-01-01',
                          'cpf': '111.222.333-44',
                        });
                      });
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

          const CustomTextField(
            label: 'E-mail corporativo',
            hintText: 'Ex: antonio@email.com',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: const CustomTextField(
                  label: 'Senha',
                  hintText: 'Senha',
                  obscureText: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: const CustomTextField(
                  label: 'Confirme sua Senha',
                  hintText: 'Senha',
                  obscureText: true,
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
                _buildCheckboxRow('Email'),
                _buildCheckboxRow('Mídias Sociais (Whatsapp e Facebook)'),
                _buildCheckboxRow('SMS'),
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
                    value: false,
                    onChanged: (val) {},
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
                onPressed: () {
                  // Finish registration
                },
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
                child: const Text(
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

  Widget _buildCheckboxRow(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(
              value: false,
              onChanged: (val) {},
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
