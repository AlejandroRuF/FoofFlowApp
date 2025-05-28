import 'package:foodflow_app/models/categoria_model.dart';
import 'package:foodflow_app/models/producto_model.dart';
import 'package:foodflow_app/models/user_model.dart';

class ProductsModel {
  final List<Producto> productos;
  final List<User> cocinas;
  final List<Categoria> categorias;
  final Producto? productoSeleccionado;
  final User? cocinaSeleccionada;
  final bool isLoading;
  final String? error;

  ProductsModel({
    this.productos = const [],
    this.cocinas = const [],
    this.categorias = const [],
    this.productoSeleccionado,
    this.cocinaSeleccionada,
    this.isLoading = false,
    this.error,
  });

  ProductsModel copyWith({
    List<Producto>? productos,
    List<User>? cocinas,
    List<Categoria>? categorias,
    Producto? productoSeleccionado,
    User? cocinaSeleccionada,
    bool? isLoading,
    String? error,
  }) {
    return ProductsModel(
      productos: productos ?? this.productos,
      cocinas: cocinas ?? this.cocinas,
      categorias: categorias ?? this.categorias,
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

  List<Producto> filtrarProductosAvanzado({
    String? textoBusqueda,
    int? categoriaId,
    double? precioMin,
    double? precioMax,
    bool soloActivos = true,
    int? cocinaCentralId, // Añadir este parámetro
  }) {
    print('Filtrando productos. Total antes de filtrar: ${productos.length}');
    print(
      'Filtros aplicados: textoBusqueda=$textoBusqueda, categoriaId=$categoriaId, precioMin=$precioMin, precioMax=$precioMax, soloActivos=$soloActivos, cocinaCentralId=$cocinaCentralId',
    );

    return productos.where((producto) {
      final textoOk =
          textoBusqueda == null ||
          textoBusqueda.isEmpty ||
          producto.nombre.toLowerCase().contains(textoBusqueda.toLowerCase()) ||
          (producto.descripcion?.toLowerCase().contains(
                textoBusqueda.toLowerCase(),
              ) ??
              false) ||
          producto.categoriaNombre?.toLowerCase().contains(
                textoBusqueda.toLowerCase(),
              ) ==
              true ||
          producto.cocinaCentralId.toString() == textoBusqueda;

      final categoriaOk =
          categoriaId == null ||
          (producto.categoria != null && producto.categoria!.id == categoriaId);

      final precioMinOk =
          precioMin == null || producto.precioFinal >= precioMin;
      final precioMaxOk =
          precioMax == null || producto.precioFinal <= precioMax;

      final activosOk = !soloActivos || producto.isActive;

      // Agregar esta línea para filtrar por cocina central
      final cocinaCentralOk =
          cocinaCentralId == null ||
          producto.cocinaCentralId == cocinaCentralId;

      if (!textoOk ||
          !categoriaOk ||
          !precioMinOk ||
          !precioMaxOk ||
          !activosOk ||
          !cocinaCentralOk) {
        print(
          'Producto ${producto.id} (${producto.nombre}) filtrado. Razones: textoOk=$textoOk, categoriaOk=$categoriaOk, precioMinOk=$precioMinOk, precioMaxOk=$precioMaxOk, activosOk=$activosOk, cocinaCentralOk=$cocinaCentralOk',
        );
      }

      return textoOk &&
          categoriaOk &&
          precioMinOk &&
          precioMaxOk &&
          activosOk &&
          cocinaCentralOk;
    }).toList();
  }
}
