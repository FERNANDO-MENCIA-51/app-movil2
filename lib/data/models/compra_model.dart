import 'supplier_model.dart';
// import 'compra_detalle_model.dart'; // Descomenta si usas detalles anidados

class CompraModel {
  final int? compraID;
  final DateTime fechaCompra;
  final double totalCompra;
  final String? observaciones;
  final String estado;
  final int cantidad;
  final SupplierModel supplier;
  // final List<CompraDetalleModel>? detalles;

  CompraModel({
    this.compraID,
    required this.fechaCompra,
    required this.totalCompra,
    this.observaciones,
    required this.estado,
    required this.cantidad,
    required this.supplier,
    // this.detalles,
  });

  factory CompraModel.fromJson(Map<String, dynamic> json) {
    // List<CompraDetalleModel>? detallesList;
    // if (json['detalles'] != null) {
    //   detallesList = (json['detalles'] as List)
    //       .map((item) => CompraDetalleModel.fromJson(item))
    //       .toList();
    // }
    return CompraModel(
      compraID: json['compraID'] as int?,
      fechaCompra: DateTime.parse(json['fechaCompra'] as String),
      totalCompra: (json['totalCompra'] as num).toDouble(),
      observaciones: json['observaciones'] as String?,
      estado: json['estado'] as String,
      cantidad: json['cantidad'] as int,
      supplier: SupplierModel.fromJson(
        json['supplier'] as Map<String, dynamic>,
      ),
      // detalles: detallesList,
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
      // 'detalles': detalles?.map((d) => d.toJson()).toList(),
    };
  }

  String get fechaFormateada =>
      '${fechaCompra.day.toString().padLeft(2, '0')}/${fechaCompra.month.toString().padLeft(2, '0')}/${fechaCompra.year}';

  bool get isActivo => estado.toLowerCase() == 'activo';

  @override
  String toString() {
    return 'CompraModel(compraID: $compraID, fechaCompra: $fechaCompra, totalCompra: $totalCompra, estado: $estado, cantidad: $cantidad, supplier: $supplier)';
  }
}
