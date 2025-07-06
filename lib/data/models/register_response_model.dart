class RegisterResponseModel {
  final String username;
  final String rol;
  final String message;

  RegisterResponseModel({
    required this.username,
    required this.rol,
    required this.message,
  });

  factory RegisterResponseModel.fromJson(Map<String, dynamic> json) {
    return RegisterResponseModel(
      username: json['username'],
      rol: json['rol'],
      message: json['message'],
    );
  }
}
