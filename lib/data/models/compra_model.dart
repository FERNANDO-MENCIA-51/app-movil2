import 'supplier_model.dart';

class CompraModel {
  final int? compraID;
  final DateTime fechaCompra;
  final double totalCompra;
  final String? observaciones;
  final String estado; // 'A' o 'I'
  final int cantidad;
  final SupplierModel supplier;

  CompraModel({
    this.compraID,
    required this.fechaCompra,
    required this.totalCompra,
    this.observaciones,
    required this.estado,
    required this.cantidad,
    required this.supplier,
  });

  factory CompraModel.fromJson(Map<String, dynamic> json) {
    return CompraModel(
      compraID: json['compraID'] as int?,
      fechaCompra: DateTime.parse(json['fechaCompra'] as String),
      totalCompra: (json['totalCompra'] as num).toDouble(),
      observaciones: json['observaciones'] as String?,
      estado: json['estado'] as String, // debe ser 'A' o 'I'
      cantidad: json['cantidad'] as int,
      supplier: SupplierModel.fromJson(
        json['supplier'] as Map<String, dynamic>,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'compraID': compraID,
      'fechaCompra': fechaCompra.toIso8601String().split('T')[0],
      'totalCompra': totalCompra,
      'observaciones': observaciones,
      'estado': estado,
      'cantidad': cantidad,
      'supplier': supplier.toJson(),
    };
  }

  String get fechaFormateada =>
      '${fechaCompra.day.toString().padLeft(2, '0')}/${fechaCompra.month.toString().padLeft(2, '0')}/${fechaCompra.year}';

  bool get isActivo => estado.toUpperCase() == 'A';

  @override
  String toString() {
    return 'CompraModel(compraID: $compraID, fechaCompra: $fechaCompra, totalCompra: $totalCompra, estado: $estado, cantidad: $cantidad, supplier: $supplier)';
  }
}
