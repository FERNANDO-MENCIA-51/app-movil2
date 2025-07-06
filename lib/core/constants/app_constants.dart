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
  static const String pedidosRoute = '/pedidos';
  static const String inventarioRoute = '/inventario';
  static const String reportesRoute = '/reportes';
  static const String configuracionRoute = '/configuracion';
}
