import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/login_request_model.dart';
import '../models/login_response_model.dart';
import '../models/register_request_model.dart';
import '../models/register_response_model.dart';

class AuthService {
  // Tu IP local es 192.168.0.102 según tu ipconfig
  static const String _baseUrl = 'http://192.168.0.106:8080/v1/api/auth';

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  static const String _tokenKey = 'jwt_token';
  static const String _usernameKey = 'auth_username';
  static const String _rolKey = 'auth_rol';

  Future<LoginResponseModel> login(LoginRequestModel request) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      final loginResponse = LoginResponseModel.fromJson(responseData);

      await _secureStorage.write(key: _tokenKey, value: loginResponse.token);
      await _secureStorage.write(
        key: _usernameKey,
        value: loginResponse.username,
      );
      await _secureStorage.write(key: _rolKey, value: loginResponse.rol);

      return loginResponse;
    } else {
      throw Exception('Error al iniciar sesión: ${response.statusCode}');
    }
  }

  Future<RegisterResponseModel> register(RegisterRequestModel request) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/register'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return RegisterResponseModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Error al registrar usuario: ${response.statusCode}');
    }
  }

  Future<void> logout() async {
    await _secureStorage.delete(key: _tokenKey);
    await _secureStorage.delete(key: _usernameKey);
    await _secureStorage.delete(key: _rolKey);
  }

  Future<String?> getToken() async {
    return await _secureStorage.read(key: _tokenKey);
  }

  Future<bool> isLoggedIn() async {
    String? token = await getToken();
    return token != null;
  }

  Future<String?> getUserRole() async {
    return await _secureStorage.read(key: _rolKey);
  }

  Future<String?> getUsername() async {
    return await _secureStorage.read(key: _usernameKey);
  }
}
