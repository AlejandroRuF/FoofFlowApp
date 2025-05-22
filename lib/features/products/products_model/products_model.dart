import 'package:foodflow_app/models/producto_model.dart';
import 'package:foodflow_app/models/user_model.dart';

class ProductsModel {
  final List<Producto> productos;

  final List<User> cocinas;

  final Producto? productoSeleccionado;

  final User? cocinaSeleccionada;

  final bool isLoading;
  final String? error;

  ProductsModel({
    this.productos = const [],
    this.cocinas = const [],
    this.productoSeleccionado,
    this.cocinaSeleccionada,
    this.isLoading = false,
    this.error,
  });

  ProductsModel copyWith({
    List<Producto>? productos,
    List<User>? cocinas,
    Producto? productoSeleccionado,
    User? cocinaSeleccionada,
    bool? isLoading,
    String? error,
  }) {
    return ProductsModel(
      productos: productos ?? this.productos,
      cocinas: cocinas ?? this.cocinas,
      productoSeleccionado: productoSeleccionado ?? this.productoSeleccionado,
      cocinaSeleccionada: cocinaSeleccionada ?? this.cocinaSeleccionada,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  List<Producto> filtrarProductosPorNombre(String busqueda) {
    if (busqueda.isEmpty) {
      return productos;
    }

    final busquedaLower = busqueda.toLowerCase();
    return productos
        .where(
          (producto) =>
              producto.nombre.toLowerCase().contains(busquedaLower) ||
              (producto.descripcion?.toLowerCase().contains(busquedaLower) ??
                  false),
        )
        .toList();
  }

  List<Producto> filtrarProductosPorEstado({required bool mostrarInactivos}) {
    if (mostrarInactivos) {
      return productos;
    }

    return productos.where((producto) => producto.isActive).toList();
  }

  List<User> filtrarCocinasPorNombre(String busqueda) {
    if (busqueda.isEmpty) {
      return cocinas;
    }

    final busquedaLower = busqueda.toLowerCase();
    return cocinas
        .where(
          (cocina) =>
              cocina.nombre.toLowerCase().contains(busquedaLower) ||
              cocina.email.toLowerCase().contains(busquedaLower) ||
              (cocina.empresaAsociada?.toLowerCase().contains(busquedaLower) ??
                  false),
        )
        .toList();
  }
}
