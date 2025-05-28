import 'package:foodflow_app/models/pedido_model.dart';
import 'package:foodflow_app/models/user_model.dart';

class OrdersModel {
  final List<Pedido> pedidos;
  final List<User> usuariosRelacionados;
  final bool isLoading;
  final String? error;
  final Map<String, dynamic> filtros;
  final String? estado;
  final String? tipoPedido;
  final bool? urgente;
  final double? importeMin;
  final double? importeMax;
  final String? textoBusqueda;
  final DateTime? fechaInicio;
  final DateTime? fechaFin;

  OrdersModel({
    this.pedidos = const [],
    this.usuariosRelacionados = const [],
    this.isLoading = false,
    this.error,
    this.filtros = const {},
    this.estado,
    this.tipoPedido,
    this.urgente,
    this.importeMin,
    this.importeMax,
    this.textoBusqueda,
    this.fechaInicio,
    this.fechaFin,
  });

  OrdersModel copyWith({
    List<Pedido>? pedidos,
    List<User>? usuariosRelacionados,
    bool? isLoading,
    String? error,
    Map<String, dynamic>? filtros,
    String? estado,
    String? tipoPedido,
    bool? urgente,
    double? importeMin,
    double? importeMax,
    String? textoBusqueda,
    DateTime? fechaInicio,
    DateTime? fechaFin,
  }) {
    return OrdersModel(
      pedidos: pedidos ?? this.pedidos,
      usuariosRelacionados: usuariosRelacionados ?? this.usuariosRelacionados,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      filtros: filtros ?? this.filtros,
      estado: estado ?? this.estado,
      tipoPedido: tipoPedido ?? this.tipoPedido,
      urgente: urgente ?? this.urgente,
      importeMin: importeMin ?? this.importeMin,
      importeMax: importeMax ?? this.importeMax,
      textoBusqueda: textoBusqueda ?? this.textoBusqueda,
      fechaInicio: fechaInicio ?? this.fechaInicio,
      fechaFin: fechaFin ?? this.fechaFin,
    );
  }

  List<Pedido> filtrarPedidos({
    String? estado,
    String? tipoPedido,
    bool? urgente,
    double? importeMin,
    double? importeMax,
    String? textoBusqueda,
    DateTime? fechaInicio,
    DateTime? fechaFin,
  }) {
    return pedidos.where((pedido) {
      if (pedido.estado == 'carrito') return false;
      if (estado != null && estado.isNotEmpty && pedido.estado != estado)
        return false;

      if (tipoPedido != null &&
          tipoPedido.isNotEmpty &&
          pedido.tipoPedido != tipoPedido)
        return false;

      if (urgente != null && pedido.urgente != urgente) return false;

      if (fechaInicio != null) {
        final fechaPedido = DateTime.tryParse(pedido.fechaPedido);
        if (fechaPedido == null || fechaPedido.isBefore(fechaInicio))
          return false;
      }
      if (fechaFin != null) {
        final fechaPedido = DateTime.tryParse(pedido.fechaPedido);
        if (fechaPedido == null || fechaPedido.isAfter(fechaFin)) return false;
      }

      if (importeMin != null && pedido.montoTotal < importeMin) return false;
      if (importeMax != null && pedido.montoTotal > importeMax) return false;

      if (textoBusqueda != null && textoBusqueda.isNotEmpty) {
        final query = textoBusqueda.toLowerCase();

        bool encontrado = false;

        if (pedido.restauranteNombre?.toLowerCase().contains(query) ?? false)
          encontrado = true;
        if (pedido.cocinaCentralNombre?.toLowerCase().contains(query) ?? false)
          encontrado = true;
        if (pedido.notas?.toLowerCase().contains(query) ?? false)
          encontrado = true;
        if (pedido.productos.any(
          (p) =>
              p.productoDetalle?.nombre?.toLowerCase()?.contains(query) ??
              false,
        ))
          encontrado = true;

        if (!encontrado) return false;
      }

      return true;
    }).toList();
  }
}
