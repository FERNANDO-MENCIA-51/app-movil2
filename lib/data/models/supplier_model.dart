class SupplierModel {
  final int? supplierID;
  final String name;
  final String ruc;
  final String email;
  final String? phone;
  final String address;
  final String estatus; // 'A' o 'I'

  SupplierModel({
    this.supplierID,
    required this.name,
    required this.ruc,
    required this.email,
    this.phone,
    required this.address,
    required this.estatus,
  });

  factory SupplierModel.fromJson(Map<String, dynamic> json) {
    return SupplierModel(
      supplierID: json['supplierID'] as int?,
      name: json['name'] as String,
      ruc: json['ruc'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      address: json['address'] as String,
      estatus: json['estatus'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'supplierID': supplierID,
      'name': name,
      'ruc': ruc,
      'email': email,
      'phone': phone,
      'address': address,
      'estatus': estatus,
    };
  }

  SupplierModel copyWith({
    int? supplierID,
    String? name,
    String? ruc,
    String? email,
    String? phone,
    String? address,
    String? estatus,
  }) {
    return SupplierModel(
      supplierID: supplierID ?? this.supplierID,
      name: name ?? this.name,
      ruc: ruc ?? this.ruc,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      estatus: estatus ?? this.estatus,
    );
  }

  bool get isActivo => estatus.toUpperCase() == 'A';

  List<String> validate() {
    List<String> errors = [];
    if (name.trim().isEmpty) errors.add('El nombre es requerido');
    if (ruc.trim().isEmpty) errors.add('El RUC es requerido');
    if (email.trim().isEmpty) errors.add('El email es requerido');
    if (address.trim().isEmpty) errors.add('La dirección es requerida');
    if (estatus.trim().isEmpty) errors.add('El estatus es requerido');
    return errors;
  }

  factory SupplierModel.empty() {
    return SupplierModel(
      name: '',
      ruc: '',
      email: '',
      address: '',
      estatus: 'A',
    );
  }

  @override
  String toString() {
    return 'SupplierModel(supplierID: $supplierID, name: $name, ruc: $ruc, email: $email, phone: $phone, address: $address, estatus: $estatus)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SupplierModel &&
          runtimeType == other.runtimeType &&
          supplierID == other.supplierID &&
          name == other.name &&
          ruc == other.ruc &&
          email == other.email &&
          phone == other.phone &&
          address == other.address &&
          estatus == other.estatus;

  @override
  int get hashCode =>
      supplierID.hashCode ^
      name.hashCode ^
      ruc.hashCode ^
      email.hashCode ^
      phone.hashCode ^
      address.hashCode ^
      estatus.hashCode;
}
