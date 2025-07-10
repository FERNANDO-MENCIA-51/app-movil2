import 'venta_detalle_request_dto.dart';

class VentaRequestModel {
  final int clienteId;
  final DateTime fechaVenta;
  final double totalVenta;
  final List<VentaDetalleRequestDTO> detalles;

  VentaRequestModel({
    required this.clienteId,
    required this.fechaVenta,
    required this.totalVenta,
    required this.detalles,
  });

  Map<String, dynamic> toJson() {
    final String formattedFecha =
        "${fechaVenta.year.toString().padLeft(4, '0')}-${fechaVenta.month.toString().padLeft(2, '0')}-${fechaVenta.day.toString().padLeft(2, '0')}";

    return {
      'clienteId': clienteId,
      'fechaVenta': formattedFecha,
      'totalVenta': totalVenta,
      'detalles': detalles.map((detalle) => detalle.toJson()).toList(),
    };
  }
}
