import 'package:foodflow_app/models/inventario_model.dart';
import 'package:foodflow_app/models/producto_model.dart';
import 'package:foodflow_app/models/categoria_model.dart';

class WarehouseModel {
  final List<Inventario> inventarioItems;
  final List<Producto> productosDisponibles;
  final List<Categoria> categorias;
  final bool isLoading;
  final String? error;
  final Inventario? productoSeleccionado;
  final String busqueda;
  final bool mostrarStockBajo;
  final double? stockMinimo;
  final double? stockMaximo;
  final int? categoriaIdSeleccionada;
  final bool soloActivos;

  WarehouseModel({
    this.inventarioItems = const [],
    this.productosDisponibles = const [],
    this.categorias = const [],
    this.isLoading = false,
    this.error,
    this.productoSeleccionado,
    this.busqueda = '',
    this.mostrarStockBajo = false,
    this.stockMinimo,
    this.stockMaximo,
    this.categoriaIdSeleccionada,
    this.soloActivos = true,
  });

  WarehouseModel copyWith({
    List<Inventario>? inventarioItems,
    List<Producto>? productosDisponibles,
    List<Categoria>? categorias,
    bool? isLoading,
    String? error,
    Inventario? productoSeleccionado,
    String? busqueda,
    bool? mostrarStockBajo,
    double? stockMinimo,
    double? stockMaximo,
    int? categoriaIdSeleccionada,
    bool? soloActivos,
  }) {
    return WarehouseModel(
      inventarioItems: inventarioItems ?? this.inventarioItems,
      productosDisponibles: productosDisponibles ?? this.productosDisponibles,
      categorias: categorias ?? this.categorias,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      productoSeleccionado: productoSeleccionado ?? this.productoSeleccionado,
      busqueda: busqueda ?? this.busqueda,
      mostrarStockBajo: mostrarStockBajo ?? this.mostrarStockBajo,
      stockMinimo: stockMinimo ?? this.stockMinimo,
      stockMaximo: stockMaximo ?? this.stockMaximo,
      categoriaIdSeleccionada:
          categoriaIdSeleccionada ?? this.categoriaIdSeleccionada,
      soloActivos: soloActivos ?? this.soloActivos,
    );
  }

  List<Inventario> get inventarioFiltrado {
    print(
      'Filtrando inventario. Total antes de filtrar: ${inventarioItems.length}',
    );
    print(
      'Filtros aplicados: textoBusqueda=$busqueda, mostrarStockBajo=$mostrarStockBajo, stockMinimo=$stockMinimo, stockMaximo=$stockMaximo, categoriaId=$categoriaIdSeleccionada, soloActivos=$soloActivos',
    );

    return inventarioItems.where((item) {
      final busquedaLower = busqueda.toLowerCase();

      final cumpleBusqueda =
          busqueda.isEmpty ||
          item.productoNombre.toLowerCase().contains(busquedaLower) ||
          item.usuarioNombre.toLowerCase().contains(busquedaLower);

      final cumpleFiltroStockBajo = !mostrarStockBajo || item.stockActual < 10;

      final cumpleStockMinimo =
          stockMinimo == null || item.stockActual >= stockMinimo!;
      final cumpleStockMaximo =
          stockMaximo == null || item.stockActual <= stockMaximo!;

      // Implementación para filtrado por categoría
      // En un caso real, esto dependería de cómo está estructurado tu modelo de datos
      final cumpleCategoria =
          categoriaIdSeleccionada ==
          null; // Por defecto considera que cumple si no hay filtro

      // Implementación para filtrado por activos
      // En un caso real, esto dependería de si tienes un campo "activo" en tu modelo
      final cumpleActivos =
          !soloActivos || true; // Por defecto considera que cumple

      if (!cumpleBusqueda ||
          !cumpleFiltroStockBajo ||
          !cumpleStockMinimo ||
          !cumpleStockMaximo ||
          !cumpleCategoria ||
          !cumpleActivos) {
        print(
          'Producto ${item.id} (${item.productoNombre}) filtrado. Razones: '
          'busquedaOk=$cumpleBusqueda, stockBajoOk=$cumpleFiltroStockBajo, '
          'stockMinimoOk=$cumpleStockMinimo, stockMaximoOk=$cumpleStockMaximo, '
          'categoriaOk=$cumpleCategoria, activosOk=$cumpleActivos',
        );
      }

      return cumpleBusqueda &&
          cumpleFiltroStockBajo &&
          cumpleStockMinimo &&
          cumpleStockMaximo &&
          cumpleCategoria &&
          cumpleActivos;
    }).toList();
  }
}
