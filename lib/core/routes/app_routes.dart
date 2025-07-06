import 'package:flutter/material.dart';
import '../../presentation/screens/login/login_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/cliente/cliente_list_screen.dart';
import '../../presentation/screens/cliente/cliente_form_screen.dart';
import '../../presentation/screens/cliente/cliente_detail_screen.dart';
import '../../presentation/screens/producto/producto_list_screen.dart';
import '../../presentation/screens/producto/producto_form_screen.dart';
import '../../presentation/screens/producto/producto_detail_screen.dart';
import '../../presentation/screens/supplier/supplier_list_screen.dart';
import '../../presentation/screens/supplier/supplier_form_screen.dart';
import '../../presentation/screens/supplier/supplier_detail_screen.dart';
import '../../presentation/screens/venta/venta_list_screen.dart';
import '../../presentation/screens/venta/venta_form_screen.dart';
import '../../presentation/screens/venta/venta_detail_screen.dart';
import '../../presentation/screens/compra/compra_list_screen.dart';
import '../../presentation/screens/compra/compra_form_screen.dart';
import '../../presentation/screens/compra/compra_detail_screen.dart';

import '../../data/models/cliente_model.dart';
import '../../data/models/producto_model.dart';
import '../../data/models/supplier_model.dart';
import '../../data/models/venta_model.dart';
import '../../data/models/compra_model.dart';
import '../constants/app_constants.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> get routes {
    return {
      AppConstants.loginRoute: (context) => const LoginScreen(),
      AppConstants.homeRoute: (context) => const HomeScreen(),
      AppConstants.clientesRoute: (context) => const ClienteListScreen(),
      // Productos
      '/productos': (context) => const ProductoListScreen(),
      '/producto-form': (context) => const ProductoFormScreen(),
      // Proveedores
      '/suppliers': (context) => const SupplierListScreen(),
      '/supplier-form': (context) => const SupplierFormScreen(),
      // Ventas
      '/ventas': (context) => const VentaListScreen(),
      '/venta-form': (context) => const VentaFormScreen(),
      // Compras
      '/compras': (context) => const CompraListScreen(),
      '/compra-form': (context) => const CompraFormScreen(),
    };
  }

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppConstants.clienteFormRoute:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (context) => ClienteFormScreen(
            cliente: args?['cliente'] as ClienteModel?,
            isEditing: args?['isEditing'] as bool? ?? false,
          ),
        );

      case AppConstants.clienteDetailRoute:
        final cliente = settings.arguments as ClienteModel;
        return MaterialPageRoute(
          builder: (context) => ClienteDetailScreen(cliente: cliente),
        );
      // Producto
      case '/producto-form':
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (context) => ProductoFormScreen(
            producto: args?['producto'] as ProductoModel?,
            isEditing: args?['isEditing'] as bool? ?? false,
          ),
        );
      case '/producto-detail':
        final producto = settings.arguments as ProductoModel;
        return MaterialPageRoute(
          builder: (context) => ProductoDetailScreen(producto: producto),
        );
      // Supplier
      case '/supplier-form':
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (context) => SupplierFormScreen(
            supplier: args?['supplier'] as SupplierModel?,
            isEditing: args?['isEditing'] as bool? ?? false,
          ),
        );
      case '/supplier-detail':
        final supplier = settings.arguments as SupplierModel;
        return MaterialPageRoute(
          builder: (context) => SupplierDetailScreen(supplier: supplier),
        );
      // Venta
      case '/venta-form':
        return MaterialPageRoute(builder: (context) => const VentaFormScreen());
      case '/venta-detail':
        final venta = settings.arguments as VentaModel;
        return MaterialPageRoute(
          builder: (context) => VentaDetailScreen(venta: venta),
        );
      // Compra
      case '/compra-form':
        return MaterialPageRoute(
          builder: (context) => const CompraFormScreen(),
        );
      case '/compra-detail':
        final compra = settings.arguments as CompraModel;
        return MaterialPageRoute(
          builder: (context) => CompraDetailScreen(compra: compra),
        );
      default:
        return MaterialPageRoute(
          builder: (context) =>
              const Scaffold(body: Center(child: Text('Página no encontrada'))),
        );
    }
  }

  static void navigateToClientes(BuildContext context) {
    Navigator.pushNamed(context, AppConstants.clientesRoute);
  }

  static void navigateToClienteForm(
    BuildContext context, {
    ClienteModel? cliente,
  }) {
    Navigator.pushNamed(
      context,
      AppConstants.clienteFormRoute,
      arguments: {'cliente': cliente, 'isEditing': cliente != null},
    );
  }

  static void navigateToClienteDetail(
    BuildContext context,
    ClienteModel cliente,
  ) {
    Navigator.pushNamed(
      context,
      AppConstants.clienteDetailRoute,
      arguments: cliente,
    );
  }

  static void navigateToHome(BuildContext context) {
    Navigator.pushReplacementNamed(context, AppConstants.homeRoute);
  }

  static void navigateToLogin(BuildContext context) {
    Navigator.pushReplacementNamed(context, AppConstants.loginRoute);
  }

  static void navigateToProductos(BuildContext context) {
    Navigator.pushNamed(context, '/productos');
  }

  static void navigateToProductoForm(
    BuildContext context, {
    ProductoModel? producto,
  }) {
    Navigator.pushNamed(
      context,
      '/producto-form',
      arguments: {'producto': producto, 'isEditing': producto != null},
    );
  }

  static void navigateToProductoDetail(
    BuildContext context,
    ProductoModel producto,
  ) {
    Navigator.pushNamed(context, '/producto-detail', arguments: producto);
  }

  static void navigateToSuppliers(BuildContext context) {
    Navigator.pushNamed(context, '/suppliers');
  }

  static void navigateToSupplierForm(
    BuildContext context, {
    SupplierModel? supplier,
  }) {
    Navigator.pushNamed(
      context,
      '/supplier-form',
      arguments: {'supplier': supplier, 'isEditing': supplier != null},
    );
  }

  static void navigateToSupplierDetail(
    BuildContext context,
    SupplierModel supplier,
  ) {
    Navigator.pushNamed(context, '/supplier-detail', arguments: supplier);
  }

  static void navigateToVentas(BuildContext context) {
    Navigator.pushNamed(context, '/ventas');
  }

  static void navigateToVentaForm(BuildContext context) {
    Navigator.pushNamed(context, '/venta-form');
  }

  static void navigateToVentaDetail(BuildContext context, VentaModel venta) {
    Navigator.pushNamed(context, '/venta-detail', arguments: venta);
  }

  static void navigateToCompras(BuildContext context) {
    Navigator.pushNamed(context, '/compras');
  }

  static void navigateToCompraForm(BuildContext context) {
    Navigator.pushNamed(context, '/compra-form');
  }

  static void navigateToCompraDetail(BuildContext context, CompraModel compra) {
    Navigator.pushNamed(context, '/compra-detail', arguments: compra);
  }
}
