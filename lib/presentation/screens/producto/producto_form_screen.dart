import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../data/models/producto_model.dart';
import '../../../data/models/supplier_model.dart';
import '../../../data/services/producto_service.dart';
import '../../../data/services/supplier_service.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/section_header.dart';

class ProductoFormScreen extends StatefulWidget {
  final ProductoModel? producto;
  final bool isEditing;

  const ProductoFormScreen({super.key, this.producto, this.isEditing = false});

  @override
  State<ProductoFormScreen> createState() => _ProductoFormScreenState();
}

class _ProductoFormScreenState extends State<ProductoFormScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final ProductoService _productoService = ProductoService();
  final SupplierService _supplierService = SupplierService();

  // Controllers
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _marcaController = TextEditingController();
  final _codeBarraController = TextEditingController();
  final _precioVentaController = TextEditingController();
  final _stockController = TextEditingController();

  String _selectedCategoria = 'Pasteles';
  String _selectedEstatus = 'activo';
  SupplierModel? _selectedSupplier;
  List<SupplierModel> _suppliers = [];
  bool _isLoading = false;
  bool _isLoadingSuppliers = true;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<String> _categorias = [
    'Pasteles',
    'Ingredientes',
    'Decoración',
    'Herramientas',
  ];
  final List<String> _estatusOptions = ['activo', 'inactivo'];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadSuppliers();
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

  Future<void> _loadSuppliers() async {
    try {
      final suppliers = await _supplierService.getActiveSuppliers();
      setState(() {
        _suppliers = suppliers;
        _isLoadingSuppliers = false;
      });
    } catch (e) {
      setState(() => _isLoadingSuppliers = false);
      _showErrorSnackBar('Error al cargar proveedores: $e');
    }
  }

  void _initializeForm() {
    if (widget.producto != null) {
      final producto = widget.producto!;
      _nombreController.text = producto.nombre;
      _descripcionController.text = producto.descripcion ?? '';
      _marcaController.text = producto.marca ?? '';
      _codeBarraController.text = producto.codeBarra ?? '';
      _precioVentaController.text = producto.precioVenta.toString();
      _stockController.text = producto.stock.toString();
      _selectedCategoria = producto.categoria ?? 'Pasteles';
      _selectedEstatus = producto.estatus;
      _selectedSupplier = producto.supplier;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    // ...existing controllers disposal...
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
                widget.isEditing ? 'Editar Producto' : 'Nuevo Producto',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                widget.isEditing
                    ? 'Actualizar información'
                    : 'Crear nuevo producto',
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
              SectionHeader(
                title: 'Información del Producto',
                icon: Icons.inventory_2,
              ),
              const SizedBox(height: 20),

              CustomTextField(
                controller: _nombreController,
                label: 'Nombre del Producto',
                icon: Icons.label,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El nombre es requerido';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              CustomTextField(
                controller: _descripcionController,
                label: 'Descripción',
                icon: Icons.description,
                maxLines: 3,
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _marcaController,
                      label: 'Marca',
                      icon: Icons.branding_watermark,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: CustomTextField(
                      controller: _codeBarraController,
                      label: 'Código de Barra',
                      icon: Icons.qr_code,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              _buildDropdownField(
                value: _selectedCategoria,
                items: _categorias,
                label: 'Categoría',
                icon: Icons.category,
                onChanged: (value) {
                  setState(() => _selectedCategoria = value!);
                },
              ),

              const SizedBox(height: 30),

              SectionHeader(
                title: 'Precio y Stock',
                icon: Icons.monetization_on,
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _precioVentaController,
                      label: 'Precio de Venta',
                      icon: Icons.attach_money,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'El precio es requerido';
                        }
                        final precio = double.tryParse(value);
                        if (precio == null || precio <= 0) {
                          return 'Ingrese un precio válido';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: CustomTextField(
                      controller: _stockController,
                      label: 'Stock',
                      icon: Icons.inventory,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'El stock es requerido';
                        }
                        final stock = int.tryParse(value);
                        if (stock == null || stock < 0) {
                          return 'Ingrese un stock válido';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              SectionHeader(title: 'Proveedor', icon: Icons.business),
              const SizedBox(height: 20),

              _buildSupplierDropdown(),

              const SizedBox(height: 30),

              SectionHeader(title: 'Estado', icon: Icons.settings),
              const SizedBox(height: 20),

              _buildDropdownField(
                value: _selectedEstatus,
                items: _estatusOptions,
                label: 'Estado del Producto',
                icon: Icons.toggle_on,
                onChanged: (value) {
                  setState(() => _selectedEstatus = value!);
                },
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

  Widget _buildSupplierDropdown() {
    if (_isLoadingSuppliers) {
      return Container(
        height: 60,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.surfaceDark.withValues(alpha: 0.5),
              AppColors.cardDark.withValues(alpha: 0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

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
      child: DropdownButtonFormField<SupplierModel>(
        value: _selectedSupplier,
        items: _suppliers
            .map(
              (supplier) => DropdownMenuItem(
                value: supplier,
                child: Text(
                  supplier.nombre,
                  style: const TextStyle(color: AppColors.textPrimary),
                ),
              ),
            )
            .toList(),
        onChanged: (value) {
          setState(() => _selectedSupplier = value);
        },
        validator: (value) {
          if (value == null) {
            return 'Seleccione un proveedor';
          }
          return null;
        },
        decoration: const InputDecoration(
          labelText: 'Proveedor',
          labelStyle: TextStyle(color: AppColors.textSecondary),
          prefixIcon: Icon(Icons.business, color: AppColors.primary, size: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
          onTap: _isLoading ? null : _saveProducto,
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

  Future<void> _saveProducto() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final producto = ProductoModel(
        productoID: widget.producto?.productoID,
        nombre: _nombreController.text.trim(),
        descripcion: _descripcionController.text.trim().isEmpty
            ? null
            : _descripcionController.text.trim(),
        marca: _marcaController.text.trim().isEmpty
            ? null
            : _marcaController.text.trim(),
        codeBarra: _codeBarraController.text.trim().isEmpty
            ? null
            : _codeBarraController.text.trim(),
        categoria: _selectedCategoria,
        precioVenta: double.parse(_precioVentaController.text.trim()),
        stock: int.parse(_stockController.text.trim()),
        estatus: _selectedEstatus,
        fechaIngreso: widget.producto?.fechaIngreso ?? DateTime.now(),
        supplier: _selectedSupplier!,
      );

      if (widget.isEditing) {
        await _productoService.updateProducto(
          widget.producto!.productoID!,
          producto,
        );
        if (mounted) {
          _showSuccessSnackBar('Producto actualizado exitosamente');
          Navigator.pop(context, true);
        }
      } else {
        await _productoService.createProducto(producto);
        if (mounted) {
          _showSuccessSnackBar('Producto creado exitosamente');
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
