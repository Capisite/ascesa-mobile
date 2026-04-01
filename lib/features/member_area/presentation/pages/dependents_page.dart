import 'package:flutter/material.dart';
import 'package:ascesa/core/theme/app_colors.dart';
import 'package:intl/intl.dart';

class DependentsPage extends StatefulWidget {
  const DependentsPage({super.key});

  @override
  State<DependentsPage> createState() => _DependentsPageState();
}

class _DependentsPageState extends State<DependentsPage> {
  // Mock data for dependents
  final List<Map<String, String>> _dependents = [
    {
      'name': 'Enzo Silva',
      'birthDate': '2015-05-12',
      'cpf': '111.222.333-44',
      'gender': 'MALE',
    },
    {
      'name': 'Valentina Silva',
      'birthDate': '2018-09-20',
      'cpf': '555.666.777-88',
      'gender': 'FEMALE',
    },
  ];

  void _addDependent(Map<String, String> newDependent) {
    setState(() {
      _dependents.add(newDependent);
    });
  }

  void _showAddDependentDialog() {
    final nameController = TextEditingController();
    final cpfController = TextEditingController();
    DateTime? selectedDate;
    String? selectedGender = 'NOT_INFORMED';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Novo Dependente',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.greenDark,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: AppColors.textLight),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildModalTextField(
                label: 'Nome Completo',
                controller: nameController,
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 12),
              _buildModalTextField(
                label: 'CPF',
                controller: cpfController,
                icon: Icons.badge_outlined,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              // Birth Date Picker
              InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.light(
                            primary: AppColors.greenPrimary,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (date != null) {
                    setModalState(() {
                      selectedDate = date;
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined,
                          color: AppColors.greenPrimary, size: 22),
                      const SizedBox(width: 12),
                      Text(
                        selectedDate == null
                            ? 'Data de Nascimento'
                            : DateFormat('dd/MM/yyyy').format(selectedDate!),
                        style: TextStyle(
                          color: selectedDate == null
                              ? AppColors.textLight
                              : AppColors.greenDark,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Gender Dropdown
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedGender,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down,
                        color: AppColors.textLight),
                    items: const [
                      DropdownMenuItem(
                          value: 'NOT_INFORMED', child: Text('Gênero')),
                      DropdownMenuItem(value: 'MALE', child: Text('Masculino')),
                      DropdownMenuItem(value: 'FEMALE', child: Text('Feminino')),
                      DropdownMenuItem(value: 'OTHER', child: Text('Outro')),
                    ],
                    onChanged: (value) {
                      setModalState(() {
                        selectedGender = value;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    if (nameController.text.isNotEmpty &&
                        selectedDate != null &&
                        cpfController.text.isNotEmpty) {
                      _addDependent({
                        'name': nameController.text,
                        'birthDate': selectedDate!.toIso8601String(),
                        'cpf': cpfController.text,
                        'gender': selectedGender!,
                      });
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.greenPrimary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Adicionar',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModalTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textLight, fontSize: 14),
        prefixIcon: Icon(icon, color: AppColors.greenPrimary, size: 22),
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
          borderSide: const BorderSide(color: AppColors.greenPrimary, width: 2),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.greenDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Dependentes',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.greenDark,
          ),
        ),
      ),
      body: _dependents.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline,
                      size: 64, color: AppColors.textLight.withValues(alpha: 0.5)),
                  const SizedBox(height: 16),
                  const Text(
                    'Nenhum dependente encontrado.',
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              itemCount: _dependents.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final dependent = _dependents[index];
                return _buildDependentCard(dependent);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDependentDialog,
        backgroundColor: AppColors.greenPrimary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildDependentCard(Map<String, String> dependent) {
    final birthDate = DateTime.parse(dependent['birthDate']!);
    final formattedDate = DateFormat('dd/MM/yyyy').format(birthDate);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.greenPrimary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.person, color: AppColors.greenPrimary, size: 24),
        ),
        title: Text(
          dependent['name']!,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.greenDark,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Nascimento: $formattedDate',
              style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
            ),
            Text(
              'CPF: ${dependent['cpf']}',
              style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textLight),
      ),
    );
  }
}
