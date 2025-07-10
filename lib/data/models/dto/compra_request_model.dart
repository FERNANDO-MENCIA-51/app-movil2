import 'compra_detalle_request_dto.dart';

class CompraRequestModel {
  final DateTime fechaCompra;
  final double totalCompra;
  final String? observaciones;
  final String estado; // 'A' o 'I'
  final int cantidad;
  final int supplierId;
  final List<CompraDetalleRequestDTO> detalles;

  CompraRequestModel({
    required this.fechaCompra,
    required this.totalCompra,
    this.observaciones,
    required this.estado,
    required this.cantidad,
    required this.supplierId,
    required this.detalles,
  });

  Map<String, dynamic> toJson() {
    return {
      'fechaCompra': fechaCompra.toIso8601String().split('T')[0], // YYYY-MM-DD
      'totalCompra': totalCompra,
      'observaciones': observaciones,
      'estado': estado,
      'cantidad': cantidad,
      'supplierId': supplierId,
      'detalles': detalles.map((d) => d.toJson()).toList(),
    };
  }
}
