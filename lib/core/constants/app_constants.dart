class AppConstants {
  // Información de la app
  static const String appName = 'Mi App';
  static const String appVersion = '1.0.0';

  // Dimensiones
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;

  // Bordes redondeados
  static const double defaultRadius = 8.0;
  static const double smallRadius = 4.0;
  static const double largeRadius = 16.0;

  // Elevaciones
  static const double defaultElevation = 2.0;
  static const double smallElevation = 1.0;
  static const double largeElevation = 8.0;

  // Duraciones de animación
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Rutas de navegación
  static const String homeRoute = '/home';
  static const String loginRoute = '/login';
  static const String clientesRoute = '/clientes';
  static const String clienteFormRoute = '/cliente-form';
  static const String clienteDetailRoute = '/cliente-detail';
  static const String productosRoute = '/productos';
  static const String productoFormRoute = '/producto-form';
  static const String productoDetailRoute = '/producto-detail';
  static const String comprasRoute = '/compras';
  static const String compraFormRoute = '/compra-form';
  static const String compraDetailRoute = '/compra-detail';
  static const String ventasRoute = '/ventas';
  static const String ventaFormRoute = '/venta-form';
  static const String ventaDetailRoute = '/venta-detail';
  static const String suppliersRoute = '/suppliers';
  static const String supplierFormRoute = '/supplier-form';
  static const String supplierDetailRoute = '/supplier-detail';

  static const String settingsRoute = '/settings';
}
