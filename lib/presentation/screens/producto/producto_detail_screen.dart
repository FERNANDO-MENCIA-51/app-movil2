import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../data/models/producto_model.dart';
import '../../../data/services/producto_service.dart';

class ProductoDetailScreen extends StatefulWidget {
  final ProductoModel producto;

  const ProductoDetailScreen({super.key, required this.producto});

  @override
  State<ProductoDetailScreen> createState() => _ProductoDetailScreenState();
}

class _ProductoDetailScreenState extends State<ProductoDetailScreen>
    with TickerProviderStateMixin {
  final ProductoService _productoService = ProductoService();
  late ProductoModel _producto;
  bool _isLoading = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _producto = widget.producto;
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
                  'Detalle del Producto',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _producto.nombre,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _producto.isActivo
                  ? AppColors.success.withValues(alpha: 0.2)
                  : AppColors.error.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _producto.isActivo ? AppColors.success : AppColors.error,
                width: 1,
              ),
            ),
            child: Text(
              _producto.isActivo ? 'ACTIVO' : 'INACTIVO',
              style: TextStyle(
                color: _producto.isActivo ? AppColors.success : AppColors.error,
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
            _buildProductCard(),
            const SizedBox(height: 20),
            _buildProductInfoCard(),
            const SizedBox(height: 20),
            _buildPriceStockCard(),
            const SizedBox(height: 20),
            _buildSupplierCard(),
            const SizedBox(height: 20),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard() {
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
                colors: _producto.isActivo
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
              Icons.inventory_2,
              color: AppColors.textPrimary,
              size: 50,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _producto.nombreCompleto,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            _producto.precioFormateado,
            style: const TextStyle(
              color: AppColors.secondary,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _producto.isStockBajo
                      ? AppColors.warning.withValues(alpha: 0.2)
                      : AppColors.success.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Stock: ${_producto.stock}',
                  style: TextStyle(
                    color: _producto.isStockBajo
                        ? AppColors.warning
                        : AppColors.success,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (_producto.isStockBajo) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'STOCK BAJO',
                    style: TextStyle(
                      color: AppColors.warning,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductInfoCard() {
    return _buildInfoCard(
      title: 'Información del Producto',
      icon: Icons.info,
      children: [
        if (_producto.categoria != null)
          _buildInfoRow('Categoría', _producto.categoria!, Icons.category),
        if (_producto.marca != null)
          _buildInfoRow('Marca', _producto.marca!, Icons.branding_watermark),
        if (_producto.hasCodeBarra)
          _buildInfoRow('Código de Barra', _producto.codeBarra!, Icons.qr_code),
        if (_producto.hasDescripcion)
          _buildInfoRow(
            'Descripción',
            _producto.descripcion!,
            Icons.description,
          ),
        _buildInfoRow(
          'Fecha de Ingreso',
          _producto.fechaFormateada,
          Icons.calendar_today,
        ),
        _buildInfoRow(
          'Estado',
          _producto.estatus.toUpperCase(),
          _producto.isActivo ? Icons.check_circle : Icons.cancel,
          color: _producto.isActivo ? AppColors.success : AppColors.error,
        ),
      ],
    );
  }

  Widget _buildPriceStockCard() {
    return _buildInfoCard(
      title: 'Precio y Stock',
      icon: Icons.monetization_on,
      children: [
        _buildInfoRow(
          'Precio de Venta',
          _producto.precioFormateado,
          Icons.attach_money,
          color: AppColors.secondary,
        ),
        _buildInfoRow(
          'Stock Actual',
          _producto.stock.toString(),
          Icons.inventory,
          color: _producto.isStockBajo ? AppColors.warning : AppColors.success,
        ),
        _buildInfoRow(
          'Disponibilidad',
          _producto.isDisponible ? 'Disponible' : 'No Disponible',
          _producto.isDisponible ? Icons.check_circle : Icons.error,
          color: _producto.isDisponible ? AppColors.success : AppColors.error,
        ),
      ],
    );
  }

  Widget _buildSupplierCard() {
    return _buildInfoCard(
      title: 'Información del Proveedor',
      icon: Icons.business,
      children: [
        _buildInfoRow('Nombre', _producto.supplier.nombre, Icons.business),
        if (_producto.supplier.contacto != null)
          _buildInfoRow('Contacto', _producto.supplier.contacto!, Icons.person),
        if (_producto.supplier.hasTelefono)
          _buildInfoRow('Teléfono', _producto.supplier.telefono!, Icons.phone),
        if (_producto.supplier.hasValidEmail)
          _buildInfoRow('Email', _producto.supplier.email!, Icons.email),
        _buildInfoRow(
          'Estado',
          _producto.supplier.estado.toUpperCase(),
          _producto.supplier.isActivo ? Icons.check_circle : Icons.cancel,
          color: _producto.supplier.isActivo
              ? AppColors.success
              : AppColors.error,
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
            label: _producto.isActivo ? 'ELIMINAR' : 'RESTAURAR',
            icon: _producto.isActivo ? Icons.delete : Icons.restore,
            color: _producto.isActivo ? AppColors.error : AppColors.success,
            onPressed: () => _showDeleteRestoreDialog(),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _buildActionButton(
            label: 'EDITAR',
            icon: Icons.edit,
            color: AppColors.primary,
            onPressed: () {},
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
        onPressed: () {},
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
          _producto.isActivo ? 'Eliminar Producto' : 'Restaurar Producto',
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          _producto.isActivo
              ? '¿Estás seguro de que deseas eliminar ${_producto.nombre}? Esta acción se puede revertir.'
              : '¿Estás seguro de que deseas restaurar ${_producto.nombre}?',
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
              _deleteOrRestoreProduct();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _producto.isActivo
                  ? AppColors.error
                  : AppColors.success,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              _producto.isActivo ? 'Eliminar' : 'Restaurar',
              style: const TextStyle(color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteOrRestoreProduct() async {
    setState(() => _isLoading = true);

    try {
      if (_producto.isActivo) {
        await _productoService.deleteLogicalProducto(_producto.productoID!);
        _showSuccessSnackBar('Producto eliminado exitosamente');
        setState(() {
          _producto = _producto.copyWith(estatus: 'inactivo');
        });
      } else {
        await _productoService.restoreProducto(_producto.productoID!);
        _showSuccessSnackBar('Producto restaurado exitosamente');
        setState(() {
          _producto = _producto.copyWith(estatus: 'activo');
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
