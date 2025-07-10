import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/supplier_model.dart';
import '../services/auth_service.dart';

class SupplierService {
  // Reemplaza con la URL base de tu backend
  static const String _baseUrl = 'http://192.168.0.106:8080/v1/api/suppliers';
  final AuthService _authService = AuthService();

  // Headers por defecto
  static const Map<String, String> _headers = {
    'Content-Type': 'application/json; charset=UTF-8',
  };

  /// Método para obtener todos los proveedores (activos e inactivos)
  Future<List<SupplierModel>> getAllSuppliers() async {
    try {
      final token = await _authService.getToken();
      final response = await http.get(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse
            .map((item) => SupplierModel.fromJson(item))
            .toList();
      } else {
        throw Exception('Failed to load suppliers: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error connecting to server: $e');
    }
  }

  /// Método para obtener solo proveedores activos
  Future<List<SupplierModel>> getActiveSuppliers() async {
    final token = await _authService.getToken();
    final response = await http.get(
      Uri.parse('$_baseUrl/active'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final List jsonResponse = json.decode(response.body);
      return jsonResponse.map((item) => SupplierModel.fromJson(item)).toList();
    } else {
      throw Exception(
        'Failed to load active suppliers: ${response.statusCode}',
      );
    }
  }

  /// Método para obtener solo proveedores inactivos
  Future<List<SupplierModel>> getInactiveSuppliers() async {
    try {
      final token = await _authService.getToken();
      final response = await http.get(
        Uri.parse('$_baseUrl/inactive'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse
            .map((item) => SupplierModel.fromJson(item))
            .toList();
      } else {
        throw Exception(
          'Failed to load inactive suppliers: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error connecting to server: $e');
    }
  }

  /// Método para obtener un proveedor por su ID
  Future<SupplierModel?> getSupplierById(int id) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/$id'));

      if (response.statusCode == 200) {
        return SupplierModel.fromJson(json.decode(response.body));
      } else if (response.statusCode == 404) {
        return null; // Supplier not found
      } else {
        throw Exception('Failed to load supplier: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error connecting to server: $e');
    }
  }

  /// Método para buscar proveedores por nombre
  Future<List<SupplierModel>> searchSuppliersByName(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/search?q=${Uri.encodeComponent(query)}'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse
            .map((item) => SupplierModel.fromJson(item))
            .toList();
      } else {
        throw Exception('Failed to search suppliers: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error connecting to server: $e');
    }
  }

  /// Método para crear un nuevo proveedor
  Future<SupplierModel> createSupplier(SupplierModel supplier) async {
    try {
      // Validar datos antes de enviar
      final errors = supplier.validate();
      if (errors.isNotEmpty) {
        throw Exception('Validation errors: ${errors.join(', ')}');
      }

      final token = await _authService.getToken();
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {..._headers, 'Authorization': 'Bearer $token'},
        body: jsonEncode(supplier.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return SupplierModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create supplier: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating supplier: $e');
    }
  }

  /// Método para actualizar un proveedor existente
  Future<SupplierModel> updateSupplier(int id, SupplierModel supplier) async {
    try {
      // Validar datos antes de enviar
      final errors = supplier.validate();
      if (errors.isNotEmpty) {
        throw Exception('Validation errors: ${errors.join(', ')}');
      }

      final token = await _authService.getToken();
      final response = await http.put(
        Uri.parse('$_baseUrl/$id'),
        headers: {..._headers, 'Authorization': 'Bearer $token'},
        body: jsonEncode(supplier.toJson()),
      );

      if (response.statusCode == 200) {
        return SupplierModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to update supplier: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating supplier: $e');
    }
  }

  /// Método para eliminación lógica (cambiar estado a 'inactivo')
  Future<void> deleteLogicalSupplier(int id) async {
    try {
      final token = await _authService.getToken();
      final response = await http.patch(
        Uri.parse('$_baseUrl/delete/$id'),
        headers: {..._headers, 'Authorization': 'Bearer $token'},
      );

      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception(
          'Failed to logically delete supplier: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error deleting supplier: $e');
    }
  }

  /// Método para restaurar proveedor (cambiar estado a 'activo')
  Future<void> restoreSupplier(int id) async {
    try {
      final token = await _authService.getToken();
      final response = await http.patch(
        Uri.parse('$_baseUrl/restore/$id'),
        headers: {..._headers, 'Authorization': 'Bearer $token'},
      );

      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception('Failed to restore supplier: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error restoring supplier: $e');
    }
  }

  /// Método para obtener estadísticas de proveedores
  Future<Map<String, dynamic>> getSupplierStats() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/stats'));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
          'Failed to load supplier stats: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error loading stats: $e');
    }
  }

  /// Método para obtener proveedores paginados
  Future<Map<String, dynamic>> getSuppliersPaginated({
    int page = 1,
    int limit = 10,
    String? search,
    String? estado,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      if (estado != null && estado.isNotEmpty) {
        queryParams['estado'] = estado;
      }

      final uri = Uri.parse(
        '$_baseUrl/paginated',
      ).replace(queryParameters: queryParams);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'suppliers': (data['suppliers'] as List)
              .map((item) => SupplierModel.fromJson(item))
              .toList(),
          'total': data['total'],
          'page': data['page'],
          'limit': data['limit'],
          'totalPages': data['totalPages'],
        };
      } else {
        throw Exception(
          'Failed to load paginated suppliers: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error loading paginated suppliers: $e');
    }
  }
}
