import 'package:flutter/material.dart';
import 'package:ascesa/core/theme/app_colors.dart';
import 'package:ascesa/features/auth/presentation/widgets/custom_text_field.dart';
import 'package:ascesa/features/auth/presentation/widgets/custom_dropdown.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class Step3AddressFiliation extends StatelessWidget {
  final TextEditingController cepController;
  final TextEditingController addressNumberController;
  final TextEditingController streetController;
  final TextEditingController districtController;
  final TextEditingController addressComplementController;
  final TextEditingController cityController;
  final TextEditingController fatherNameController;
  final TextEditingController motherNameController;

  final String? selectedState;
  final ValueChanged<String?> onStateChanged;
  final VoidCallback onSearchCep;

  final MaskTextInputFormatter cepFormatter;
  final List<String> states;

  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const Step3AddressFiliation({
    super.key,
    required this.cepController,
    required this.addressNumberController,
    required this.streetController,
    required this.districtController,
    required this.addressComplementController,
    required this.cityController,
    required this.fatherNameController,
    required this.motherNameController,
    required this.selectedState,
    required this.onStateChanged,
    required this.onSearchCep,
    required this.cepFormatter,
    required this.states,
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
            'Endereço e filiação',
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
            suffixIcon: IconButton(
              icon: const Icon(
                Icons.search,
                color: AppColors.textLight,
                size: 18,
              ),
              onPressed: onSearchCep,
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [cepFormatter],
            controller: cepController,
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                flex: 1,
                child: CustomTextField(
                  label: 'Número',
                  hintText: 'Ex: 123',
                  controller: addressNumberController,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: CustomTextField(
                  label: 'Rua / Logradouro',
                  hintText: 'Ex: Quadra F',
                  controller: streetController,
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
                  controller: districtController,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 1,
                child: CustomTextField(
                  label: 'Complemento',
                  hintText: 'Ex: Casa A',
                  controller: addressComplementController,
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
                  label: 'Cidade',
                  hintText: 'Ex: Teresina',
                  controller: cityController,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 1,
                child: CustomDropdown(
                  label: 'Estado',
                  hintText: 'UF',
                  items: states,
                  value: selectedState,
                  onChanged: onStateChanged,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  label: 'Nome do Pai',
                  hintText: 'Ex: Joaquim',
                  controller: fatherNameController,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomTextField(
                  label: 'Nome da Mãe',
                  hintText: 'Ex: Maria',
                  controller: motherNameController,
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
