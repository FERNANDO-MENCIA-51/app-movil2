import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../data/models/producto_model.dart';
import '../../../data/services/producto_service.dart';
import '../../widgets/futuristic_sidebar.dart';
import '../../widgets/producto_card.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/constants/app_constants.dart';
import 'producto_form_screen.dart';

class ProductoListScreen extends StatefulWidget {
  const ProductoListScreen({super.key});

  @override
  State<ProductoListScreen> createState() => _ProductoListScreenState();
}

class _ProductoListScreenState extends State<ProductoListScreen>
    with TickerProviderStateMixin {
  final ProductoService _productoService = ProductoService();
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<ProductoModel> _productos = [];
  List<ProductoModel> _filteredProductos = [];
  bool _isLoading = true;
  String _selectedFilter = 'todos'; // 'todos', 'A', 'I', 'stock_bajo'
  String _selectedCategoryFilter = 'todos';

  // Lista de categorías disponibles (debe coincidir con las del formulario)
  final List<String> _categoriasDisponibles = [
    'todos',
    'Keke',
    'Chocotorta',
    'Chupcake',
    'Pie',
    'Torta Helada',
    'Brownie',
    'Pasteles',
    'Repostero',
    'Pastelería',
  ];

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadProductos();
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
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProductos() async {
    try {
      setState(() => _isLoading = true);

      List<ProductoModel> productos;
      switch (_selectedFilter) {
        case 'A':
          productos = await _productoService.getActiveProductos(context);
          break;
        case 'I':
          productos = await _productoService.getInactiveProductos(context);
          break;
        // Elimina el filtro de stock bajo para evitar el error 401
        // case 'stock_bajo':
        //   productos = await _productoService.getLowStockProductos(context);
        //   break;
        default:
          productos = await _productoService.getAllProductos(context);
      }

      setState(() {
        _productos = productos;
        _filteredProductos = productos;
        _isLoading = false;
      });
      _filterProductos(_searchController.text);
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Error al cargar productos: $e');
    }
  }

  void _filterProductos(String query) {
    setState(() {
      if (query.isEmpty && _selectedCategoryFilter == 'todos') {
        _filteredProductos = _productos;
      } else {
        _filteredProductos = _productos.where((producto) {
          bool matchesQuery =
              query.isEmpty ||
              producto.nombre.toLowerCase().contains(query.toLowerCase()) ||
              (producto.codeBarra?.contains(query) ?? false) ||
              (producto.marca?.toLowerCase().contains(query.toLowerCase()) ??
                  false);

          bool matchesCategory =
              _selectedCategoryFilter == 'todos' ||
              producto.categoria == _selectedCategoryFilter;

          return matchesQuery && matchesCategory;
        }).toList();
      }
    });
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
      key: _scaffoldKey,
      drawer: FuturisticSidebar(
        currentRoute: '/productos',
        onRouteSelected: (route) {
          Navigator.pop(context);
          if (route != '/productos') {
            _navigateToRoute(route);
          }
        },
      ),
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
              _buildSearchAndFilters(),
              _buildProductStats(),
              Expanded(child: _buildProductList()),
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
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              icon: const Icon(Icons.menu, color: AppColors.primary, size: 24),
            ),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Productos',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Gestión de inventario',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            onPressed: _loadProductos,
            icon: const Icon(Icons.refresh, color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Barra de búsqueda
              Container(
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
                child: TextField(
                  controller: _searchController,
                  onChanged: _filterProductos,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Buscar por nombre, código o marca...',
                    hintStyle: const TextStyle(color: AppColors.textHint),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: AppColors.primary,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(
                              Icons.clear,
                              color: AppColors.textHint,
                            ),
                            onPressed: () {
                              _searchController.clear();
                              _filterProductos('');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // Filtros de estado
              Row(
                children: [
                  Expanded(child: _buildFilterChip('Todos', 'todos')),
                  const SizedBox(width: 8),
                  Expanded(child: _buildFilterChip('Activos', 'A')),
                  const SizedBox(width: 8),
                  Expanded(child: _buildFilterChip('Inactivos', 'I')),
                ],
              ),
              const SizedBox(height: 15),
              // Filtro de categoría como DropdownButton
              Row(
                children: [
                  const Icon(
                    Icons.category,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.surfaceDark.withValues(alpha: 0.5),
                            AppColors.cardDark.withValues(alpha: 0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.border.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: DropdownButton<String>(
                        value: _selectedCategoryFilter,
                        isExpanded: true,
                        dropdownColor: AppColors.cardDark,
                        icon: const Icon(
                          Icons.arrow_drop_down,
                          color: AppColors.primary,
                        ),
                        underline: const SizedBox(),
                        style: const TextStyle(color: AppColors.textPrimary),
                        items: _categoriasDisponibles
                            .map(
                              (cat) => DropdownMenuItem<String>(
                                value: cat,
                                child: Text(
                                  cat == 'todos' ? 'Todas las categorías' : cat,
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontWeight: cat == _selectedCategoryFilter
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategoryFilter = value!;
                            _filterProductos(_searchController.text);
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedFilter = value);
        _loadProductos();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
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
            color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 11,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildProductStats() {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withValues(alpha: 0.2),
                AppColors.secondary.withValues(alpha: 0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Total', _productos.length, Icons.inventory_2),
              _buildStatItem(
                'Activos',
                _productos.where((p) => p.isActivo).length,
                Icons.check_circle,
              ),
              _buildStatItem(
                'Inactivos',
                _productos.where((p) => !p.isActivo).length,
                Icons.cancel,
              ),
              _buildStatItem(
                'Stock Bajo',
                _productos.where((p) => p.isStockBajo && p.isActivo).length,
                Icons.warning,
              ),
              _buildStatItem(
                'Sin Stock',
                _productos.where((p) => p.stock == 0 && p.isActivo).length,
                Icons.error,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, int value, IconData icon) {
    Color iconColor = AppColors.primary;
    if (label == 'Stock Bajo') iconColor = AppColors.warning;
    if (label == 'Sin Stock') iconColor = AppColors.error;
    if (label == 'Inactivos')
      iconColor = AppColors.error; // <- Corrige color a rojo

    return Column(
      children: [
        Icon(icon, color: iconColor, size: 18),
        const SizedBox(height: 4),
        Text(
          value.toString(),
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: label == 'Inactivos'
                ? AppColors
                      .error // <- Texto rojo para inactivos
                : AppColors.textSecondary,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildProductList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_filteredProductos.isEmpty) {
      return _buildEmptyState();
    }

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: _filteredProductos.length,
          itemBuilder: (context, index) {
            final producto = _filteredProductos[index];
            return TweenAnimationBuilder<double>(
              duration: Duration(milliseconds: 300 + (index * 100)),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset((1 - value) * 50, 0),
                  child: Opacity(
                    opacity: value,
                    child: ProductoCard(
                      producto: producto,
                      onTap:
                          () {}, // Puedes dejarlo vacío o usar para ver detalle
                      onView:
                          () {}, // Puedes dejarlo vacío o usar para ver detalle
                      onEdit: () {
                        // Abre el formulario de edición de producto
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductoFormScreen(
                              producto: producto,
                              isEditing: true,
                            ),
                          ),
                        );
                      },
                      onDelete: () {
                        _showDeleteRestoreDialog(producto);
                      },
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.inventory_2_outlined,
            size: 80,
            color: AppColors.textHint,
          ),
          const SizedBox(height: 16),
          const Text(
            'No hay productos disponibles',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Agrega tu primer producto para comenzar',
            style: TextStyle(color: AppColors.textHint, fontSize: 14),
          ),
        ],
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
          // Abre el formulario para crear un nuevo producto
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductoFormScreen(isEditing: false),
            ),
          ).then((value) {
            // Recarga la lista si se creó un producto
            if (value == true) _loadProductos();
          });
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: const Icon(Icons.add, color: AppColors.textPrimary, size: 28),
      ),
    );
  }

  void _showDeleteRestoreDialog(ProductoModel producto) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        title: Text(
          producto.isActivo ? 'Eliminar Producto' : 'Restaurar Producto',
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          producto.isActivo
              ? '¿Estás seguro de que deseas eliminar ${producto.nombre}?'
              : '¿Estás seguro de que deseas restaurar ${producto.nombre}?',
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
              _deleteOrRestoreProduct(producto);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: producto.isActivo
                  ? AppColors.error
                  : AppColors.success,
            ),
            child: Text(
              producto.isActivo ? 'Eliminar' : 'Restaurar',
              style: const TextStyle(color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteOrRestoreProduct(ProductoModel producto) async {
    try {
      if (producto.isActivo) {
        await _productoService.deleteLogicalProducto(
          producto.productoID!,
          context: context,
        );
        _showSuccessSnackBar('Producto eliminado exitosamente');
      } else {
        await _productoService.restoreProducto(
          producto.productoID!,
          context: context,
        );
        _showSuccessSnackBar('Producto restaurado exitosamente');
      }
      _loadProductos();
    } catch (e) {
      _showErrorSnackBar('Error: $e');
    }
  }

  void _navigateToRoute(String route) {
    switch (route) {
      case AppConstants.homeRoute:
        AppRoutes.navigateToHome(context);
        break;
      case AppConstants.clientesRoute:
        AppRoutes.navigateToClientes(context);
        break;
      case AppConstants.loginRoute:
        AppRoutes.navigateToLogin(context);
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Navegando a: $route'),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
    }
  }
}
