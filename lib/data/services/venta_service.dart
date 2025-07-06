import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/venta_model.dart';

class VentaService {
  static const String _baseUrl = 'http://localhost:8080/v1/api/ventas';
  static const Map<String, String> _headers = {
    'Content-Type': 'application/json; charset=UTF-8',
  };

  Future<List<VentaModel>> getAllVentas() async {
    final response = await http.get(Uri.parse(_baseUrl));
    if (response.statusCode == 200) {
      final List jsonResponse = json.decode(response.body);
      return jsonResponse.map((item) => VentaModel.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load ventas');
    }
  }

  Future<List<VentaModel>> getActiveVentas() async {
    final response = await http.get(Uri.parse('$_baseUrl/active'));
    if (response.statusCode == 200) {
      final List jsonResponse = json.decode(response.body);
      return jsonResponse.map((item) => VentaModel.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load active ventas');
    }
  }

  Future<List<VentaModel>> getInactiveVentas() async {
    final response = await http.get(Uri.parse('$_baseUrl/inactive'));
    if (response.statusCode == 200) {
      final List jsonResponse = json.decode(response.body);
      return jsonResponse.map((item) => VentaModel.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load inactive ventas');
    }
  }

  Future<VentaModel?> getVentaById(int id) async {
    final response = await http.get(Uri.parse('$_baseUrl/$id'));
    if (response.statusCode == 200) {
      return VentaModel.fromJson(json.decode(response.body));
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Failed to load venta');
    }
  }

  Future<VentaModel> createVenta(VentaModel venta) async {
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: _headers,
      body: jsonEncode(venta.toJson()),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return VentaModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create venta');
    }
  }

  Future<VentaModel> updateVenta(int id, VentaModel venta) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/$id'),
      headers: _headers,
      body: jsonEncode(venta.toJson()),
    );
    if (response.statusCode == 200) {
      return VentaModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update venta');
    }
  }

  Future<void> deleteLogicalVenta(int id) async {
    final response = await http.patch(Uri.parse('$_baseUrl/delete/$id'));
    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Failed to logically delete venta');
    }
  }

  Future<void> restoreVenta(int id) async {
    final response = await http.patch(Uri.parse('$_baseUrl/restore/$id'));
    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Failed to restore venta');
    }
  }
}
