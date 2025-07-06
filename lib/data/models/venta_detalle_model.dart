import 'venta_model.dart';
import 'producto_model.dart';

class VentaDetalleModel {
  final int? detalleID;
  final int cantidad;
  final double precioUnitario;
  final double subtotal;
  final String estado;
  final VentaModel venta;
  final ProductoModel producto;

  VentaDetalleModel({
    this.detalleID,
    required this.cantidad,
    required this.precioUnitario,
    required this.subtotal,
    required this.estado,
    required this.venta,
    required this.producto,
  });

  factory VentaDetalleModel.fromJson(Map<String, dynamic> json) {
    return VentaDetalleModel(
      detalleID: json['detalleID'] as int?,
      cantidad: json['cantidad'] as int,
      precioUnitario: (json['precioUnitario'] as num).toDouble(),
      subtotal: (json['subtotal'] as num).toDouble(),
      estado: json['estado'] as String,
      venta: VentaModel.fromJson(json['venta'] as Map<String, dynamic>),
      producto: ProductoModel.fromJson(
        json['producto'] as Map<String, dynamic>,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'detalleID': detalleID,
      'cantidad': cantidad,
      'precioUnitario': precioUnitario,
      'subtotal': subtotal,
      'estado': estado,
      'venta': venta.toJson(),
      'producto': producto.toJson(),
    };
  }

  VentaDetalleModel copyWith({
    int? detalleID,
    int? cantidad,
    double? precioUnitario,
    double? subtotal,
    String? estado,
    VentaModel? venta,
    ProductoModel? producto,
  }) {
    return VentaDetalleModel(
      detalleID: detalleID ?? this.detalleID,
      cantidad: cantidad ?? this.cantidad,
      precioUnitario: precioUnitario ?? this.precioUnitario,
      subtotal: subtotal ?? this.subtotal,
      estado: estado ?? this.estado,
      venta: venta ?? this.venta,
      producto: producto ?? this.producto,
    );
  }

  @override
  String toString() {
    return 'VentaDetalleModel(detalleID: $detalleID, cantidad: $cantidad, precioUnitario: $precioUnitario, subtotal: $subtotal, estado: $estado, venta: $venta, producto: $producto)';
  }
}
