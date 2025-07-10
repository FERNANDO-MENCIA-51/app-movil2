import 'producto_model.dart';
import 'compra_model.dart';
import 'supplier_model.dart';

class CompraDetalleModel {
  final int? compraDetalleID;
  final int cantidad;
  final double precioUnitario;
  final double subtotal;
  final String estado; // 'A' o 'I'
  final String ruc;
  final ProductoModel producto;
  final CompraModel compra;
  final SupplierModel supplier;

  CompraDetalleModel({
    this.compraDetalleID,
    required this.cantidad,
    required this.precioUnitario,
    required this.subtotal,
    required this.estado,
    required this.ruc,
    required this.producto,
    required this.compra,
    required this.supplier,
  });

  factory CompraDetalleModel.fromJson(Map<String, dynamic> json) {
    return CompraDetalleModel(
      compraDetalleID: json['compraDetalleID'] as int?,
      cantidad: json['cantidad'] as int,
      precioUnitario: (json['precioUnitario'] as num).toDouble(),
      subtotal: (json['subtotal'] as num).toDouble(),
      estado: json['estado'] as String,
      ruc: json['ruc'] as String,
      producto: ProductoModel.fromJson(
        json['producto'] as Map<String, dynamic>,
      ),
      compra: CompraModel.fromJson(json['compra'] as Map<String, dynamic>),
      supplier: SupplierModel.fromJson(
        json['supplier'] as Map<String, dynamic>,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'compraDetalleID': compraDetalleID,
      'cantidad': cantidad,
      'precioUnitario': precioUnitario,
      'subtotal': subtotal,
      'estado': estado,
      'ruc': ruc,
      'producto': producto.toJson(),
      'compra': compra.toJson(),
      'supplier': supplier.toJson(),
    };
  }

  CompraDetalleModel copyWith({
    int? compraDetalleID,
    int? cantidad,
    double? precioUnitario,
    double? subtotal,
    String? estado,
    String? ruc,
    ProductoModel? producto,
    CompraModel? compra,
    SupplierModel? supplier,
  }) {
    return CompraDetalleModel(
      compraDetalleID: compraDetalleID ?? this.compraDetalleID,
      cantidad: cantidad ?? this.cantidad,
      precioUnitario: precioUnitario ?? this.precioUnitario,
      subtotal: subtotal ?? this.subtotal,
      estado: estado ?? this.estado,
      ruc: ruc ?? this.ruc,
      producto: producto ?? this.producto,
      compra: compra ?? this.compra,
      supplier: supplier ?? this.supplier,
    );
  }

  @override
  String toString() {
    return 'CompraDetalleModel(compraDetalleID: $compraDetalleID, cantidad: $cantidad, precioUnitario: $precioUnitario, subtotal: $subtotal, estado: $estado, ruc: $ruc, producto: $producto, compra: $compra, supplier: $supplier)';
  }
}
