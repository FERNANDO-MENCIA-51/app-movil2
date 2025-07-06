import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/producto_model.dart';

class ProductoService {
  // Reemplaza con la URL base de tu backend
  static const String _baseUrl = 'http://localhost:8080/v1/api/productos';
  
  // Headers por defecto
  static const Map<String, String> _headers = {
    'Content-Type': 'application/json; charset=UTF-8',
  };

  /// Método para obtener todos los productos (activos e inactivos)
  Future<List<ProductoModel>> getAllProductos() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl));

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse.map((item) => ProductoModel.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error connecting to server: $e');
    }
  }

  /// Método para obtener solo productos activos
  Future<List<ProductoModel>> getActiveProductos() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/active'));

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse.map((item) => ProductoModel.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load active products: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error connecting to server: $e');
    }
  }

  /// Método para obtener solo productos inactivos
  Future<List<ProductoModel>> getInactiveProductos() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/inactive'));

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse.map((item) => ProductoModel.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load inactive products: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error connecting to server: $e');
    }
  }

  /// Método para obtener productos con stock bajo
  Future<List<ProductoModel>> getLowStockProductos() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/low-stock'));

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse.map((item) => ProductoModel.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load low stock products: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error connecting to server: $e');
    }
  }

  /// Método para obtener un producto por su ID
  Future<ProductoModel?> getProductoById(int id) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/$id'));

      if (response.statusCode == 200) {
        return ProductoModel.fromJson(json.decode(response.body));
      } else if (response.statusCode == 404) {
        return null; // Producto not found
      } else {
        throw Exception('Failed to load product: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error connecting to server: $e');
    }
  }

  /// Método para buscar productos por nombre
  Future<List<ProductoModel>> searchProductosByName(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/search?q=${Uri.encodeComponent(query)}'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse.map((item) => ProductoModel.fromJson(item)).toList();
      } else {
        throw Exception('Failed to search products: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error connecting to server: $e');
    }
  }

  /// Método para obtener productos por categoría
  Future<List<ProductoModel>> getProductosByCategoria(String categoria) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/categoria/${Uri.encodeComponent(categoria)}'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse.map((item) => ProductoModel.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load products by category: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error connecting to server: $e');
    }
  }

  /// Método para crear un nuevo producto
  Future<ProductoModel> createProducto(ProductoModel producto) async {
    try {
      // Validar datos antes de enviar
      final errors = producto.validate();
      if (errors.isNotEmpty) {
        throw Exception('Validation errors: ${errors.join(', ')}');
      }

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: _headers,
        body: jsonEncode(producto.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ProductoModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create product: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating product: $e');
    }
  }

  /// Método para actualizar un producto existente
  Future<ProductoModel> updateProducto(int id, ProductoModel producto) async {
    try {
      // Validar datos antes de enviar
      final errors = producto.validate();
      if (errors.isNotEmpty) {
        throw Exception('Validation errors: ${errors.join(', ')}');
      }

      final response = await http.put(
        Uri.parse('$_baseUrl/$id'),
        headers: _headers,
        body: jsonEncode(producto.toJson()),
      );

      if (response.statusCode == 200) {
        return ProductoModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to update product: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating product: $e');
    }
  }

  /// Método para actualizar stock de un producto
  Future<ProductoModel> updateStock(int id, int newStock) async {
    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl/$id/stock'),
        headers: _headers,
        body: jsonEncode({'stock': newStock}),
      );

      if (response.statusCode == 200) {
        return ProductoModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to update stock: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating stock: $e');
    }
  }

  /// Método para eliminación lógica (cambiar estatus a 'inactivo')
  Future<void> deleteLogicalProducto(int id) async {
    try {
      final response = await http.patch(Uri.parse('$_baseUrl/delete/$id'));

      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception('Failed to logically delete product: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting product: $e');
    }
  }

  /// Método para restaurar producto (cambiar estatus a 'activo')
  Future<void> restoreProducto(int id) async {
    try {
      final response = await http.patch(Uri.parse('$_baseUrl/restore/$id'));

      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception('Failed to restore product: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error restoring product: $e');
    }
  }

  /// Método para verificar si un código de barra ya existe
  Future<bool> codeBarraExists(String codeBarra, {int? excludeId}) async {
    try {
      final uri = Uri.parse('$_baseUrl/check-code-barra').replace(queryParameters: {
        'codeBarra': codeBarra,
        if (excludeId != null) 'excludeId': excludeId.toString(),
      });

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['exists'] == true;
      } else {
        throw Exception('Failed to check code barra: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error checking code barra: $e');
    }
  }

  /// Método para obtener estadísticas de productos
  Future<Map<String, dynamic>> getProductStats() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/stats'));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load product stats: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading stats: $e');
    }
  }

  /// Método para obtener productos paginados
  Future<Map<String, dynamic>> getProductosPaginated({
    int page = 1,
    int limit = 10,
    String? search,
    String? categoria,
    String? estatus,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      if (categoria != null && categoria.isNotEmpty) {
        queryParams['categoria'] = categoria;
      }

      if (estatus != null && estatus.isNotEmpty) {
        queryParams['estatus'] = estatus;
      }

      final uri = Uri.parse('$_baseUrl/paginated').replace(queryParameters: queryParams);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'products': (data['products'] as List)
              .map((item) => ProductoModel.fromJson(item))
              .toList(),
          'total': data['total'],
          'page': data['page'],
          'limit': data['limit'],
          'totalPages': data['totalPages'],
        };
      } else {
        throw Exception('Failed to load paginated products: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading paginated products: $e');
    }
  }
}
