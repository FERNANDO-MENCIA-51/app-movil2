import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:flutter/material.dart'; // Agrega este import para BuildContext
import '../../providers/auth_provider.dart';
import '../models/dto/venta_request_model.dart';
import '../models/venta_model.dart';

class VentaTransaccionService {
  static const String _baseUrl =
      'http://192.168.0.102:8080/v1/api/ventas/transaccion';

  Future<Map<String, String>> _getHeaders() async {
    final Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
    };
    return headers;
  }

  Future<VentaModel> registrarVentaCompleta(VentaRequestModel request) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: headers,
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return VentaModel.fromJson(json.decode(response.body));
    } else {
      throw Exception(
        'Failed to register venta completa: ${response.statusCode}',
      );
    }
  }

  Future<List<VentaModel>> listarTodasLasVentas(BuildContext context) async {
    // Obtén el token desde el AuthProvider
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token; // Usa el getter correcto (token)

    final response = await http.get(
      Uri.parse('$_baseUrl/all'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => VentaModel.fromJson(e)).toList();
    } else {
      throw Exception('Error al listar ventas');
    }
  }

  Future<VentaModel?> obtenerVentaCompleta(int id) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$_baseUrl/$id'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return VentaModel.fromJson(json.decode(response.body));
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception(
        'Failed to load venta completa by ID: ${response.statusCode}',
      );
    }
  }

  Future<VentaModel> actualizarVentaCompleta(
    int id,
    VentaRequestModel request,
  ) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('$_baseUrl/$id'),
      headers: headers,
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      return VentaModel.fromJson(json.decode(response.body));
    } else {
      throw Exception(
        'Failed to update venta completa: ${response.statusCode}',
      );
    }
  }

  Future<void> eliminarVentaCompleta(int id) async {
    final headers = await _getHeaders();
    final response = await http.patch(
      Uri.parse('$_baseUrl/delete/$id'),
      headers: headers,
    );

    if (response.statusCode != 204) {
      throw Exception(
        'Failed to logically delete venta completa: ${response.statusCode}',
      );
    }
  }

  Future<void> restaurarVentaCompleta(int id) async {
    final headers = await _getHeaders();
    final response = await http.patch(
      Uri.parse('$_baseUrl/restore/$id'),
      headers: headers,
    );

    if (response.statusCode != 204) {
      throw Exception(
        'Failed to restore venta completa: ${response.statusCode}',
      );
    }
  }
}
