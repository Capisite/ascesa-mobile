import 'package:flutter/material.dart';
import 'package:ascesa/core/theme/app_colors.dart';
import 'package:ascesa/features/member_area/data/datasources/dependents_remote_data_source.dart';
import 'package:intl/intl.dart';

class DependentsPage extends StatefulWidget {
  final String token;
  const DependentsPage({super.key, required this.token});

  @override
  State<DependentsPage> createState() => _DependentsPageState();
}

class DependentFormState {
  final String id;
  final TextEditingController nameController;
  final TextEditingController cpfController;
  DateTime? birthDate;
  String gender;
  String status;
  bool isEditing;

  DependentFormState({
    required this.id,
    String initialName = '',
    String initialCpf = '',
    this.birthDate,
    this.gender = 'NOT_INFORMED',
    this.status = 'PENDING',
    this.isEditing = false,
  })  : nameController = TextEditingController(text: initialName),
        cpfController = TextEditingController(text: initialCpf);

  void dispose() {
    nameController.dispose();
    cpfController.dispose();
  }
}

class _DependentsPageState extends State<DependentsPage> {
  final List<DependentFormState> _dependents = [];
  late final DependentsRemoteDataSource _dataSource;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _dataSource = DependentsRemoteDataSource(token: widget.token);
    _fetchDependents();
  }

  Future<void> _fetchDependents() async {
    setState(() => _isLoading = true);
    try {
      final data = await _dataSource.getDependents();
      setState(() {
        for (var d in _dependents) {
          d.dispose();
        }
        _dependents.clear();

        for (var json in data) {
          _dependents.add(DependentFormState(
            id: json['id'],
            initialName: json['name'] ?? '',
            initialCpf: json['cpf'] ?? '',
            birthDate: json['birthDate'] != null ? DateTime.parse(json['birthDate']) : null,
            gender: json['gender'] ?? 'NOT_INFORMED',
            status: json['status'] ?? 'PENDING',
          ));
        }
      });
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
  void dispose() {
    for (var d in _dependents) {
      d.dispose();
    }
    super.dispose();
  }

  void _addDependent() {
    setState(() {
      _dependents.add(DependentFormState(
        id: 'TEMP_${UniqueKey().toString()}',
        isEditing: true,
      ));
    });
  }

  Future<void> _removeDependent(String id) async {
    // If it's a temp dependent, just remove it from the list
    if (id.startsWith('TEMP_')) {
      setState(() {
        final index = _dependents.indexWhere((d) => d.id == id);
        if (index != -1) {
          _dependents[index].dispose();
          _dependents.removeAt(index);
        }
      });
      return;
    }

    // If it has a real ID, delete from backend
    try {
      setState(() => _isLoading = true);
      await _dataSource.deleteDependent(id);
      setState(() {
        final index = _dependents.indexWhere((d) => d.id == id);
        if (index != -1) {
          _dependents[index].dispose();
          _dependents.removeAt(index);
        }
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dependente removido com sucesso.'), backgroundColor: AppColors.greenPrimary),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao remover: ${e.toString().replaceAll('Exception: ', '')}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveChanges() async {
    setState(() => _isLoading = true);

    try {
      for (var dependent in _dependents) {
        if (dependent.nameController.text.isEmpty || dependent.cpfController.text.isEmpty || dependent.birthDate == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Por favor, preencha todos os campos obrigatórios.')),
          );
          setState(() => _isLoading = false);
          return;
        }

        final data = {
          'name': dependent.nameController.text,
          'cpf': dependent.cpfController.text,
          'birthDate': dependent.birthDate!.toIso8601String(),
          'gender': dependent.gender,
        };

        if (dependent.id.startsWith('TEMP_')) {
          await _dataSource.createDependent(data);
        } else {
          await _dataSource.updateDependent(dependent.id, data);
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dependentes salvos com sucesso!'),
            backgroundColor: AppColors.greenPrimary,
          ),
        );
        for (var d in _dependents) {
          d.isEditing = false;
        }
        // Refresh to get real IDs for TEMP dependents
        await _fetchDependents();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar: ${e.toString().replaceAll('Exception: ', '')}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FBF8),
        border: Border.all(color: const Color(0xFFDCE6DF)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dependentes',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF163320),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Gerencie os dependentes atrelados à sua conta.',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF5B6B61),
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: _addDependent,
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Adicionar dependente'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.greenDark,
                side: const BorderSide(color: AppColors.greenDark),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDependentCard(DependentFormState dependent, int index) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dependent.nameController.text.isNotEmpty
                        ? dependent.nameController.text
                        : 'Dependente ${index + 1}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.greenDark,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Informações do dependente',
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 8),
                  _buildStatusBadge(dependent.status),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!dependent.isEditing)
                    IconButton(
                      onPressed: () => setState(() => dependent.isEditing = true),
                      icon: const Icon(Icons.edit_outlined,
                          color: AppColors.greenDark, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () => _removeDependent(dependent.id),
                    icon: const Icon(Icons.delete_outline,
                        color: Colors.redAccent, size: 20),
                    label: const Text(
                      'Remover',
                      style: TextStyle(color: Colors.redAccent, fontSize: 13),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (dependent.isEditing) ...[
            _buildInlineTextField(
              label: 'Nome completo',
              controller: dependent.nameController,
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 12),
            _buildInlineTextField(
              label: 'CPF',
              controller: dependent.cpfController,
              icon: Icons.badge_outlined,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            // Data de nascimento
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: dependent.birthDate ?? DateTime.now(),
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
                  setState(() {
                    dependent.birthDate = date;
                  });
                }
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        color: AppColors.textLight, size: 22),
                    const SizedBox(width: 12),
                    Text(
                      dependent.birthDate == null
                          ? 'Data de nascimento'
                          : DateFormat('dd/MM/yyyy')
                              .format(dependent.birthDate!),
                      style: TextStyle(
                        color: dependent.birthDate == null
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
            // Gênero
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: dependent.gender,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down,
                      color: AppColors.textLight),
                  items: const [
                    DropdownMenuItem(
                        value: 'NOT_INFORMED', child: Text('Não informado')),
                    DropdownMenuItem(value: 'MALE', child: Text('Masculino')),
                    DropdownMenuItem(value: 'FEMALE', child: Text('Feminino')),
                    DropdownMenuItem(value: 'OTHER', child: Text('Outro')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        dependent.gender = value;
                      });
                    }
                  },
                ),
              ),
            ),
          ] else ...[
            _buildDataField(
              label: 'Nome completo',
              value: dependent.nameController.text,
              icon: Icons.person_outline,
            ),
            _buildDataField(
              label: 'CPF',
              value: dependent.cpfController.text,
              icon: Icons.badge_outlined,
            ),
            _buildDataField(
              label: 'Data de nascimento',
              value: dependent.birthDate == null
                  ? 'Não informada'
                  : DateFormat('dd/MM/yyyy').format(dependent.birthDate!),
              icon: Icons.calendar_today_outlined,
            ),
            _buildDataField(
              label: 'Gênero',
              value: _getGenderLabel(dependent.gender),
              icon: Icons.person_search_outlined,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInlineTextField({
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
        prefixIcon: Icon(icon, color: AppColors.textLight, size: 22),
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

  Widget _buildDataField({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.greenPrimary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.greenPrimary, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
              ),
              Text(
                value.isEmpty ? 'Não informado' : value,
                style: const TextStyle(
                  color: AppColors.greenDark,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getGenderLabel(String gender) {
    switch (gender) {
      case 'MALE':
        return 'Masculino';
      case 'FEMALE':
        return 'Feminino';
      case 'OTHER':
        return 'Outro';
      default:
        return 'Não informado';
    }
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String label;

    switch (status) {
      case 'ACTIVE':
        color = AppColors.greenPrimary;
        label = 'ATIVO';
        break;
      case 'REJECTED':
        color = Colors.redAccent;
        label = 'REJEITADO';
        break;
      case 'PENDING':
      default:
        color = Colors.orangeAccent;
        label = 'EM ANÁLISE';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
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
      body: _isLoading && _dependents.isEmpty
          ? const Center(child: CircularProgressIndicator(color: AppColors.greenPrimary))
          : RefreshIndicator(
              onRefresh: _fetchDependents,
              color: AppColors.greenPrimary,
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(24),
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 24),
                        if (_dependents.isEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.border, style: BorderStyle.solid),
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              'Nenhum dependente adicionado. Puxe para baixo para atualizar.',
                              style: TextStyle(color: AppColors.textMuted, fontSize: 14),
                              textAlign: TextAlign.center,
                            ),
                          )
                        else
                          ..._dependents.asMap().entries.map((entry) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _buildDependentCard(entry.value, entry.key),
                            );
                          }),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveChanges,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.greenDark,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                          disabledBackgroundColor: AppColors.greenDark.withValues(alpha: 0.5),
                        ),
                        child: _isLoading && _dependents.isNotEmpty
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2),
                              )
                            : const Text(
                                'Salvar alterações',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
