import 'supplier_model.dart';

class ProductoModel {
  final int? productoID;
  final String? codeBarra;
  final String nombre;
  final String? descripcion;
  final String? marca;
  final String? categoria;
  final double precioVenta;
  final int stock;
  final String estatus; // 'A' o 'I'
  final DateTime fechaIngreso;
  final SupplierModel supplier;

  ProductoModel({
    this.productoID,
    this.codeBarra,
    required this.nombre,
    this.descripcion,
    this.marca,
    this.categoria,
    required this.precioVenta,
    required this.stock,
    required this.estatus,
    required this.fechaIngreso,
    required this.supplier,
  });

  factory ProductoModel.fromJson(Map<String, dynamic> json) {
    return ProductoModel(
      productoID: json['productoID'] as int?,
      codeBarra: json['codeBarra'] as String?,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String?,
      marca: json['marca'] as String?,
      categoria: json['categoria'] as String?,
      precioVenta: (json['precioVenta'] as num).toDouble(),
      stock: json['stock'] as int,
      estatus: json['estatus'] as String,
      fechaIngreso: json['fechaIngreso'] != null
          ? DateTime.parse(json['fechaIngreso'])
          : DateTime.now(),
      supplier: json['supplier'] != null
          ? SupplierModel.fromJson(json['supplier'])
          : SupplierModel.empty(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productoID': productoID,
      'codeBarra': codeBarra,
      'nombre': nombre,
      'descripcion': descripcion,
      'marca': marca,
      'categoria': categoria,
      'precioVenta': precioVenta,
      'stock': stock,
      'estatus': estatus,
      'fechaIngreso': fechaIngreso.toIso8601String().split('T')[0],
      'supplier': supplier.toJson(),
    };
  }

  ProductoModel copyWith({
    int? productoID,
    String? codeBarra,
    String? nombre,
    String? descripcion,
    String? marca,
    String? categoria,
    double? precioVenta,
    int? stock,
    String? estatus,
    DateTime? fechaIngreso,
    SupplierModel? supplier,
  }) {
    return ProductoModel(
      productoID: productoID ?? this.productoID,
      codeBarra: codeBarra ?? this.codeBarra,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      marca: marca ?? this.marca,
      categoria: categoria ?? this.categoria,
      precioVenta: precioVenta ?? this.precioVenta,
      stock: stock ?? this.stock,
      estatus: estatus ?? this.estatus,
      fechaIngreso: fechaIngreso ?? this.fechaIngreso,
      supplier: supplier ?? this.supplier,
    );
  }

  bool get isActivo => estatus.toUpperCase() == 'A';
  bool get isDisponible => isActivo && stock > 0;
  bool get isStockBajo => stock < 10;
  bool get hasCodeBarra => codeBarra != null && codeBarra!.isNotEmpty;
  bool get hasDescripcion => descripcion != null && descripcion!.isNotEmpty;

  String get nombreCompleto {
    if (marca != null && marca!.isNotEmpty) {
      return '$nombre - $marca';
    }
    return nombre;
  }

  String get precioFormateado => '\$${precioVenta.toStringAsFixed(2)}';

  String get fechaFormateada {
    return '${fechaIngreso.day.toString().padLeft(2, '0')}/${fechaIngreso.month.toString().padLeft(2, '0')}/${fechaIngreso.year}';
  }

  @override
  String toString() {
    return 'ProductoModel(productoID: $productoID, codeBarra: $codeBarra, nombre: $nombre, descripcion: $descripcion, marca: $marca, categoria: $categoria, precioVenta: $precioVenta, stock: $stock, estatus: $estatus, fechaIngreso: $fechaIngreso, supplier: $supplier)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProductoModel &&
        other.productoID == productoID &&
        other.codeBarra == codeBarra &&
        other.nombre == nombre &&
        other.descripcion == descripcion &&
        other.marca == marca &&
        other.categoria == categoria &&
        other.precioVenta == precioVenta &&
        other.stock == stock &&
        other.estatus == estatus &&
        other.fechaIngreso == fechaIngreso &&
        other.supplier == supplier;
  }

  @override
  int get hashCode {
    return Object.hash(
      productoID,
      codeBarra,
      nombre,
      descripcion,
      marca,
      categoria,
      precioVenta,
      stock,
      estatus,
      fechaIngreso,
      supplier,
    );
  }

  List<String> validate() {
    List<String> errors = [];
    if (nombre.trim().isEmpty) {
      errors.add('El nombre del producto es requerido');
    }
    if (precioVenta <= 0) errors.add('El precio de venta debe ser mayor a 0');
    if (stock < 0) errors.add('El stock no puede ser negativo');
    if (estatus.trim().isEmpty) errors.add('El estatus es requerido');
    final supplierErrors = supplier.validate();
    if (supplierErrors.isNotEmpty) {
      errors.addAll(supplierErrors.map((e) => 'Proveedor: $e'));
    }
    return errors;
  }

  factory ProductoModel.empty() {
    return ProductoModel(
      nombre: '',
      precioVenta: 0.0,
      stock: 0,
      estatus: 'A',
      fechaIngreso: DateTime.now(),
      supplier: SupplierModel.empty(),
    );
  }
}
