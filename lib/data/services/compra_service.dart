import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/compra_model.dart';

class CompraService {
  static const String _baseUrl = 'http://localhost:8080/v1/api/compras';
  static const Map<String, String> _headers = {
    'Content-Type': 'application/json; charset=UTF-8',
  };

  Future<List<CompraModel>> getAllCompras() async {
    final response = await http.get(Uri.parse(_baseUrl));
    if (response.statusCode == 200) {
      final List jsonResponse = json.decode(response.body);
      return jsonResponse.map((item) => CompraModel.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load compras: ${response.statusCode}');
    }
  }

  Future<List<CompraModel>> getActiveCompras() async {
    final response = await http.get(Uri.parse('$_baseUrl/active'));
    if (response.statusCode == 200) {
      final List jsonResponse = json.decode(response.body);
      return jsonResponse.map((item) => CompraModel.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load active compras: ${response.statusCode}');
    }
  }

  Future<List<CompraModel>> getInactiveCompras() async {
    final response = await http.get(Uri.parse('$_baseUrl/inactive'));
    if (response.statusCode == 200) {
      final List jsonResponse = json.decode(response.body);
      return jsonResponse.map((item) => CompraModel.fromJson(item)).toList();
    } else {
      throw Exception(
        'Failed to load inactive compras: ${response.statusCode}',
      );
    }
  }

  Future<CompraModel?> getCompraById(int id) async {
    final response = await http.get(Uri.parse('$_baseUrl/$id'));
    if (response.statusCode == 200) {
      return CompraModel.fromJson(json.decode(response.body));
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Failed to load compra: ${response.statusCode}');
    }
  }

  Future<CompraModel> createCompra(CompraModel compra) async {
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: _headers,
      body: jsonEncode(compra.toJson()),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return CompraModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create compra: ${response.statusCode}');
    }
  }

  Future<CompraModel> updateCompra(int id, CompraModel compra) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/$id'),
      headers: _headers,
      body: jsonEncode(compra.toJson()),
    );
    if (response.statusCode == 200) {
      return CompraModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update compra: ${response.statusCode}');
    }
  }

  Future<void> deleteLogicalCompra(int id) async {
    final response = await http.patch(Uri.parse('$_baseUrl/delete/$id'));
    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception(
        'Failed to logically delete compra: ${response.statusCode}',
      );
    }
  }

  Future<void> restoreCompra(int id) async {
    final response = await http.patch(Uri.parse('$_baseUrl/restore/$id'));
    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Failed to restore compra: ${response.statusCode}');
    }
  }
}
