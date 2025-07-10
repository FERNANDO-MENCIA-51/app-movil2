import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/compra_detalle_model.dart';

class CompraDetalleService {
  static const String _baseUrl =
      'http://192.168.0.106:8080/v1/api/compra-detalle';
  static const Map<String, String> _headers = {
    'Content-Type': 'application/json; charset=UTF-8',
  };

  Future<List<CompraDetalleModel>> getActiveCompraDetalles() async {
    final response = await http.get(Uri.parse('$_baseUrl/active'));
    if (response.statusCode == 200) {
      final List jsonResponse = json.decode(response.body);
      return jsonResponse
          .map((item) => CompraDetalleModel.fromJson(item))
          .toList();
    } else {
      throw Exception(
        'Failed to load active compra detalles: ${response.statusCode}',
      );
    }
  }

  Future<List<CompraDetalleModel>> getInactiveCompraDetalles() async {
    final response = await http.get(Uri.parse('$_baseUrl/inactive'));
    if (response.statusCode == 200) {
      final List jsonResponse = json.decode(response.body);
      return jsonResponse
          .map((item) => CompraDetalleModel.fromJson(item))
          .toList();
    } else {
      throw Exception(
        'Failed to load inactive compra detalles: ${response.statusCode}',
      );
    }
  }

  Future<CompraDetalleModel?> getCompraDetalleById(int id) async {
    final response = await http.get(Uri.parse('$_baseUrl/$id'));
    if (response.statusCode == 200) {
      return CompraDetalleModel.fromJson(json.decode(response.body));
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Failed to load compra detalle: ${response.statusCode}');
    }
  }

  Future<CompraDetalleModel> createCompraDetalle(
    CompraDetalleModel detalle,
  ) async {
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: _headers,
      body: jsonEncode(detalle.toJson()),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return CompraDetalleModel.fromJson(json.decode(response.body));
    } else {
      throw Exception(
        'Failed to create compra detalle: ${response.statusCode}',
      );
    }
  }

  Future<CompraDetalleModel> updateCompraDetalle(
    int id,
    CompraDetalleModel detalle,
  ) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/$id'),
      headers: _headers,
      body: jsonEncode(detalle.toJson()),
    );
    if (response.statusCode == 200) {
      return CompraDetalleModel.fromJson(json.decode(response.body));
    } else {
      throw Exception(
        'Failed to update compra detalle: ${response.statusCode}',
      );
    }
  }

  Future<void> deleteLogicalCompraDetalle(int id) async {
    final response = await http.patch(
      Uri.parse('$_baseUrl/delete/$id'),
      headers: _headers,
    );
    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception(
        'Failed to logically delete compra detalle: ${response.statusCode}',
      );
    }
  }

  Future<void> restoreCompraDetalle(int id) async {
    final response = await http.patch(
      Uri.parse('$_baseUrl/restore/$id'),
      headers: _headers,
    );
    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception(
        'Failed to restore compra detalle: ${response.statusCode}',
      );
    }
  }
}
