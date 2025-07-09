import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/venta_detalle_model.dart';

class VentaDetalleService {
  static const String _baseUrl = 'http://192.168.0.102:8080:8080/v1/api/venta-detalle';
  static const Map<String, String> _headers = {
    'Content-Type': 'application/json; charset=UTF-8',
  };

  Future<List<VentaDetalleModel>> getActiveVentaDetalles() async {
    final response = await http.get(Uri.parse('$_baseUrl/active'));
    if (response.statusCode == 200) {
      final List jsonResponse = json.decode(response.body);
      return jsonResponse
          .map((item) => VentaDetalleModel.fromJson(item))
          .toList();
    } else {
      throw Exception('Failed to load active venta detalles');
    }
  }

  Future<List<VentaDetalleModel>> getInactiveVentaDetalles() async {
    final response = await http.get(Uri.parse('$_baseUrl/inactive'));
    if (response.statusCode == 200) {
      final List jsonResponse = json.decode(response.body);
      return jsonResponse
          .map((item) => VentaDetalleModel.fromJson(item))
          .toList();
    } else {
      throw Exception('Failed to load inactive venta detalles');
    }
  }

  Future<VentaDetalleModel?> getVentaDetalleById(int id) async {
    final response = await http.get(Uri.parse('$_baseUrl/$id'));
    if (response.statusCode == 200) {
      return VentaDetalleModel.fromJson(json.decode(response.body));
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Failed to load venta detalle');
    }
  }

  Future<VentaDetalleModel> createVentaDetalle(
    VentaDetalleModel detalle,
  ) async {
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: _headers,
      body: jsonEncode(detalle.toJson()),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return VentaDetalleModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create venta detalle');
    }
  }

  Future<VentaDetalleModel> updateVentaDetalle(
    int id,
    VentaDetalleModel detalle,
  ) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/$id'),
      headers: _headers,
      body: jsonEncode(detalle.toJson()),
    );
    if (response.statusCode == 200) {
      return VentaDetalleModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update venta detalle');
    }
  }

  Future<void> deleteLogicalVentaDetalle(int id) async {
    final response = await http.patch(Uri.parse('$_baseUrl/delete/$id'));
    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Failed to logically delete venta detalle');
    }
  }

  Future<void> restoreVentaDetalle(int id) async {
    final response = await http.patch(Uri.parse('$_baseUrl/restore/$id'));
    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Failed to restore venta detalle');
    }
  }
}
