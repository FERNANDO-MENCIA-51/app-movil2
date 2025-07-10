import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/compra_model.dart';
import '../models/dto/compra_request_model.dart';
import '../services/auth_service.dart';

class CompraTransaccionService {
  static const String _baseUrl =
      'http://192.168.0.106:8080/v1/api/compras-transaccion';
  final AuthService _authService = AuthService();

  /// Crear una compra completa (cabecera y detalles)
  Future<CompraModel> createCompraTransaccion(
    CompraRequestModel request,
  ) async {
    final token = await _authService.getToken();
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(request.toJson()),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return CompraModel.fromJson(json.decode(response.body));
    } else {
      throw Exception(
        'Failed to create compra transaccional: ${response.statusCode}',
      );
    }
  }

  /// Obtener todas las compras transaccionales (cabecera + detalles)
  Future<List<CompraModel>> getAllComprasTransaccion() async {
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
      throw Exception(
        'Failed to load compras transaccionales: ${response.statusCode}',
      );
    }
  }

  /// Obtener una compra completa por ID (cabecera + detalles)
  Future<CompraModel?> getCompraTransaccionById(int id) async {
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
      throw Exception(
        'Failed to load compra transaccional: ${response.statusCode}',
      );
    }
  }

  /// Actualizar una compra completa (cabecera y detalles)
  Future<CompraModel> updateCompraTransaccion(
    int id,
    CompraRequestModel request,
  ) async {
    final token = await _authService.getToken();
    final response = await http.put(
      Uri.parse('$_baseUrl/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(request.toJson()),
    );
    if (response.statusCode == 200) {
      return CompraModel.fromJson(json.decode(response.body));
    } else {
      throw Exception(
        'Failed to update compra transaccional: ${response.statusCode}',
      );
    }
  }

  /// Eliminación lógica de una compra transaccional
  Future<void> deleteLogicalCompraTransaccion(int id) async {
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
        'Failed to logically delete compra transaccional: ${response.statusCode}',
      );
    }
  }

  /// Restaurar una compra transaccional
  Future<void> restoreCompraTransaccion(int id) async {
    final token = await _authService.getToken();
    final response = await http.patch(
      Uri.parse('$_baseUrl/restore/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception(
        'Failed to restore compra transaccional: ${response.statusCode}',
      );
    }
  }
}
