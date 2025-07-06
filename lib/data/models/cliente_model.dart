class ClienteModel {
  final int? clienteID;
  final String nombres;
  final String apellidos;
  final String tipoDocumento;
  final String nroDocumento;
  final String? telefono;
  final String? email;
  final String? direccion;
  final String estado;

  ClienteModel({
    this.clienteID,
    required this.nombres,
    required this.apellidos,
    required this.tipoDocumento,
    required this.nroDocumento,
    this.telefono,
    this.email,
    this.direccion,
    required this.estado,
  });

  /// Crear instancia desde JSON
  factory ClienteModel.fromJson(Map<String, dynamic> json) {
    return ClienteModel(
      clienteID: json['clienteID'] as int?,
      nombres: json['nombres'] as String,
      apellidos: json['apellidos'] as String,
      tipoDocumento: json['tipoDocumento'] as String,
      nroDocumento: json['nroDocumento'] as String,
      telefono: json['telefono'] as String?,
      email: json['email'] as String?,
      direccion: json['direccion'] as String?,
      estado: json['estado'] as String,
    );
  }

  /// Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'clienteID': clienteID,
      'nombres': nombres,
      'apellidos': apellidos,
      'tipoDocumento': tipoDocumento,
      'nroDocumento': nroDocumento,
      'telefono': telefono,
      'email': email,
      'direccion': direccion,
      'estado': estado,
    };
  }

  /// Crear copia con modificaciones
  ClienteModel copyWith({
    int? clienteID,
    String? nombres,
    String? apellidos,
    String? tipoDocumento,
    String? nroDocumento,
    String? telefono,
    String? email,
    String? direccion,
    String? estado,
  }) {
    return ClienteModel(
      clienteID: clienteID ?? this.clienteID,
      nombres: nombres ?? this.nombres,
      apellidos: apellidos ?? this.apellidos,
      tipoDocumento: tipoDocumento ?? this.tipoDocumento,
      nroDocumento: nroDocumento ?? this.nroDocumento,
      telefono: telefono ?? this.telefono,
      email: email ?? this.email,
      direccion: direccion ?? this.direccion,
      estado: estado ?? this.estado,
    );
  }

  /// Obtener nombre completo
  String get nombreCompleto => '$nombres $apellidos';

  /// Verificar si el cliente está activo
  bool get isActivo => estado.toLowerCase() == 'activo';

  /// Verificar si tiene email válido
  bool get hasValidEmail => email != null && email!.contains('@');

  /// Verificar si tiene teléfono
  bool get hasTelefono => telefono != null && telefono!.isNotEmpty;

  /// Verificar si tiene dirección
  bool get hasDireccion => direccion != null && direccion!.isNotEmpty;

  /// Representación como string
  @override
  String toString() {
    return 'ClienteModel(clienteID: $clienteID, nombres: $nombres, apellidos: $apellidos, tipoDocumento: $tipoDocumento, nroDocumento: $nroDocumento, telefono: $telefono, email: $email, direccion: $direccion, estado: $estado)';
  }

  /// Comparación de igualdad
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ClienteModel &&
        other.clienteID == clienteID &&
        other.nombres == nombres &&
        other.apellidos == apellidos &&
        other.tipoDocumento == tipoDocumento &&
        other.nroDocumento == nroDocumento &&
        other.telefono == telefono &&
        other.email == email &&
        other.direccion == direccion &&
        other.estado == estado;
  }

  /// Hash code
  @override
  int get hashCode {
    return Object.hash(
      clienteID,
      nombres,
      apellidos,
      tipoDocumento,
      nroDocumento,
      telefono,
      email,
      direccion,
      estado,
    );
  }

  /// Validar datos del cliente
  List<String> validate() {
    List<String> errors = [];

    if (nombres.trim().isEmpty) {
      errors.add('Los nombres son requeridos');
    }

    if (apellidos.trim().isEmpty) {
      errors.add('Los apellidos son requeridos');
    }

    if (tipoDocumento.trim().isEmpty) {
      errors.add('El tipo de documento es requerido');
    }

    if (nroDocumento.trim().isEmpty) {
      errors.add('El número de documento es requerido');
    }

    if (email != null && email!.isNotEmpty && !email!.contains('@')) {
      errors.add('El email no tiene un formato válido');
    }

    if (estado.trim().isEmpty) {
      errors.add('El estado es requerido');
    }

    return errors;
  }

  /// Crear cliente vacío
  factory ClienteModel.empty() {
    return ClienteModel(
      nombres: '',
      apellidos: '',
      tipoDocumento: '',
      nroDocumento: '',
      estado: 'activo',
    );
  }
}
