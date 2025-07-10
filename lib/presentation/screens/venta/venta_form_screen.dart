import 'package:flutter/material.dart';
import 'package:myapp/data/models/venta_model.dart';
import '../../../core/constants/colors.dart';
import '../../../data/models/cliente_model.dart';
import '../../../data/models/producto_model.dart';
import '../../../data/models/venta_detalle_model.dart';
import '../../../data/models/dto/venta_request_model.dart';
import '../../../data/models/dto/venta_detalle_request_dto.dart';
import '../../../data/services/cliente_service.dart';
import '../../../data/services/producto_service.dart';
import '../../../data/services/venta_transaccion_service.dart';

class VentaFormScreen extends StatefulWidget {
  final VentaModel? venta;
  final bool isEditing;

  const VentaFormScreen({super.key, this.venta, this.isEditing = false});

  @override
  State<VentaFormScreen> createState() => _VentaFormScreenState();
}

class _VentaFormScreenState extends State<VentaFormScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final ClienteService _clienteService = ClienteService();
  final ProductoService _productoService = ProductoService();
  final VentaTransaccionService _ventaService = VentaTransaccionService();

  List<ClienteModel> _clientes = [];
  List<ProductoModel> _productos = [];
  ClienteModel? _selectedCliente;
  ProductoModel? _selectedProducto;
  int _cantidadProducto = 1;
  List<VentaDetalleModel> _carrito = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadClientes();
    _loadProductos();
    if (widget.isEditing && widget.venta != null) {
      _loadVentaDetalles();
      // Cargar cliente seleccionado al editar
      _selectedCliente = widget.venta!.cliente;
    }
  }

  Future<void> _loadClientes() async {
    // Solo usa lo que tienes en tu ClienteService
    final clientes = await _clienteService
        .getAllClients(); // Usa el método real que tienes
    setState(() => _clientes = clientes);
  }

  Future<void> _loadProductos() async {
    final productos = await _productoService.getActiveProductos(context);
    setState(() => _productos = productos);
  }

  Future<void> _loadVentaDetalles() async {
    // Si el modelo ya trae los detalles, los usamos directamente
    if (widget.venta!.detalles.isNotEmpty) {
      setState(() {
        _carrito = List<VentaDetalleModel>.from(widget.venta!.detalles);
      });
      return;
    }
    // Si necesitas obtener los detalles desde el backend:
    // final detalles = await VentaDetalleService().getDetallesByVentaId(widget.venta!.ventaID!);
    // setState(() {
    //   _carrito = detalles;
    // });
  }

  double get subtotal => _carrito.fold(0.0, (sum, d) => sum + d.subtotal);
  double get igv => subtotal * 0.18;
  double get total => subtotal + igv;

  void _addProductoToCarrito() {
    if (_selectedProducto == null) return;
    if (_carrito.any(
      (d) => d.producto.productoID == _selectedProducto!.productoID,
    )) {
      _showErrorSnackBar('El producto ya está en el carrito');
      return;
    }
    if (_cantidadProducto <= 0) {
      _showErrorSnackBar('La cantidad debe ser mayor a cero');
      return;
    }
    if (_cantidadProducto > _selectedProducto!.stock) {
      _showErrorSnackBar('No hay suficiente stock disponible');
      return;
    }
    setState(() {
      _carrito.add(
        VentaDetalleModel(
          cantidad: _cantidadProducto,
          precioUnitario: _selectedProducto!.precioVenta.toDouble(),
          subtotal:
              (_selectedProducto!.precioVenta.toDouble() * _cantidadProducto),
          producto: _selectedProducto!,
          estado: 'A',
        ),
      );
      _selectedProducto = null;
      _cantidadProducto = 1;
    });
  }

  void _removeFromCarrito(int index) {
    setState(() {
      _carrito.removeAt(index);
    });
  }

  Future<void> _saveVenta() async {
    if (_selectedCliente == null || _carrito.isEmpty) {
      _showErrorSnackBar('Seleccione cliente y agregue productos');
      return;
    }
    setState(() => _isLoading = true);
    try {
      final detalles = _carrito
          .map(
            (d) => VentaDetalleRequestDTO(
              productoId: d.producto.productoID!,
              cantidad: d.cantidad.toDouble(),
              precioUnitario: d.precioUnitario,
              subtotal: d.subtotal,
            ),
          )
          .toList();

      final ventaRequest = VentaRequestModel(
        fechaVenta: DateTime.now(),
        totalVenta: total,
        clienteId: _selectedCliente!.clienteID!,
        detalles: detalles,
      );

      // Usa el método correcto para registrar la venta
      await _ventaService.registrarVentaCompleta(ventaRequest);

      if (mounted) {
        _showSuccessSnackBar('Venta registrada exitosamente');
        Navigator.pop(context, true);
      }
    } catch (e) {
      _showErrorSnackBar('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
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
                'Nueva Venta',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Registrar venta y detalle',
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
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 10),
          _buildClienteDropdown(),
          const SizedBox(height: 20),
          _buildProductoSelector(),
          const SizedBox(height: 20),
          _buildCarrito(),
          const SizedBox(height: 20),
          _buildResumen(),
          const SizedBox(height: 30),
          Row(
            children: [
              Expanded(child: _buildCancelButton()),
              const SizedBox(width: 15),
              Expanded(child: _buildSaveButton()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildClienteDropdown() {
    return DropdownButtonFormField<ClienteModel>(
      value: _selectedCliente,
      items: _clientes
          .map(
            (cliente) => DropdownMenuItem(
              value: cliente,
              child: Text(
                cliente.nombreCompleto,
                style: const TextStyle(color: AppColors.textPrimary),
              ),
            ),
          )
          .toList(),
      onChanged: (value) {
        setState(() => _selectedCliente = value);
      },
      decoration: const InputDecoration(
        labelText: 'Seleccionar Cliente',
        labelStyle: TextStyle(color: AppColors.textSecondary),
        prefixIcon: Icon(Icons.person, color: AppColors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.transparent,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      dropdownColor: AppColors.cardDark,
      validator: (value) => value == null ? 'Seleccione un cliente' : null,
    );
  }

  Widget _buildProductoSelector() {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: DropdownButtonFormField<ProductoModel>(
            value: _selectedProducto,
            items: _productos
                .where(
                  (p) => !_carrito.any(
                    (d) => d.producto.productoID == p.productoID,
                  ),
                )
                .map(
                  (producto) => DropdownMenuItem(
                    value: producto,
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            '${producto.nombreCompleto} (Stock: ${producto.stock})',
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedProducto = value;
                _cantidadProducto = 1;
              });
            },
            decoration: const InputDecoration(
              labelText: 'Seleccionar Producto',
              labelStyle: TextStyle(color: AppColors.textSecondary),
              prefixIcon: Icon(Icons.inventory_2, color: AppColors.primary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.transparent,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            dropdownColor: AppColors.cardDark,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 1,
          child: TextFormField(
            enabled: _selectedProducto != null,
            initialValue: '1',
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Cant.',
              labelStyle: TextStyle(color: AppColors.textSecondary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.transparent,
              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            ),
            style: const TextStyle(color: AppColors.textPrimary),
            onChanged: (value) {
              final cantidad = int.tryParse(value) ?? 1;
              setState(() => _cantidadProducto = cantidad);
            },
          ),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: _selectedProducto == null ? null : _addProductoToCarrito,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Icon(Icons.add, color: AppColors.textPrimary),
        ),
      ],
    );
  }

  Widget _buildCarrito() {
    if (_carrito.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text(
            'No hay productos en el carrito',
            style: TextStyle(color: AppColors.textHint),
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Carrito de Productos',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 10),
        ..._carrito.asMap().entries.map((entry) {
          final i = entry.key;
          final detalle = entry.value;
          return Card(
            color: AppColors.cardDark,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: AppColors.primary.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: ListTile(
              leading: const Icon(Icons.inventory_2, color: AppColors.primary),
              title: Text(
                detalle.producto.nombreCompleto,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                'Cantidad: ${detalle.cantidad}  |  P. Unit: S/ ${detalle.precioUnitario.toStringAsFixed(2)}',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: AppColors.error),
                onPressed: () => _removeFromCarrito(i),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildResumen() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.1),
            AppColors.secondary.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildResumenRow('Subtotal', 'S/ ${subtotal.toStringAsFixed(2)}'),
          _buildResumenRow('IGV (18%)', 'S/ ${igv.toStringAsFixed(2)}'),
          const Divider(color: AppColors.border),
          _buildResumenRow(
            'Total',
            'S/ ${total.toStringAsFixed(2)}',
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildResumenRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isTotal ? AppColors.primary : AppColors.textSecondary,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: isTotal ? AppColors.primary : AppColors.textPrimary,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
        ],
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
          onTap: _isLoading ? null : _saveVenta,
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
                : const Text(
                    'GUARDAR',
                    style: TextStyle(
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
}
