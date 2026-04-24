import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:ascesa/core/theme/app_colors.dart';
import 'package:ascesa/features/member_area/presentation/controllers/user_profile_controller.dart';
import 'package:image_picker/image_picker.dart';

class UserProfilePage extends StatefulWidget {
  final UserProfileController controller;

  const UserProfilePage({super.key, required this.controller});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final _formKey = GlobalKey<FormState>();

  // Informações pessoais
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _mobilePhoneController;
  late TextEditingController _businessPhoneController;

  // Filiação
  late TextEditingController _fatherNameController;
  late TextEditingController _motherNameController;

  // Endereço
  late TextEditingController _zipCodeController;
  late TextEditingController _streetController;
  late TextEditingController _addressNumberController;
  late TextEditingController _addressComplementController;
  late TextEditingController _districtController;
  late TextEditingController _cityController;
  String? _selectedState;

  final List<String> _states = const [
    'AC', 'AL', 'AP', 'AM', 'BA', 'CE', 'DF', 'ES', 'GO', 'MA',
    'MT', 'MS', 'MG', 'PA', 'PB', 'PR', 'PE', 'PI', 'RJ', 'RN',
    'RS', 'RO', 'RR', 'SC', 'SP', 'SE', 'TO'
  ];

  final _phoneFormatter = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {"#": RegExp(r'[0-9]')},
  );
  final _phoneFormatterBusiness = MaskTextInputFormatter(
    mask: '(##) ####-####',
    filter: {"#": RegExp(r'[0-9]')},
  );
  final _cepFormatter = MaskTextInputFormatter(
    mask: '#####-###',
    filter: {"#": RegExp(r'[0-9]')},
  );

  @override
  void initState() {
    super.initState();
    _initControllers(widget.controller.user);
    // Ouve o controller: quando fetchProfile terminar, atualiza os campos
    widget.controller.addListener(_onUserUpdated);
  }

  void _initControllers(user) {
    _nameController = TextEditingController(text: user.name);
    _emailController = TextEditingController(text: user.email);
    _mobilePhoneController = TextEditingController(text: user.mobilePhone ?? user.phone ?? '');
    _businessPhoneController = TextEditingController(text: user.businessPhone ?? '');
    _fatherNameController = TextEditingController(text: user.fatherName ?? '');
    _motherNameController = TextEditingController(text: user.motherName ?? '');
    _zipCodeController = TextEditingController(text: user.zipCode ?? '');
    _streetController = TextEditingController(text: user.street ?? '');
    _addressNumberController = TextEditingController(text: user.addressNumber ?? '');
    _addressComplementController = TextEditingController(text: user.addressComplement ?? '');
    _districtController = TextEditingController(text: user.district ?? '');
    _cityController = TextEditingController(text: user.city ?? '');
    _selectedState = _validState(user.state);
  }

  /// Retorna o estado somente se for um UF válido da lista, caso contrário null.
  String? _validState(String? state) {
    if (state == null) return null;
    final upper = state.toUpperCase();
    return _states.contains(upper) ? upper : null;
  }

  void _onUserUpdated() {
    // Só atualiza os campos se não estiver carregando mais (fetch concluído)
    if (!widget.controller.isLoading) {
      final user = widget.controller.user;
      _nameController.text = user.name;
      _emailController.text = user.email;
      _mobilePhoneController.text = user.mobilePhone ?? user.phone ?? '';
      _businessPhoneController.text = user.businessPhone ?? '';
      _fatherNameController.text = user.fatherName ?? '';
      _motherNameController.text = user.motherName ?? '';
      _zipCodeController.text = user.zipCode ?? '';
      _streetController.text = user.street ?? '';
      _addressNumberController.text = user.addressNumber ?? '';
      _addressComplementController.text = user.addressComplement ?? '';
      _districtController.text = user.district ?? '';
      _cityController.text = user.city ?? '';
      if (mounted) setState(() => _selectedState = _validState(user.state));
    }
  }


  @override
  void dispose() {
    widget.controller.removeListener(_onUserUpdated);
    _nameController.dispose();
    _emailController.dispose();
    _mobilePhoneController.dispose();
    _businessPhoneController.dispose();
    _fatherNameController.dispose();
    _motherNameController.dispose();
    _zipCodeController.dispose();
    _streetController.dispose();
    _addressNumberController.dispose();
    _addressComplementController.dispose();
    _districtController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  void _handleSave() async {
    if (_formKey.currentState!.validate()) {
      await widget.controller.updateProfile(
        name: _nameController.text,
        email: _emailController.text,
        mobilePhone: _mobilePhoneController.text.replaceAll(RegExp(r'\D'), ''),
        businessPhone: _businessPhoneController.text.replaceAll(RegExp(r'\D'), ''),
        fatherName: _fatherNameController.text,
        motherName: _motherNameController.text,
        zipCode: _zipCodeController.text.replaceAll(RegExp(r'\D'), ''),
        street: _streetController.text,
        addressNumber: _addressNumberController.text,
        addressComplement: _addressComplementController.text,
        district: _districtController.text,
        city: _cityController.text,
        state: _selectedState,
      );

      if (mounted) {
        if (widget.controller.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.controller.errorMessage!),
              backgroundColor: Colors.red,
            ),
          );
        } else if (widget.controller.successMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.controller.successMessage!),
              backgroundColor: AppColors.greenPrimary,
            ),
          );
        }
      }
    }
  }

  void _handlePhotoEdit() async {
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Alterar Foto de Perfil',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.greenDark),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppColors.greenPrimary),
              title: const Text('Galeria'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.greenPrimary),
              title: const Text('Câmera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (source != null) {
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );

      if (image != null) {
        await widget.controller.updateProfilePhoto(image.path);
        
        if (mounted) {
          if (widget.controller.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(widget.controller.errorMessage!), backgroundColor: Colors.red),
            );
          } else if (widget.controller.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(widget.controller.successMessage!), backgroundColor: AppColors.greenPrimary),
            );
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final isLoading = widget.controller.isLoading;

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
              'Perfil do Usuário',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.greenDark,
              ),
            ),
          ),
          body: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Photo Section
                      Center(
                        child: GestureDetector(
                          onTap: isLoading ? null : _handlePhotoEdit,
                          child: Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.greenPrimary, width: 2),
                                ),
                                child: CircleAvatar(
                                  radius: 50,
                                  backgroundColor: AppColors.bgLight,
                                  backgroundImage: widget.controller.user.profilePhotoUrl != null
                                      ? NetworkImage(widget.controller.user.profilePhotoUrl!)
                                      : null,
                                  child: widget.controller.user.profilePhotoUrl == null
                                      ? const Icon(Icons.person, size: 50, color: AppColors.textLight)
                                      : null,
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: AppColors.greenPrimary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.edit, color: Colors.white, size: 20),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // ── Informações Pessoais ──
                      _buildSectionTitle('Informações Pessoais'),
                      _buildTextField(
                        label: 'Nome completo',
                        controller: _nameController,
                        icon: Icons.person_outline,
                        validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
                      ),
                      _buildTextField(
                        label: 'E-mail',
                        controller: _emailController,
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              label: 'Tel. Celular',
                              controller: _mobilePhoneController,
                              icon: Icons.phone_android_outlined,
                              keyboardType: TextInputType.phone,
                              inputFormatters: [_phoneFormatter],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTextField(
                              label: 'Tel. Comercial',
                              controller: _businessPhoneController,
                              icon: Icons.phone_outlined,
                              keyboardType: TextInputType.phone,
                              inputFormatters: [_phoneFormatterBusiness],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),
                      // ── Documentos (bloqueados) ──
                      _buildSectionTitle('Documentos'),
                      _buildLockedField(
                        label: 'CPF',
                        value: '***.***.***-**',
                        icon: Icons.badge_outlined,
                      ),
                      _buildLockedField(
                        label: 'RG',
                        value: '**.***.***-*',
                        icon: Icons.card_membership_outlined,
                      ),

                      const SizedBox(height: 8),
                      // ── Filiação ──
                      _buildSectionTitle('Filiação'),
                      _buildTextField(
                        label: 'Nome do Pai',
                        controller: _fatherNameController,
                        icon: Icons.man_outlined,
                      ),
                      _buildTextField(
                        label: 'Nome da Mãe',
                        controller: _motherNameController,
                        icon: Icons.woman_outlined,
                      ),

                      const SizedBox(height: 8),
                      // ── Endereço ──
                      _buildSectionTitle('Endereço'),
                      _buildTextField(
                        label: 'CEP',
                        controller: _zipCodeController,
                        icon: Icons.location_on_outlined,
                        keyboardType: TextInputType.number,
                        inputFormatters: [_cepFormatter],
                      ),
                      _buildTextField(
                        label: 'Rua / Logradouro',
                        controller: _streetController,
                        icon: Icons.signpost_outlined,
                      ),
                      Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: _buildTextField(
                              label: 'Número',
                              controller: _addressNumberController,
                              icon: Icons.house_outlined,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: _buildTextField(
                              label: 'Complemento',
                              controller: _addressComplementController,
                              icon: Icons.add_road_outlined,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              label: 'Bairro',
                              controller: _districtController,
                              icon: Icons.holiday_village_outlined,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTextField(
                              label: 'Cidade',
                              controller: _cityController,
                              icon: Icons.location_city_outlined,
                            ),
                          ),
                        ],
                      ),
                      // Estado dropdown
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: DropdownButtonFormField<String>(
                          initialValue: _selectedState,
                          decoration: InputDecoration(
                            labelText: 'Estado',
                            labelStyle: const TextStyle(color: AppColors.textMuted),
                            prefixIcon: const Icon(Icons.map_outlined, color: AppColors.greenPrimary, size: 22),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.greenPrimary, width: 2)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          ),
                          items: _states.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                          onChanged: (val) => setState(() => _selectedState = val),
                          style: const TextStyle(fontSize: 15, color: AppColors.greenDark),
                        ),
                      ),

                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _handleSave,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.greenPrimary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ).copyWith(
                            backgroundColor: WidgetStateProperty.resolveWith((states) {
                              if (states.contains(WidgetState.disabled)) return AppColors.textLight;
                              return AppColors.greenPrimary;
                            }),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : const Text(
                                  'Salvar Alterações',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
              if (isLoading)
                Container(
                  color: Colors.black.withValues(alpha: 0.1),
                  child: const Center(
                    child: CircularProgressIndicator(color: AppColors.greenPrimary),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0, top: 8.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.greenDark,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    List<dynamic>? inputFormatters,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        inputFormatters: inputFormatters != null
            ? inputFormatters.cast()
            : null,
        style: const TextStyle(fontSize: 15, color: AppColors.greenDark),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.textMuted),
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
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildLockedField({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.bgLight.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textLight, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.textMuted.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.lock_outline, color: AppColors.textLight, size: 18),
          ],
        ),
      ),
    );
  }
}

