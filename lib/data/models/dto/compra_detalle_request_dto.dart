class CompraDetalleRequestDTO {
  final int productoId;
  final int cantidad;
  final double precioUnitario;
  final double subtotal;
  final String ruc;

  CompraDetalleRequestDTO({
    required this.productoId,
    required this.cantidad,
    required this.precioUnitario,
    required this.subtotal,
    required this.ruc,
  });

  Map<String, dynamic> toJson() {
    return {
      'productoId': productoId,
      'cantidad': cantidad,
      'precioUnitario': precioUnitario,
      'subtotal': subtotal,
      'ruc': ruc,
    };
  }
}
