class VentaDetalleRequestDTO {
  final int productoId;
  final double cantidad;
  final double precioUnitario;
  final double subtotal;

  VentaDetalleRequestDTO({
    required this.productoId,
    required this.cantidad,
    required this.precioUnitario,
    required this.subtotal,
  });

  Map<String, dynamic> toJson() {
    return {
      'productoId': productoId,
      'cantidad': cantidad,
      'precioUnitario': precioUnitario,
      'subtotal': subtotal,
    };
  }
}
