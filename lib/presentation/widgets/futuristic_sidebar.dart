import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';

class FuturisticSidebar extends StatefulWidget {
  final String currentRoute;
  final Function(String) onRouteSelected;

  const FuturisticSidebar({
    super.key,
    required this.currentRoute,
    required this.onRouteSelected,
  });

  @override
  State<FuturisticSidebar> createState() => _FuturisticSidebarState();
}

class _FuturisticSidebarState extends State<FuturisticSidebar>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  final List<SidebarItem> _menuItems = [
    SidebarItem(
      icon: Icons.dashboard,
      title: 'Dashboard',
      route: AppConstants.homeRoute,
    ),
    SidebarItem(
      icon: Icons.people,
      title: 'Clientes',
      route: AppConstants.clientesRoute,
    ),
    SidebarItem(
      icon: Icons.inventory_2,
      title: 'Productos',
      route: '/productos',
    ),
    SidebarItem(
      icon: Icons.business,
      title: 'Proveedores',
      route: '/suppliers',
    ),
    SidebarItem(icon: Icons.receipt_long, title: 'Ventas', route: '/ventas'),
    SidebarItem(icon: Icons.shopping_cart, title: 'Compras', route: '/compras'),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: -1.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
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
    // Obtén el usuario actual desde el AuthProvider
    final user = Provider.of<AuthProvider>(context, listen: true).currentUser;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_slideAnimation.value * 280, 0),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              width: 280,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.backgroundDark,
                    AppColors.surfaceDark,
                    AppColors.cardDark,
                  ],
                ),
                border: Border(
                  right: BorderSide(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    _buildSidebarHeader(),
                    const SizedBox(height: 30),
                    Expanded(child: _buildMenuItems()),
                    _buildSidebarFooter(user),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSidebarHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Logo animado
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.4),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.cake,
              color: AppColors.textPrimary,
              size: 40,
            ),
          ),

          const SizedBox(height: 15),

          // Título
          Text(
            'REPOSTERÍA',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            '& PASTELERÍA',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              letterSpacing: 1.2,
            ),
          ),

          const SizedBox(height: 20),

          // Línea divisoria
          Container(
            height: 1,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  AppColors.primary.withValues(alpha: 0.5),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItems() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      itemCount: _menuItems.length,
      itemBuilder: (context, index) {
        final item = _menuItems[index];
        final isSelected = widget.currentRoute == item.route;

        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 300 + (index * 100)),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset((1 - value) * 50, 0),
              child: Opacity(
                opacity: value,
                child: _buildMenuItem(item, isSelected),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMenuItem(SidebarItem item, bool isSelected) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        gradient: isSelected
            ? LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.3),
                  AppColors.secondary.withValues(alpha: 0.1),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              )
            : null,
        borderRadius: BorderRadius.circular(12),
        border: isSelected
            ? Border.all(
                color: AppColors.primary.withValues(alpha: 0.5),
                width: 1,
              )
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            // Solución: Navega usando Navigator si la ruta es diferente a la actual
            if (item.route != widget.currentRoute) {
              Navigator.of(context).pop(); // Cierra el drawer
              Navigator.of(context).pushNamed(item.route);
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? const LinearGradient(
                            colors: [AppColors.primary, AppColors.secondary],
                          )
                        : null,
                    color: isSelected ? null : AppColors.surfaceDark,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    item.icon,
                    color: isSelected
                        ? AppColors.textPrimary
                        : AppColors.textHint,
                    size: 20,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Text(
                    item.title,
                    style: TextStyle(
                      color: isSelected
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),

                if (isSelected)
                  Container(
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSidebarFooter(dynamic user) {
    // Usa solo username para mostrar el nombre
    final String nombre = user?.username ?? 'Usuario';
    final String rol = user?.rol ?? user?.role ?? 'Sin rol';

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Línea divisoria
          Container(
            height: 1,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  AppColors.primary.withValues(alpha: 0.5),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Perfil de usuario dinámico
          Row(
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.secondary, AppColors.primary],
                  ),
                  borderRadius: BorderRadius.circular(22.5),
                ),
                child: const Icon(
                  Icons.person,
                  color: AppColors.textPrimary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nombre,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      rol,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textHint,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Botón de cerrar sesión
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.error.withValues(alpha: 0.3),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  widget.onRouteSelected('/login');
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout, color: AppColors.error, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Cerrar Sesión',
                        style: TextStyle(
                          color: AppColors.error,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SidebarItem {
  final IconData icon;
  final String title;
  final String route;

  SidebarItem({required this.icon, required this.title, required this.route});
}

