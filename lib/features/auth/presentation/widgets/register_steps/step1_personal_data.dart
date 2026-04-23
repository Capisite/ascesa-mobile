import 'dart:io';
import 'package:flutter/material.dart';
import 'package:ascesa/core/theme/app_colors.dart';
import 'package:ascesa/features/auth/presentation/widgets/custom_text_field.dart';
import 'package:ascesa/features/auth/presentation/widgets/custom_dropdown.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class Step1PersonalData extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController cpfController;
  final TextEditingController rgController;
  final TextEditingController birthDateController;
  final TextEditingController registrationNumberController;
  final TextEditingController companyNameController;
  final TextEditingController affiliatedCompanyNameController;

  final String? selectedGender;
  final ValueChanged<String?> onGenderChanged;

  final String? selectedMaritalStatus;
  final ValueChanged<String?> onMaritalStatusChanged;

  final String? companyRelationship;
  final ValueChanged<String?> onCompanyRelationshipChanged;

  final File? profilePhotoFile;
  final VoidCallback onPickProfilePhoto;

  final MaskTextInputFormatter cpfFormatter;
  final MaskTextInputFormatter rgFormatter;
  final MaskTextInputFormatter dateFormatter;

  final VoidCallback onNext;

  const Step1PersonalData({
    super.key,
    required this.nameController,
    required this.cpfController,
    required this.rgController,
    required this.birthDateController,
    required this.registrationNumberController,
    required this.companyNameController,
    required this.affiliatedCompanyNameController,
    required this.selectedGender,
    required this.onGenderChanged,
    required this.selectedMaritalStatus,
    required this.onMaritalStatusChanged,
    required this.companyRelationship,
    required this.onCompanyRelationshipChanged,
    required this.profilePhotoFile,
    required this.onPickProfilePhoto,
    required this.cpfFormatter,
    required this.rgFormatter,
    required this.dateFormatter,
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
            'Dados Pessoais',
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
            label: 'Nome completo',
            hintText: 'Ex: Antonio Carlos',
            controller: nameController,
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  label: 'CPF',
                  hintText: '000.000.000-00',
                  keyboardType: TextInputType.number,
                  inputFormatters: [cpfFormatter],
                  controller: cpfController,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomTextField(
                  label: 'RG',
                  hintText: '0.000.000',
                  keyboardType: TextInputType.number,
                  inputFormatters: [rgFormatter],
                  controller: rgController,
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
                  inputFormatters: [dateFormatter],
                  controller: birthDateController,
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
                  label: 'Matrícula',
                  hintText: 'Digite a matrícula',
                  controller: registrationNumberController,
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
                  hintText: 'Selecione',
                  items: const ['Masculino', 'Feminino', 'Outro', 'Não informado'],
                  value: selectedGender,
                  onChanged: onGenderChanged,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomDropdown(
                  label: 'Estado Civil',
                  hintText: 'Selecione',
                  items: const [
                    'Solteiro(a)',
                    'Casado(a)',
                    'Divorciado(a)',
                    'Viúvo(a)',
                    'Separado(a)',
                    'União estável',
                  ],
                  value: selectedMaritalStatus,
                  onChanged: onMaritalStatusChanged,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          CustomDropdown(
            label: 'Vinculo com a cooperativa',
            hintText: 'Selecione',
            items: const ['Funcionario da cooperativa', 'Filiado'],
            value: companyRelationship == 'COOPERATIVE_EMPLOYEE' ? 'Funcionario da cooperativa' : (companyRelationship == 'AFFILIATED_MEMBER' ? 'Filiado' : null),
            onChanged: (val) {
              onCompanyRelationshipChanged(val == 'Funcionario da cooperativa' ? 'COOPERATIVE_EMPLOYEE' : 'AFFILIATED_MEMBER');
            },
          ),
          const SizedBox(height: 12),

          if (companyRelationship == 'COOPERATIVE_EMPLOYEE') ...[
            CustomTextField(
              label: 'Empresa na qual trabalha',
              hintText: 'Digite o nome da empresa',
              controller: companyNameController,
            ),
            const SizedBox(height: 12),
          ],

          if (companyRelationship == 'AFFILIATED_MEMBER') ...[
            CustomTextField(
              label: 'Filiado em qual empresa',
              hintText: 'Digite o nome da empresa',
              controller: affiliatedCompanyNameController,
            ),
            const SizedBox(height: 12),
          ],

          const SizedBox(height: 12),
          const Text(
            'Foto de perfil (opcional)',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.greenDark,
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: onPickProfilePhoto,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.camera_alt_outlined, color: AppColors.textLight),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      profilePhotoFile != null ? profilePhotoFile!.path.split('/').last : 'Selecione uma imagem (JPG, PNG)',
                      style: TextStyle(color: profilePhotoFile != null ? AppColors.greenDark : AppColors.textLight, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          Align(
            alignment: Alignment.centerRight, 
            child: ElevatedButton(
              onPressed: onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.greenDark,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              child: const Text(
                'Próximo',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
