import 'package:foodflow_app/models/carrito_model.dart';

class CartModel {
  final List<Carrito> carritos;
  final bool isLoading;
  final String? error;
  final Map<String, dynamic> filtros;

  CartModel({
    this.carritos = const [],
    this.isLoading = false,
    this.error,
    this.filtros = const {},
  });

  CartModel copyWith({
    List<Carrito>? carritos,
    bool? isLoading,
    String? error,
    Map<String, dynamic>? filtros,
  }) {
    return CartModel(
      carritos: carritos ?? this.carritos,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      filtros: filtros ?? this.filtros,
    );
  }
}
