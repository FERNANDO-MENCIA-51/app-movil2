class RegisterRequestModel {
  final String username;
  final String password;
  final String rol; // 'admin' o 'usuario'

  RegisterRequestModel({
    required this.username,
    required this.password,
    required this.rol,
  });

  Map<String, dynamic> toJson() {
    return {'username': username, 'password': password, 'rol': rol};
  }
}
