import 'package:flutter/material.dart';
import '../data/services/auth_service.dart';
import '../data/models/login_request_model.dart';
import '../data/models/login_response_model.dart';
import '../data/models/register_request_model.dart';
import '../data/models/register_response_model.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  LoginResponseModel? _currentUser;

  LoginResponseModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  Future<void> loadCurrentUser() async {
    String? token = await _authService.getToken();
    String? username = await _authService.getUsername();
    String? rol = await _authService.getUserRole();

    if (token != null && username != null && rol != null) {
      _currentUser = LoginResponseModel(
        token: token,
        username: username,
        rol: rol,
      );
    } else {
      _currentUser = null;
    }
    notifyListeners();
  }

  Future<void> login(LoginRequestModel request) async {
    try {
      final response = await _authService.login(request);
      _currentUser = response;
      notifyListeners();
    } catch (e) {
      _currentUser = null;
      notifyListeners();
      rethrow;
    }
  }

  Future<RegisterResponseModel> register(RegisterRequestModel request) async {
    try {
      final response = await _authService.register(request);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _currentUser = null;
    notifyListeners();
  }
}
