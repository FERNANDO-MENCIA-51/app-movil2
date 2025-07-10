import 'cliente_model.dart';
import 'venta_detalle_model.dart';

class VentaModel {
  final int? ventaID;
  final DateTime fechaVenta;
  final double totalVenta;
  final String estado;
  final ClienteModel cliente;
  final List<VentaDetalleModel> detalles;

  VentaModel({
    this.ventaID,
    required this.fechaVenta,
    required this.totalVenta,
    required this.estado,
    required this.cliente,
    required this.detalles,
  });

  factory VentaModel.fromJson(Map<String, dynamic> json) {
    return VentaModel(
      ventaID: json['ventaID'] as int?,
      fechaVenta: DateTime.parse(json['fechaVenta'] as String),
      totalVenta: (json['totalVenta'] as num).toDouble(),
      estado: json['estado'] as String,
      cliente: ClienteModel.fromJson(json['cliente'] as Map<String, dynamic>),
      detalles: (json['detalles'] as List<dynamic>? ?? [])
          .map((e) => VentaDetalleModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ventaID': ventaID,
      'fechaVenta': fechaVenta.toIso8601String().split('T')[0],
      'totalVenta': totalVenta,
      'estado': estado,
      'cliente': cliente.toJson(),
      'detalles': detalles.map((e) => e.toJson()).toList(),
    };
  }

  String get fechaFormateada =>
      '${fechaVenta.day.toString().padLeft(2, '0')}/${fechaVenta.month.toString().padLeft(2, '0')}/${fechaVenta.year}';

  bool get isActivo => estado.toUpperCase() == 'A';

  @override
  String toString() {
    return 'VentaModel(ventaID: $ventaID, fechaVenta: $fechaVenta, totalVenta: $totalVenta, estado: $estado, cliente: $cliente, detalles: $detalles)';
  }
}
