import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../data/models/venta_model.dart';
import '../../../data/services/venta_transaccion_service.dart';
import '../../../core/routes/app_routes.dart';
import '../../widgets/venta_card.dart';

class VentaListScreen extends StatefulWidget {
  const VentaListScreen({super.key});

  @override
  State<VentaListScreen> createState() => _VentaListScreenState();
}

class _VentaListScreenState extends State<VentaListScreen> {
  final VentaTransaccionService _ventaTransaccionService =
      VentaTransaccionService();
  List<VentaModel> _ventas = [];
  bool _isLoading = true;
  String _selectedFilter = 'todos';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadVentas();
  }

  Future<void> _loadVentas() async {
    setState(() => _isLoading = true);
    try {
      List<VentaModel> ventas = await _ventaTransaccionService.listarTodasLasVentas(context);
      if (_selectedFilter == 'activos') {
        ventas = ventas.where((v) => v.isActivo).toList();
      } else if (_selectedFilter == 'inactivos') {
        ventas = ventas.where((v) => !v.isActivo).toList();
      }
      setState(() {
        _ventas = ventas;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Error al cargar ventas: $e', AppColors.error);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Future<void> _deleteOrRestoreVenta(VentaModel venta) async {
    setState(() => _isLoading = true);
    try {
      if (venta.isActivo) {
        await _ventaTransaccionService.eliminarVentaCompleta(venta.ventaID!);
        _showSnackBar('Venta eliminada', AppColors.error);
      } else {
        await _ventaTransaccionService.restaurarVentaCompleta(venta.ventaID!);
        _showSnackBar('Venta restaurada', AppColors.success);
      }
      await _loadVentas();
    } catch (e) {
      _showSnackBar('Error: $e', AppColors.error);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List<VentaModel> get _filteredVentas {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return _ventas;
    return _ventas
        .where(
          (venta) =>
              venta.cliente.nombreCompleto.toLowerCase().contains(query) ||
              venta.cliente.nroDocumento.contains(query),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ventas',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        backgroundColor: AppColors.backgroundDark,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.primary),
            onPressed: _loadVentas,
          ),
        ],
      ),
      backgroundColor: AppColors.backgroundDark,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: AppColors.textPrimary),
        onPressed: () => AppRoutes.navigateToVentaForm(context),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Buscar por cliente o documento...',
                hintStyle: const TextStyle(color: AppColors.textHint),
                prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                filled: true,
                fillColor: AppColors.surfaceDark.withValues(alpha: 0.7),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildFilterChip('Todos', 'todos'),
                const SizedBox(width: 10),
                _buildFilterChip('Activos', 'activos'),
                const SizedBox(width: 10),
                _buildFilterChip('Inactivos', 'inactivos'),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : _filteredVentas.isEmpty
                ? const Center(
                    child: Text(
                      'No hay ventas registradas',
                      style: TextStyle(color: AppColors.textHint),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredVentas.length,
                    itemBuilder: (context, index) {
                      final venta = _filteredVentas[index];
                      return VentaCard(
                        venta: venta,
                        onTap: () =>
                            AppRoutes.navigateToVentaDetail(context, venta),
                        onView: () =>
                            AppRoutes.navigateToVentaDetail(context, venta),
                        onDelete: () => _deleteOrRestoreVenta(venta),
                        onRestore: () => _deleteOrRestoreVenta(venta),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedFilter = value);
          _loadVentas();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            gradient: isSelected
                ? const LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isSelected ? null : AppColors.surfaceDark,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? Colors.transparent : AppColors.border,
              width: 1,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? AppColors.textPrimary
                  : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

