import 'package:foodflow_app/models/pedido_producto_model.dart';

class Pedido {
  final int id;
  final int restauranteId;
  final String restauranteNombre;
  final int cocinaCentralId;
  final String cocinaCentralNombre;
  final String fechaPedido;
  final String? fechaEntregaEstimada;
  final String? fechaEntregaReal;
  final String estado;
  final double montoTotal;
  final String? notas;
  final String tipoPedido;
  final bool urgente;
  final String? motivoCancelacion;
  final List<PedidoProducto> productos;

  Pedido({
    required this.id,
    required this.restauranteId,
    required this.restauranteNombre,
    required this.cocinaCentralId,
    required this.cocinaCentralNombre,
    required this.fechaPedido,
    this.fechaEntregaEstimada,
    this.fechaEntregaReal,
    required this.estado,
    required this.montoTotal,
    this.notas,
    required this.tipoPedido,
    required this.urgente,
    this.motivoCancelacion,
    this.productos = const [],
  });

  factory Pedido.fromJson(Map<String, dynamic> json) {
    return Pedido(
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
          json['productos'] != null
              ? (json['productos'] as List)
                  .map((item) => PedidoProducto.fromJson(item))
                  .toList()
              : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'restaurante': restauranteId,
      'restaurante_nombre': restauranteNombre,
      'cocina_central': cocinaCentralId,
      'cocina_central_nombre': cocinaCentralNombre,
      'fecha_pedido': fechaPedido,
      'fecha_entrega_estimada': fechaEntregaEstimada,
      'fecha_entrega_real': fechaEntregaReal,
      'estado': estado,
      'monto_total': montoTotal,
      'notas': notas,
      'tipo_pedido': tipoPedido,
      'urgente': urgente,
      'motivo_cancelacion': motivoCancelacion,
      'productos': productos.map((p) => p.toJson()).toList(),
    };
  }

  Map<String, dynamic> toResumenDashboard() {
    return {
      'numero': id,
      'cliente': restauranteNombre,
      'fecha': fechaPedido.substring(0, 10),
      'total': montoTotal,
      'estado': estado.replaceAll('_', ' '),
      'urgente': urgente,
    };
  }

  Map<String, dynamic> toJsonActualizar() {
    final Map<String, dynamic> data = {};

    if (notas != null) {
      data['notas'] = notas;
    }

    data['urgente'] = urgente;

    // El estado puede estar presente si cambió
    if (estado.isNotEmpty) {
      data['estado'] = estado;
    }

    if (fechaEntregaReal != null) {
      data['fecha_entrega_real'] = fechaEntregaReal;
    }

    if (motivoCancelacion != null) {
      data['motivo_cancelacion'] = motivoCancelacion;
    }

    return data;
  }
}
