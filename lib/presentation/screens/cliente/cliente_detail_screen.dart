import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/routes/app_routes.dart';
import '../../../data/models/cliente_model.dart';
import '../../../data/services/cliente_service.dart';

class ClienteDetailScreen extends StatefulWidget {
  final ClienteModel cliente;

  const ClienteDetailScreen({super.key, required this.cliente});

  @override
  State<ClienteDetailScreen> createState() => _ClienteDetailScreenState();
}

class _ClienteDetailScreenState extends State<ClienteDetailScreen>
    with TickerProviderStateMixin {
  final ClienteService _clienteService = ClienteService();
  late ClienteModel _cliente;
  bool _isLoading = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _cliente = widget.cliente;
    _setupAnimations();
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

  @override
  void dispose() {
    _animationController.dispose();
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
                    child: _buildContent(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildCustomAppBar() {
    // Normaliza el estado para la UI
    final bool isActivo = _cliente.estado.toUpperCase() == 'A';
    final String estadoUi = isActivo ? 'ACTIVO' : 'INACTIVO';
    final Color estadoColor = isActivo ? AppColors.success : AppColors.error;

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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Detalle del Cliente',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _cliente.nombreCompleto,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: estadoColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: estadoColor, width: 1),
            ),
            child: Text(
              estadoUi,
              style: TextStyle(
                color: estadoColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileCard(),
            const SizedBox(height: 20),
            _buildPersonalInfoCard(),
            const SizedBox(height: 20),
            _buildContactInfoCard(),
            const SizedBox(height: 20),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.2),
            AppColors.secondary.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.1),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _cliente.isActivo
                    ? [AppColors.primary, AppColors.secondary]
                    : [AppColors.error, AppColors.warning],
              ),
              borderRadius: BorderRadius.circular(50),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.4),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.person,
              color: AppColors.textPrimary,
              size: 50,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _cliente.nombreCompleto,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '${_cliente.tipoDocumento}: ${_cliente.nroDocumento}',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoCard() {
    // Normaliza el estado para la UI
    final bool isActivo = _cliente.estado.toUpperCase() == 'A';
    final String estadoUi = isActivo ? 'ACTIVO' : 'INACTIVO';
    final Color estadoColor = isActivo ? AppColors.success : AppColors.error;

    return _buildInfoCard(
      title: 'Información Personal',
      icon: Icons.person,
      children: [
        _buildInfoRow('Nombres', _cliente.nombres, Icons.badge),
        _buildInfoRow('Apellidos', _cliente.apellidos, Icons.badge_outlined),
        _buildInfoRow(
          'Tipo de Documento',
          _cliente.tipoDocumento,
          Icons.credit_card,
        ),
        _buildInfoRow(
          'Número de Documento',
          _cliente.nroDocumento,
          Icons.numbers,
        ),
        _buildInfoRow(
          'Estado',
          estadoUi,
          isActivo ? Icons.check_circle : Icons.cancel,
          color: estadoColor,
        ),
      ],
    );
  }

  Widget _buildContactInfoCard() {
    return _buildInfoCard(
      title: 'Información de Contacto',
      icon: Icons.contact_phone,
      children: [
        if (_cliente.telefono != null && _cliente.telefono!.isNotEmpty)
          _buildInfoRow('Teléfono', _cliente.telefono!, Icons.phone),
        if (_cliente.email != null && _cliente.email!.isNotEmpty)
          _buildInfoRow('Email', _cliente.email!, Icons.email),
        if (_cliente.direccion != null && _cliente.direccion!.isNotEmpty)
          _buildInfoRow('Dirección', _cliente.direccion!, Icons.location_on),
        if (!_cliente.hasTelefono &&
            !_cliente.hasValidEmail &&
            !_cliente.hasDireccion)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'No hay información de contacto disponible',
              style: TextStyle(
                color: AppColors.textHint,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.cardDark, AppColors.surfaceDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.2),
                  AppColors.secondary.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
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
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    IconData icon, {
    Color? color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: (color ?? AppColors.primary).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color ?? AppColors.primary, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textHint,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    color: color ?? AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            label: _cliente.isActivo ? 'ELIMINAR' : 'RESTAURAR',
            icon: _cliente.isActivo ? Icons.delete : Icons.restore,
            color: _cliente.isActivo ? AppColors.error : AppColors.success,
            onPressed: () => _showDeleteRestoreDialog(),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _buildActionButton(
            label: 'EDITAR',
            icon: Icons.edit,
            color: AppColors.primary,
            onPressed: () {
              AppRoutes.navigateToClienteForm(context, cliente: _cliente);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: _isLoading ? null : onPressed,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.4),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: () {
          AppRoutes.navigateToClienteForm(context, cliente: _cliente);
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: const Icon(Icons.edit, color: AppColors.textPrimary, size: 24),
      ),
    );
  }

  void _showDeleteRestoreDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          _cliente.isActivo ? 'Eliminar Cliente' : 'Restaurar Cliente',
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          _cliente.isActivo
              ? '¿Estás seguro de que deseas eliminar a ${_cliente.nombreCompleto}? Esta acción se puede revertir.'
              : '¿Estás seguro de que deseas restaurar a ${_cliente.nombreCompleto}?',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: AppColors.textHint),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteOrRestoreClient();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _cliente.isActivo
                  ? AppColors.error
                  : AppColors.success,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              _cliente.isActivo ? 'Eliminar' : 'Restaurar',
              style: const TextStyle(color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteOrRestoreClient() async {
    setState(() => _isLoading = true);

    try {
      if (_cliente.estado.toUpperCase() == 'A') {
        await _clienteService.deleteLogical(_cliente.clienteID!);
        _showSuccessSnackBar('Cliente eliminado exitosamente');
        setState(() {
          _cliente = _cliente.copyWith(estado: 'I'); // Cambia a 'I'
        });
      } else {
        await _clienteService.restoreClient(_cliente.clienteID!);
        _showSuccessSnackBar('Cliente restaurado exitosamente');
        setState(() {
          _cliente = _cliente.copyWith(estado: 'A'); // Cambia a 'A'
        });
      }
    } catch (e) {
      _showErrorSnackBar('Error: $e');
    } finally {
      setState(() => _isLoading = false);
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
