import 'package:foodflow_app/models/pedido_producto_model.dart';
import 'pedido_model.dart';

class Carrito extends Pedido {
  Carrito({
    required super.id,
    required super.restauranteId,
    required super.restauranteNombre,
    required super.cocinaCentralId,
    required super.cocinaCentralNombre,
    required super.fechaPedido,
    super.fechaEntregaEstimada,
    super.fechaEntregaReal,
    required super.estado,
    required super.montoTotal,
    super.notas,
    required super.tipoPedido,
    required super.urgente,
    super.motivoCancelacion,
    super.productos,
  });

  factory Carrito.fromJson(Map<String, dynamic> json) {
    if (json['estado'] != "carrito") {
      throw ArgumentError('El estado del pedido no es "carrito".');
    }
    final productosJson = json['productos'] ?? json['pedido_productos'];
    return Carrito(
      id: json['id'],
      restauranteId: json['restaurante'],
      restauranteNombre: json['restaurante_nombre'] ?? '',
      cocinaCentralId: json['cocina_central'],
      cocinaCentralNombre: json['cocina_central_nombre'] ?? '',
      fechaPedido: json['fecha_pedido'],
      fechaEntregaEstimada: json['fecha_entrega_estimada'],
      fechaEntregaReal: json['fecha_entrega_real'],
      estado: json['estado'],
      montoTotal: double.parse(json['monto_total'].toString()),
      notas: json['notas'],
      tipoPedido: json['tipo_pedido'],
      urgente: json['urgente'] ?? false,
      motivoCancelacion: json['motivo_cancelacion'],
      productos:
          productosJson != null
              ? (productosJson as List)
                  .map((item) => PedidoProducto.fromJson(item))
                  .toList()
              : [],
    );
  }

  Carrito copyWith({
    int? id,
    int? restauranteId,
    String? restauranteNombre,
    int? cocinaCentralId,
    String? cocinaCentralNombre,
    String? fechaPedido,
    String? fechaEntregaEstimada,
    String? fechaEntregaReal,
    String? estado,
    double? montoTotal,
    String? notas,
    String? tipoPedido,
    bool? urgente,
    String? motivoCancelacion,
    List<PedidoProducto>? productos,
  }) {
    return Carrito(
      id: id ?? this.id,
      restauranteId: restauranteId ?? this.restauranteId,
      restauranteNombre: restauranteNombre ?? this.restauranteNombre,
      cocinaCentralId: cocinaCentralId ?? this.cocinaCentralId,
      cocinaCentralNombre: cocinaCentralNombre ?? this.cocinaCentralNombre,
      fechaPedido: fechaPedido ?? this.fechaPedido,
      fechaEntregaEstimada: fechaEntregaEstimada ?? this.fechaEntregaEstimada,
      fechaEntregaReal: fechaEntregaReal ?? this.fechaEntregaReal,
      estado: estado ?? this.estado,
      montoTotal: montoTotal ?? this.montoTotal,
      notas: notas ?? this.notas,
      tipoPedido: tipoPedido ?? this.tipoPedido,
      urgente: urgente ?? this.urgente,
      motivoCancelacion: motivoCancelacion ?? this.motivoCancelacion,
      productos: productos ?? List<PedidoProducto>.from(this.productos),
    );
  }
}
