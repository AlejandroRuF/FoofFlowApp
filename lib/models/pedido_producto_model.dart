class PedidoProducto {
  final int id;
  final int pedidoId;
  final int productoId;
  final String productoNombre;
  final int cantidad;
  final double precioUnitario;

  PedidoProducto({
    required this.id,
    required this.pedidoId,
    required this.productoId,
    required this.productoNombre,
    required this.cantidad,
    required this.precioUnitario,
  });

  factory PedidoProducto.fromJson(Map<String, dynamic> json) {
    return PedidoProducto(
      id: json['id'],
      pedidoId: json['pedido'],
      productoId: json['producto'],
      productoNombre: json['producto_nombre'] ?? 'Producto',
      cantidad: json['cantidad'],
      precioUnitario:
          json['precio_unitario'] != null
              ? double.parse(json['precio_unitario'].toString())
              : 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pedido': pedidoId,
      'producto': productoId,
      'producto_nombre': productoNombre,
      'cantidad': cantidad,
      'precio_unitario': precioUnitario,
    };
  }

  PedidoProducto copyWith({
    int? id,
    int? pedidoId,
    int? productoId,
    String? productoNombre,
    int? cantidad,
    double? precioUnitario,
  }) {
    return PedidoProducto(
      id: id ?? this.id,
      pedidoId: pedidoId ?? this.pedidoId,
      productoId: productoId ?? this.productoId,
      productoNombre: productoNombre ?? this.productoNombre,
      cantidad: cantidad ?? this.cantidad,
      precioUnitario: precioUnitario ?? this.precioUnitario,
    );
  }
}
