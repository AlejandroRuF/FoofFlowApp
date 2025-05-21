import 'package:foodflow_app/models/pedido_model.dart';
import 'package:foodflow_app/models/user_model.dart';

class OrdersModel {
  final List<Pedido> pedidos;
  final List<User> usuariosRelacionados;
  final bool isLoading;
  final String? error;
  final Map<String, dynamic> filtros;

  OrdersModel({
    this.pedidos = const [],
    this.usuariosRelacionados = const [],
    this.isLoading = false,
    this.error,
    this.filtros = const {},
  });

  OrdersModel copyWith({
    List<Pedido>? pedidos,
    List<User>? usuariosRelacionados,
    bool? isLoading,
    String? error,
    Map<String, dynamic>? filtros,
  }) {
    return OrdersModel(
      pedidos: pedidos ?? this.pedidos,
      usuariosRelacionados: usuariosRelacionados ?? this.usuariosRelacionados,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      filtros: filtros ?? this.filtros,
    );
  }
}
