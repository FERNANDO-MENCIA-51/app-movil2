import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../data/models/venta_model.dart';
import '../../../data/models/venta_detalle_model.dart';
import '../../../data/services/venta_transaccion_service.dart';

class VentaDetailScreen extends StatefulWidget {
  final VentaModel venta;

  const VentaDetailScreen({super.key, required this.venta});

  @override
  State<VentaDetailScreen> createState() => _VentaDetailScreenState();
}

class _VentaDetailScreenState extends State<VentaDetailScreen> {
  final VentaTransaccionService _ventaTransaccionService =
      VentaTransaccionService();
  List<VentaDetalleModel> _detalles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDetalles();
  }

  Future<void> _loadDetalles() async {
    try {
      final ventaCompleta = await _ventaTransaccionService.obtenerVentaCompleta(
        widget.venta.ventaID!,
      );
      setState(() {
        _detalles = ventaCompleta?.detalles ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _detalles = [];
        _isLoading = false;
      });
    }
  }

  double get subtotal => _detalles.fold(0, (sum, d) => sum + d.subtotal);
  double get igv => subtotal * 0.18;
  double get total => subtotal + igv;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detalle de Venta',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        backgroundColor: AppColors.backgroundDark,
      ),
      backgroundColor: AppColors.backgroundDark,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildVentaInfo(),
                    const SizedBox(height: 20),
                    _buildDetalleList(),
                    const SizedBox(height: 20),
                    _buildResumen(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildVentaInfo() {
    final venta = widget.venta;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.2),
            AppColors.secondary.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cliente: ${venta.cliente.nombreCompleto}',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Fecha: ${venta.fechaFormateada}',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Estado: ${venta.estado}',
            style: TextStyle(
              color: venta.isActivo ? AppColors.success : AppColors.error,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetalleList() {
    if (_detalles.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text(
            'No hay detalles para esta venta',
            style: TextStyle(color: AppColors.textHint),
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Detalle de Productos',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 10),
        ..._detalles.map(
          (detalle) => Card(
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
              trailing: Text(
                'S/ ${detalle.subtotal.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ),
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
}
