import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/producto_model.dart';
import '../../providers/auth_provider.dart';

class ProductoService {
  static const String _baseUrl = 'http://192.168.0.106:8080/v1/api/productos';

  static const Map<String, String> _headers = {
    'Content-Type': 'application/json; charset=UTF-8',
  };

  Future<List<ProductoModel>> getAllProductos(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final String? token = authProvider.token;
    if (token == null || token.isEmpty) {
      throw Exception('No hay sesión activa. Por favor, inicia sesión.');
    }
    final response = await http.get(
      Uri.parse(_baseUrl),
      headers: {..._headers, 'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      final List<dynamic> jsonList = decoded is List
          ? decoded
          : (decoded['data'] ?? decoded['productos'] ?? []);
      return jsonList.map((item) => ProductoModel.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load products: ${response.statusCode}');
    }
  }

  Future<List<ProductoModel>> getActiveProductos(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final String? token = authProvider.token;
    if (token == null || token.isEmpty) {
      throw Exception('No hay sesión activa. Por favor, inicia sesión.');
    }
    final response = await http.get(
      Uri.parse('$_baseUrl/active'),
      headers: {..._headers, 'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      final List<dynamic> jsonList = decoded is List
          ? decoded
          : (decoded['data'] ?? decoded['productos'] ?? []);
      return jsonList.map((item) => ProductoModel.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load active products: ${response.statusCode}');
    }
  }

  Future<List<ProductoModel>> getInactiveProductos(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final String? token = authProvider.token;
    if (token == null || token.isEmpty) {
      throw Exception('No hay sesión activa. Por favor, inicia sesión.');
    }
    final response = await http.get(
      Uri.parse('$_baseUrl/inactive'),
      headers: {..._headers, 'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      final List<dynamic> jsonList = decoded is List
          ? decoded
          : (decoded['data'] ?? decoded['productos'] ?? []);
      return jsonList.map((item) => ProductoModel.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load inactive products: ${response.statusCode}');
    }
  }

  Future<List<ProductoModel>> getLowStockProductos(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final String? token = authProvider.token;
    if (token == null || token.isEmpty) {
      throw Exception('No hay sesión activa. Por favor, inicia sesión.');
    }
    final response = await http.get(
      Uri.parse('$_baseUrl/low-stock'),
      headers: {..._headers, 'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      final List<dynamic> jsonList = decoded is List
          ? decoded
          : (decoded['data'] ?? decoded['productos'] ?? []);
      return jsonList.map((item) => ProductoModel.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load low stock products: ${response.statusCode}');
    }
  }

  Future<ProductoModel> createProducto(
    ProductoModel producto, {
    required BuildContext context,
  }) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final String? token = authProvider.token;
    if (token == null || token.isEmpty) {
      throw Exception('No hay sesión activa. Por favor, inicia sesión.');
    }
    final errors = producto.validate();
    if (errors.isNotEmpty) {
      throw Exception('Validation errors: ${errors.join(', ')}');
    }
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {..._headers, 'Authorization': 'Bearer $token'},
      body: jsonEncode(producto.toJson()),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return ProductoModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create product: ${response.statusCode}');
    }
  }

  Future<void> restoreProducto(
    int id, {
    required BuildContext context,
  }) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final String? token = authProvider.token;
    if (token == null || token.isEmpty) {
      throw Exception('No hay sesión activa. Por favor, inicia sesión.');
    }
    final response = await http.patch(
      Uri.parse('$_baseUrl/restore/$id'),
      headers: {..._headers, 'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception(
        'Failed to restore product: ${response.statusCode}',
      );
    }
  }

  Future<void> updateProducto(
    int id,
    ProductoModel producto, {
    required BuildContext context,
  }) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final String? token = authProvider.token;
    if (token == null || token.isEmpty) {
      throw Exception('No hay sesión activa. Por favor, inicia sesión.');
    }
    final errors = producto.validate();
    if (errors.isNotEmpty) {
      throw Exception('Validation errors: ${errors.join(', ')}');
    }
    final response = await http.put(
      Uri.parse('$_baseUrl/$id'),
      headers: {..._headers, 'Authorization': 'Bearer $token'},
      body: jsonEncode(producto.toJson()),
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to update product: ${response.statusCode}');
    }
  }

  Future<void> deleteLogicalProducto(
    int id, {
    required BuildContext context,
  }) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final String? token = authProvider.token;
    if (token == null || token.isEmpty) {
      throw Exception('No hay sesión activa. Por favor, inicia sesión.');
    }
    final response = await http.patch(
      Uri.parse('$_baseUrl/delete/$id'),
      headers: {..._headers, 'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception(
        'Failed to logically delete product: ${response.statusCode}',
      );
    }
  }
}