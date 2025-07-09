import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/cliente_model.dart';
import '../services/auth_service.dart';

class ClienteService {
  // Reemplaza con la URL base de tu backend
  static const String _baseUrl =
      'http://192.168.0.102:8080/v1/api/clientes'; // Usa tu IP local
  final AuthService _authService = AuthService();

  /// Método para obtener todos los clientes (activos e inactivos)
  Future<List<ClienteModel>> getAllClients() async {
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
        return jsonResponse.map((item) => ClienteModel.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load clients: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error connecting to server: $e');
    }
  }

  /// Método para obtener solo clientes activos
  Future<List<ClienteModel>> getActiveClients() async {
    try {
      final token = await _authService.getToken();
      final response = await http.get(
        Uri.parse('$_baseUrl/active'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse.map((item) => ClienteModel.fromJson(item)).toList();
      } else {
        throw Exception(
          'Failed to load active clients: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error connecting to server: $e');
    }
  }

  /// Método para obtener solo clientes inactivos
  Future<List<ClienteModel>> getInactiveClients() async {
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
        return jsonResponse.map((item) => ClienteModel.fromJson(item)).toList();
      } else {
        throw Exception(
          'Failed to load inactive clients: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error connecting to server: $e');
    }
  }

  /// Método para obtener un cliente por su ID
  Future<ClienteModel?> getClientById(int id) async {
    try {
      final token = await _authService.getToken();
      final response = await http.get(
        Uri.parse('$_baseUrl/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return ClienteModel.fromJson(json.decode(response.body));
      } else if (response.statusCode == 404) {
        return null; // Cliente not found
      } else {
        throw Exception('Failed to load client: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error connecting to server: $e');
    }
  }

  /// Método para buscar clientes por nombre
  Future<List<ClienteModel>> searchClientsByName(String query) async {
    try {
      final token = await _authService.getToken();
      final response = await http.get(
        Uri.parse('$_baseUrl/search?q=${Uri.encodeComponent(query)}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse.map((item) => ClienteModel.fromJson(item)).toList();
      } else {
        throw Exception('Failed to search clients: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error connecting to server: $e');
    }
  }

  /// Método para crear un nuevo cliente
  Future<ClienteModel> createClient(ClienteModel client) async {
    try {
      // Validar datos antes de enviar
      final errors = client.validate();
      if (errors.isNotEmpty) {
        throw Exception('Validation errors: ${errors.join(', ')}');
      }

      final token = await _authService.getToken();
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(client.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ClienteModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create client: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating client: $e');
    }
  }

  /// Método para actualizar un cliente existente
  Future<ClienteModel> updateClient(int id, ClienteModel client) async {
    try {
      // Validar datos antes de enviar
      final errors = client.validate();
      if (errors.isNotEmpty) {
        throw Exception('Validation errors: ${errors.join(', ')}');
      }

      final token = await _authService.getToken();
      final response = await http.put(
        Uri.parse('$_baseUrl/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(client.toJson()),
      );

      if (response.statusCode == 200) {
        return ClienteModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to update client: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating client: $e');
    }
  }

  /// Método para eliminación lógica (cambiar estado a 'I')
  Future<void> deleteLogical(int id) async {
    try {
      final token = await _authService.getToken();
      final response = await http.patch(
        Uri.parse('$_baseUrl/delete/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      // Si el backend retorna el cliente actualizado, puedes devolverlo aquí
      if (response.statusCode == 200) {
        // Opcional: retorna el cliente actualizado si tu backend lo envía
        // return ClienteModel.fromJson(json.decode(response.body));
        return;
      } else if (response.statusCode == 204) {
        // Eliminación lógica exitosa sin contenido
        return;
      } else {
        throw Exception(
          'Failed to logically delete client: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error deleting client: $e');
    }
  }

  /// Método para restaurar cliente (cambiar estado a 'A')
  Future<void> restoreClient(int id) async {
    try {
      final token = await _authService.getToken();
      final response = await http.patch(
        Uri.parse('$_baseUrl/restore/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      // Si el backend retorna el cliente actualizado, puedes devolverlo aquí
      if (response.statusCode == 200) {
        // Opcional: retorna el cliente actualizado si tu backend lo envía
        // return ClienteModel.fromJson(json.decode(response.body));
        return;
      } else if (response.statusCode == 204) {
        // Restauración exitosa sin contenido
        return;
      } else {
        throw Exception('Failed to restore client: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error restoring client: $e');
    }
  }

  /// Método para verificar si un documento ya existe
  Future<bool> documentExists(
    String tipoDocumento,
    String nroDocumento, {
    int? excludeId,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/check-document').replace(
        queryParameters: {
          'tipoDocumento': tipoDocumento,
          'nroDocumento': nroDocumento,
          if (excludeId != null) 'excludeId': excludeId.toString(),
        },
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['exists'] == true;
      } else {
        throw Exception('Failed to check document: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error checking document: $e');
    }
  }

  /// Método para obtener estadísticas de clientes
  Future<Map<String, dynamic>> getClientStats() async {
    try {
      final token = await _authService.getToken();
      final response = await http.get(
        Uri.parse('$_baseUrl/stats'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load client stats: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading stats: $e');
    }
  }

  /// Método para obtener clientes paginados
  Future<Map<String, dynamic>> getClientsPaginated({
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

      final token = await _authService.getToken();
      final uri = Uri.parse(
        '$_baseUrl/paginated',
      ).replace(queryParameters: queryParams);
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'clients': (data['clients'] as List)
              .map((item) => ClienteModel.fromJson(item))
              .toList(),
          'total': data['total'],
          'page': data['page'],
          'limit': data['limit'],
          'totalPages': data['totalPages'],
        };
      } else {
        throw Exception(
          'Failed to load paginated clients: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error loading paginated clients: $e');
    }
  }
}
