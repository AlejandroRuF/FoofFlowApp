import 'package:foodflow_app/models/inventario_model.dart';
import 'package:foodflow_app/models/producto_model.dart';

class WarehouseModel {
  final List<Inventario> inventarioItems;
  final List<Producto> productosDisponibles;
  final bool isLoading;
  final String? error;
  final Inventario? productoSeleccionado;
  final String busqueda;
  final bool mostrarStockBajo;

  WarehouseModel({
    this.inventarioItems = const [],
    this.productosDisponibles = const [],
    this.isLoading = false,
    this.error,
    this.productoSeleccionado,
    this.busqueda = '',
    this.mostrarStockBajo = false,
  });

  WarehouseModel copyWith({
    List<Inventario>? inventarioItems,
    List<Producto>? productosDisponibles,
    bool? isLoading,
    String? error,
    Inventario? productoSeleccionado,
    String? busqueda,
    bool? mostrarStockBajo,
  }) {
    return WarehouseModel(
      inventarioItems: inventarioItems ?? this.inventarioItems,
      productosDisponibles: productosDisponibles ?? this.productosDisponibles,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      productoSeleccionado: productoSeleccionado ?? this.productoSeleccionado,
      busqueda: busqueda ?? this.busqueda,
      mostrarStockBajo: mostrarStockBajo ?? this.mostrarStockBajo,
    );
  }

  List<Inventario> get inventarioFiltrado {
    if (busqueda.isEmpty && !mostrarStockBajo) {
      return inventarioItems;
    }

    final busquedaLower = busqueda.toLowerCase();

    return inventarioItems.where((item) {
      final cumpleBusqueda =
          busqueda.isEmpty ||
          item.productoNombre.toLowerCase().contains(busquedaLower) ||
          item.usuarioNombre.toLowerCase().contains(busquedaLower);

      final cumpleFiltroStock = !mostrarStockBajo || item.stockActual < 10;

      return cumpleBusqueda && cumpleFiltroStock;
    }).toList();
  }
}
