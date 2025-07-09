import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../data/models/cliente_model.dart';
import '../../../data/services/cliente_service.dart';

class ClienteFormScreen extends StatefulWidget {
  final ClienteModel? cliente;
  final bool isEditing;

  const ClienteFormScreen({super.key, this.cliente, this.isEditing = false});

  @override
  State<ClienteFormScreen> createState() => _ClienteFormScreenState();
}

class _ClienteFormScreenState extends State<ClienteFormScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final ClienteService _clienteService = ClienteService();

  // Controllers
  final _nombresController = TextEditingController();
  final _apellidosController = TextEditingController();
  final _nroDocumentoController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _emailController = TextEditingController();
  final _direccionController = TextEditingController();

  String _selectedEstado = 'activo';
  bool _isLoading = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Declara los tipos de documento permitidos
  final List<String> _tiposDocumento = ['DNI', 'CE'];
  String? _selectedTipoDocumento;


  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeForm();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward();
  }

  void _initializeForm() {
    if (widget.cliente != null) {
      final cliente = widget.cliente!;
      _nombresController.text = cliente.nombres;
      _apellidosController.text = cliente.apellidos;
      _selectedTipoDocumento = cliente.tipoDocumento;
      _nroDocumentoController.text = cliente.nroDocumento;
      _telefonoController.text = cliente.telefono ?? '';
      _emailController.text = cliente.email ?? '';
      _direccionController.text = cliente.direccion ?? '';
      // Normaliza el estado para el dropdown (solo para editar, pero ya no se usará en el form)
      _selectedEstado = (cliente.estado.toUpperCase() == 'A')
          ? 'activo'
          : 'inactivo';
    } else {
      // Nuevo cliente: por defecto 'activo'
      _selectedEstado = 'activo';
    }
    if (!_tiposDocumento.contains(_selectedTipoDocumento)) {
      _selectedTipoDocumento = _tiposDocumento.first;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nombresController.dispose();
    _apellidosController.dispose();
    _nroDocumentoController.dispose();
    _telefonoController.dispose();
    _emailController.dispose();
    _direccionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.backgroundDark,
              AppColors.surfaceDark,
              AppColors.cardDark,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildCustomAppBar(),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: _buildForm(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.surfaceDark.withValues(alpha: 0.8),
            AppColors.cardDark.withValues(alpha: 0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border(
          bottom: BorderSide(
            color: AppColors.primary.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.2),
                  AppColors.secondary.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.arrow_back,
                color: AppColors.primary,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.isEditing ? 'Editar Cliente' : 'Nuevo Cliente',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                widget.isEditing
                    ? 'Actualizar información'
                    : 'Crear nuevo registro',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
          const Spacer(),
          if (_isLoading)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 2,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSectionHeader('Información Personal', Icons.person),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _nombresController,
                      label: 'Nombres',
                      icon: Icons.person,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Los nombres son requeridos';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _buildTextField(
                      controller: _apellidosController,
                      label: 'Apellidos',
                      icon: Icons.person_outline,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Los apellidos son requeridos';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildDropdownField(
                      value: _selectedTipoDocumento ?? _tiposDocumento.first,
                      items: _tiposDocumento,
                      label: 'Tipo Documento',
                      icon: Icons.badge,
                      onChanged: (value) {
                        setState(() => _selectedTipoDocumento = value!);
                      },
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    flex: 3,
                    child: _buildTextField(
                      controller: _nroDocumentoController,
                      label: 'Número de Documento',
                      icon: Icons.numbers,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'El número de documento es requerido';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              _buildSectionHeader(
                'Información de Contacto',
                Icons.contact_phone,
              ),
              const SizedBox(height: 20),

              _buildTextField(
                controller: _telefonoController,
                label: 'Teléfono',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
              ),

              const SizedBox(height: 20),

              _buildTextField(
                controller: _emailController,
                label: 'Correo Electrónico',
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value != null &&
                      value.isNotEmpty &&
                      !value.contains('@')) {
                    return 'Ingrese un email válido';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              _buildTextField(
                controller: _direccionController,
                label: 'Dirección',
                icon: Icons.location_on,
                maxLines: 2,
              ),

              const SizedBox(height: 40),

              Row(
                children: [
                  Expanded(child: _buildCancelButton()),
                  const SizedBox(width: 15),
                  Expanded(child: _buildSaveButton()),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.2),
            AppColors.secondary.withValues(alpha: 0.1),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.surfaceDark.withValues(alpha: 0.5),
            AppColors.cardDark.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.textSecondary),
          prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String value,
    required List<String> items,
    required String label,
    required IconData icon,
    required void Function(String?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.surfaceDark.withValues(alpha: 0.5),
            AppColors.cardDark.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        isExpanded: true, // <-- Esto previene el overflow horizontal
        items: items
            .map(
              (item) => DropdownMenuItem(
                value: item,
                child: Text(
                  item,
                  style: const TextStyle(color: AppColors.textPrimary),
                ),
              ),
            )
            .toList(),
        onChanged: onChanged,
        style: const TextStyle(color: AppColors.textPrimary),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.textSecondary),
          prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        dropdownColor: AppColors.cardDark,
      ),
    );
  }

  Widget _buildCancelButton() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.error, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => Navigator.pop(context),
          child: const Center(
            child: Text(
              'CANCELAR',
              style: TextStyle(
                color: AppColors.error,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.4),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: _isLoading ? null : _saveCliente,
          child: Center(
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: AppColors.textPrimary,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    widget.isEditing ? 'ACTUALIZAR' : 'GUARDAR',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveCliente() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Siempre envía 'A' al crear, y el valor real al editar
      final String estadoBackend = widget.isEditing
          ? (_selectedEstado == 'activo' ? 'A' : 'I')
          : 'A';

      final cliente = ClienteModel(
        clienteID: widget.cliente?.clienteID,
        nombres: _nombresController.text.trim(),
        apellidos: _apellidosController.text.trim(),
        tipoDocumento: _selectedTipoDocumento ?? _tiposDocumento.first,
        nroDocumento: _nroDocumentoController.text.trim(),
        telefono: _telefonoController.text.trim().isEmpty
            ? null
            : _telefonoController.text.trim(),
        email: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        direccion: _direccionController.text.trim().isEmpty
            ? null
            : _direccionController.text.trim(),
        estado: estadoBackend,
      );

      if (widget.isEditing) {
        await _clienteService.updateClient(widget.cliente!.clienteID!, cliente);
        if (mounted) {
          _showSuccessSnackBar('Cliente actualizado exitosamente');
          Navigator.pop(context, true);
        }
      } else {
        await _clienteService.createClient(cliente);
        if (mounted) {
          _showSuccessSnackBar('Cliente creado exitosamente');
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Error: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
