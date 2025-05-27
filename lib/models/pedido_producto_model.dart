import 'producto_model.dart';

class PedidoProducto {
  final int id;
  final int pedidoId;
  final int productoId;
  final String productoNombre;
  final int cantidad;
  final double precioUnitario;
  final Producto? productoDetalle;

  PedidoProducto({
    required this.id,
    required this.pedidoId,
    required this.productoId,
    required this.productoNombre,
    required this.cantidad,
    required this.precioUnitario,
    this.productoDetalle,
  });

  factory PedidoProducto.fromJson(Map<String, dynamic> json) {
    final nombre =
        json['producto_nombre'] ??
        (json['producto_detalle'] != null
            ? json['producto_detalle']['nombre']
            : 'Producto');

    return PedidoProducto(
      id: json['id'],
      pedidoId: json['pedido'],
      productoId: json['producto'],
      productoNombre: nombre,
      cantidad: json['cantidad'],
      precioUnitario:
          json['precio_unitario'] != null
              ? double.parse(json['precio_unitario'].toString())
              : 0.0,
      productoDetalle:
          json['producto_detalle'] != null
              ? Producto.fromJson(json['producto_detalle'])
              : null,
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
      'producto_detalle': productoDetalle?.toJson(),
    };
  }

  PedidoProducto copyWith({
    int? id,
    int? pedidoId,
    int? productoId,
    String? productoNombre,
    int? cantidad,
    double? precioUnitario,
    Producto? productoDetalle,
  }) {
    return PedidoProducto(
      id: id ?? this.id,
      pedidoId: pedidoId ?? this.pedidoId,
      productoId: productoId ?? this.productoId,
      productoNombre: productoNombre ?? this.productoNombre,
      cantidad: cantidad ?? this.cantidad,
      precioUnitario: precioUnitario ?? this.precioUnitario,
      productoDetalle: productoDetalle ?? this.productoDetalle,
    );
  }
}
