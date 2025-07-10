import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/compra_model.dart';
import '../services/auth_service.dart';

class CompraService {
  static const String _baseUrl = 'http://192.168.0.106:8080/v1/api/compras';
  final AuthService _authService = AuthService();

  // Obtener todas las compras (puede requerir token según tu backend)
  Future<List<CompraModel>> getAllCompras() async {
    final token = await _authService.getToken();
    final response = await http.get(
      Uri.parse(_baseUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      final List<dynamic> jsonList = decoded is List
          ? decoded
          : (decoded['data'] ?? decoded['compras'] ?? []);
      return jsonList.map((item) => CompraModel.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load compras: ${response.statusCode}');
    }
  }

  // Obtener solo compras activas
  Future<List<CompraModel>> getActiveCompras() async {
    final token = await _authService.getToken();
    final response = await http.get(
      Uri.parse('$_baseUrl/active'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse.map((item) => CompraModel.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load active compras: ${response.statusCode}');
    }
  }

  // Obtener solo compras inactivas
  Future<List<CompraModel>> getInactiveCompras() async {
    final token = await _authService.getToken();
    final response = await http.get(
      Uri.parse('$_baseUrl/inactive'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse.map((item) => CompraModel.fromJson(item)).toList();
    } else {
      throw Exception(
        'Failed to load inactive compras: ${response.statusCode}',
      );
    }
  }

  // Obtener una compra por ID
  Future<CompraModel?> getCompraById(int id) async {
    final token = await _authService.getToken();
    final response = await http.get(
      Uri.parse('$_baseUrl/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    if (response.statusCode == 200) {
      return CompraModel.fromJson(json.decode(response.body));
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Failed to load compra: ${response.statusCode}');
    }
  }

  // Crear una nueva compra
  Future<CompraModel> createCompra(CompraModel compra) async {
    final token = await _authService.getToken();
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(compra.toJson()),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return CompraModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create compra: ${response.statusCode}');
    }
  }

  // Actualizar una compra existente
  Future<CompraModel> updateCompra(int id, CompraModel compra) async {
    final token = await _authService.getToken();
    final response = await http.put(
      Uri.parse('$_baseUrl/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(compra.toJson()),
    );
    if (response.statusCode == 200) {
      return CompraModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update compra: ${response.statusCode}');
    }
  }

  // Eliminación lógica de una compra
  Future<void> deleteLogicalCompra(int id) async {
    final token = await _authService.getToken();
    final response = await http.patch(
      Uri.parse('$_baseUrl/delete/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception(
        'Failed to logically delete compra: ${response.statusCode}',
      );
    }
  }

  // Restaurar una compra
  Future<void> restoreCompra(int id) async {
    final token = await _authService.getToken();
    final response = await http.patch(
      Uri.parse('$_baseUrl/restore/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Failed to restore compra: ${response.statusCode}');
    }
  }
}
