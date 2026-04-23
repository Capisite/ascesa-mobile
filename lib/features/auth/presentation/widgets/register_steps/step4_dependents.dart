import 'package:flutter/material.dart';
import 'package:ascesa/core/theme/app_colors.dart';
import 'package:ascesa/features/auth/presentation/widgets/custom_text_field.dart';
import 'package:ascesa/features/auth/presentation/widgets/custom_dropdown.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class Step4Dependents extends StatelessWidget {
  final TextEditingController depNameController;
  final TextEditingController depBirthDateController;
  final TextEditingController depCpfController;
  
  final String? depSelectedGender;
  final ValueChanged<String?> onDepGenderChanged;

  final List<Map<String, String>> dependents;
  final VoidCallback onAddDependent;
  final ValueChanged<int> onRemoveDependent;

  final MaskTextInputFormatter dependentDateFormatter;
  final MaskTextInputFormatter dependentCpfFormatter;

  final bool isLoading;
  final VoidCallback onPrevious;
  final VoidCallback onSubmit;

  const Step4Dependents({
    super.key,
    required this.depNameController,
    required this.depBirthDateController,
    required this.depCpfController,
    required this.depSelectedGender,
    required this.onDepGenderChanged,
    required this.dependents,
    required this.onAddDependent,
    required this.onRemoveDependent,
    required this.dependentDateFormatter,
    required this.dependentCpfFormatter,
    required this.isLoading,
    required this.onPrevious,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
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
            padding: const EdgeInsets.all(16),
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
                  controller: depNameController,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        label: 'Data de Nascimento',
                        hintText: 'DD/MM/AAAA',
                        keyboardType: TextInputType.number,
                        inputFormatters: [dependentDateFormatter],
                        controller: depBirthDateController,
                        suffixIcon: const Icon(
                          Icons.calendar_today_outlined,
                          color: AppColors.textLight,
                          size: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomTextField(
                        label: 'CPF do Dependente',
                        hintText: '000.000.000-00',
                        keyboardType: TextInputType.number,
                        inputFormatters: [dependentCpfFormatter],
                        controller: depCpfController,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                CustomDropdown(
                  label: 'Sexo do Dependente',
                  hintText: 'Selecione',
                  items: const ['Masculino', 'Feminino', 'Outro'],
                  value: depSelectedGender,
                  onChanged: onDepGenderChanged,
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: onAddDependent,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.greenDark,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
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
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          if (dependents.isNotEmpty)
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
                  ...dependents.asMap().entries.map((entry) {
                    int idx = entry.key;
                    var dep = entry.value;
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: idx == dependents.length - 1
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
                              onPressed: () => onRemoveDependent(idx),
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
                onPressed: isLoading ? null : onSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.greenDark,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: isLoading 
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text(
                      'Enviar cadastro',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
