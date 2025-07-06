import 'cliente_model.dart';

class VentaModel {
  final int? ventaID;
  final DateTime fechaVenta;
  final double totalVenta;
  final String estado;
  final ClienteModel cliente;


  VentaModel({
    this.ventaID,
    required this.fechaVenta,
    required this.totalVenta,
    required this.estado,
    required this.cliente,
    // this.detalles,
  });

  factory VentaModel.fromJson(Map<String, dynamic> json) {
 
    return VentaModel(
      ventaID: json['ventaID'] as int?,
      fechaVenta: DateTime.parse(json['fechaVenta'] as String),
      totalVenta: (json['totalVenta'] as num).toDouble(),
      estado: json['estado'] as String,
      cliente: ClienteModel.fromJson(json['cliente'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ventaID': ventaID,
      'fechaVenta': fechaVenta.toIso8601String().split('T')[0],
      'totalVenta': totalVenta,
      'estado': estado,
      'cliente': cliente.toJson(),
      // 'detalles': detalles?.map((d) => d.toJson()).toList(),
    };
  }

  String get fechaFormateada =>
      '${fechaVenta.day.toString().padLeft(2, '0')}/${fechaVenta.month.toString().padLeft(2, '0')}/${fechaVenta.year}';

  bool get isActivo => estado.toLowerCase() == 'activo';

  @override
  String toString() {
    return 'VentaModel(ventaID: $ventaID, fechaVenta: $fechaVenta, totalVenta: $totalVenta, estado: $estado, cliente: $cliente)';
  }
}
