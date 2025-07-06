class SupplierModel {
  final int? supplierID;
  final String nombre;
  final String? contacto;
  final String? telefono;
  final String? email;
  final String? direccion;
  final String estado;

  SupplierModel({
    this.supplierID,
    required this.nombre,
    this.contacto,
    this.telefono,
    this.email,
    this.direccion,
    required this.estado,
  });

  /// Crear instancia desde JSON
  factory SupplierModel.fromJson(Map<String, dynamic> json) {
    return SupplierModel(
      supplierID: json['supplierID'] as int?,
      nombre: json['nombre'] as String,
      contacto: json['contacto'] as String?,
      telefono: json['telefono'] as String?,
      email: json['email'] as String?,
      direccion: json['direccion'] as String?,
      estado: json['estado'] as String,
    );
  }

  /// Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'supplierID': supplierID,
      'nombre': nombre,
      'contacto': contacto,
      'telefono': telefono,
      'email': email,
      'direccion': direccion,
      'estado': estado,
    };
  }

  /// Crear copia con modificaciones
  SupplierModel copyWith({
    int? supplierID,
    String? nombre,
    String? contacto,
    String? telefono,
    String? email,
    String? direccion,
    String? estado,
  }) {
    return SupplierModel(
      supplierID: supplierID ?? this.supplierID,
      nombre: nombre ?? this.nombre,
      contacto: contacto ?? this.contacto,
      telefono: telefono ?? this.telefono,
      email: email ?? this.email,
      direccion: direccion ?? this.direccion,
      estado: estado ?? this.estado,
    );
  }

  /// Verificar si el proveedor está activo
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
    return 'SupplierModel(supplierID: $supplierID, nombre: $nombre, contacto: $contacto, telefono: $telefono, email: $email, direccion: $direccion, estado: $estado)';
  }

  /// Comparación de igualdad
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SupplierModel &&
        other.supplierID == supplierID &&
        other.nombre == nombre &&
        other.contacto == contacto &&
        other.telefono == telefono &&
        other.email == email &&
        other.direccion == direccion &&
        other.estado == estado;
  }

  /// Hash code
  @override
  int get hashCode {
    return Object.hash(
      supplierID,
      nombre,
      contacto,
      telefono,
      email,
      direccion,
      estado,
    );
  }

  /// Validar datos del proveedor
  List<String> validate() {
    List<String> errors = [];

    if (nombre.trim().isEmpty) {
      errors.add('El nombre del proveedor es requerido');
    }

    if (email != null && email!.isNotEmpty && !email!.contains('@')) {
      errors.add('El email no tiene un formato válido');
    }

    if (estado.trim().isEmpty) {
      errors.add('El estado es requerido');
    }

    return errors;
  }

  /// Crear proveedor vacío
  factory SupplierModel.empty() {
    return SupplierModel(nombre: '', estado: 'activo');
  }
}
