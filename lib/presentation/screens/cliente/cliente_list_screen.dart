import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../data/models/cliente_model.dart';
import '../../../data/services/cliente_service.dart';
import '../../widgets/futuristic_sidebar.dart';
import '../../widgets/cliente_card.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/constants/app_constants.dart';

class ClienteListScreen extends StatefulWidget {
  const ClienteListScreen({super.key});

  @override
  State<ClienteListScreen> createState() => _ClienteListScreenState();
}

class _ClienteListScreenState extends State<ClienteListScreen>
    with TickerProviderStateMixin {
  final ClienteService _clienteService = ClienteService();
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<ClienteModel> _clientes = [];
  List<ClienteModel> _filteredClientes = [];
  bool _isLoading = true;
  String _selectedFilter = 'todos';
  String _selectedDocumentFilter = 'todos';

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadClientes();
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

  Future<void> _loadClientes() async {
    try {
      setState(() => _isLoading = true);

      List<ClienteModel> clientes;
      switch (_selectedFilter) {
        case 'activos':
          clientes = await _clienteService.getActiveClients();
          break;
        case 'inactivos':
          clientes = await _clienteService.getInactiveClients();
          break;
        default:
          clientes = await _clienteService.getAllClients();
      }

      setState(() {
        _clientes = clientes;
        _filteredClientes = clientes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Error al cargar clientes: $e');
    }
  }

  void _filterClientes(String query) {
    setState(() {
      if (query.isEmpty && _selectedDocumentFilter == 'todos') {
        _filteredClientes = _clientes;
      } else {
        _filteredClientes = _clientes.where((cliente) {
          bool matchesQuery =
              query.isEmpty ||
              cliente.nombreCompleto.toLowerCase().contains(
                query.toLowerCase(),
              ) ||
              cliente.nroDocumento.contains(query) ||
              (cliente.email?.toLowerCase().contains(query.toLowerCase()) ??
                  false);

          bool matchesDocumentType =
              _selectedDocumentFilter == 'todos' ||
              cliente.tipoDocumento == _selectedDocumentFilter;

          return matchesQuery && matchesDocumentType;
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
        currentRoute: AppConstants.clientesRoute,
        onRouteSelected: (route) {
          Navigator.pop(context);
          if (route != AppConstants.clientesRoute) {
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
              _buildClientStats(),
              Expanded(child: _buildClientList()),
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
                'Clientes',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Bienvenido, Admin',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            onPressed: _loadClientes,
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
                  onChanged: _filterClientes,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Buscar por nombre, documento o email...',
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
                              _filterClientes('');
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
                  const SizedBox(width: 10),
                  Expanded(child: _buildFilterChip('Activos', 'activos')),
                  const SizedBox(width: 10),
                  Expanded(child: _buildFilterChip('Inactivos', 'inactivos')),
                ],
              ),

              const SizedBox(height: 15),

              // Filtros de tipo de documento
              Row(
                children: [
                  Expanded(child: _buildDocumentFilterChip('Todos', 'todos')),
                  const SizedBox(width: 8),
                  Expanded(child: _buildDocumentFilterChip('DNI', 'DNI')),
                  const SizedBox(width: 8),
                  Expanded(child: _buildDocumentFilterChip('RUC', 'RUC')),
                  const SizedBox(width: 8),
                  Expanded(child: _buildDocumentFilterChip('CE', 'CE')),
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
        _loadClientes();
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
            color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildDocumentFilterChip(String label, String value) {
    final isSelected = _selectedDocumentFilter == value;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedDocumentFilter = value);
        _filterClientes(_searchController.text);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [AppColors.accent, AppColors.info],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(16),
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

  Widget _buildClientStats() {
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
              _buildStatItem('Total', _clientes.length, Icons.group),
              _buildStatItem(
                'Activos',
                _clientes.where((c) => c.isActivo).length,
                Icons.check_circle,
              ),
              _buildStatItem(
                'Inactivos',
                _clientes.where((c) => !c.isActivo).length,
                Icons.cancel,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, int value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(height: 4),
        Text(
          value.toString(),
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildClientList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_filteredClientes.isEmpty) {
      return _buildEmptyState();
    }

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: _filteredClientes.length,
          itemBuilder: (context, index) {
            final cliente = _filteredClientes[index];
            return TweenAnimationBuilder<double>(
              duration: Duration(milliseconds: 300 + (index * 100)),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset((1 - value) * 50, 0),
                  child: Opacity(
                    opacity: value,
                    child: ClienteCard(
                      cliente: cliente,
                      onTap: () {
                        AppRoutes.navigateToClienteDetail(context, cliente);
                      },
                      onView: () {
                        AppRoutes.navigateToClienteDetail(context, cliente);
                      },
                      onEdit: () {
                        AppRoutes.navigateToClienteForm(
                          context,
                          cliente: cliente,
                        );
                      },
                      onDelete: () {
                        _showDeleteRestoreDialog(cliente);
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
          const Icon(Icons.people_outline, size: 80, color: AppColors.textHint),
          const SizedBox(height: 16),
          const Text(
            'No hay clientes disponibles',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Agrega tu primer cliente para comenzar',
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
          AppRoutes.navigateToClienteForm(context);
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: const Icon(Icons.add, color: AppColors.textPrimary, size: 28),
      ),
    );
  }

  void _showDeleteRestoreDialog(ClienteModel cliente) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        title: Text(
          cliente.isActivo ? 'Eliminar Cliente' : 'Restaurar Cliente',
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          cliente.isActivo
              ? '¿Estás seguro de que deseas eliminar a ${cliente.nombreCompleto}?'
              : '¿Estás seguro de que deseas restaurar a ${cliente.nombreCompleto}?',
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
              _deleteOrRestoreClient(cliente);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: cliente.isActivo
                  ? AppColors.error
                  : AppColors.success,
            ),
            child: Text(
              cliente.isActivo ? 'Eliminar' : 'Restaurar',
              style: const TextStyle(color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteOrRestoreClient(ClienteModel cliente) async {
    try {
      if (cliente.isActivo) {
        await _clienteService.deleteLogical(cliente.clienteID!);
        _showSuccessSnackBar('Cliente eliminado exitosamente');
      } else {
        await _clienteService.restoreClient(cliente.clienteID!);
        _showSuccessSnackBar('Cliente restaurado exitosamente');
      }
      _loadClientes();
    } catch (e) {
      _showErrorSnackBar('Error: $e');
    }
  }

  void _navigateToRoute(String route) {
    switch (route) {
      case AppConstants.homeRoute:
        AppRoutes.navigateToHome(context);
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
