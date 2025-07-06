class LoginResponseModel {
  final String token;
  final String username;
  final String rol;

  LoginResponseModel({
    required this.token,
    required this.username,
    required this.rol,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      token: json['token'],
      username: json['username'],
      rol: json['rol'],
    );
  }
}
