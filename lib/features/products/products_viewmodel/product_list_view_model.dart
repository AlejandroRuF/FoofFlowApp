import 'package:flutter/material.dart';
import 'package:foodflow_app/features/products/products_interactor/products_interactor.dart';
import 'package:foodflow_app/features/products/products_model/products_model.dart';
import 'package:foodflow_app/models/producto_model.dart';
import 'package:foodflow_app/models/categoria_model.dart';

class ProductListViewModel extends ChangeNotifier {
  final ProductsInteractor _interactor = ProductsInteractor();

  ProductsModel _model = ProductsModel();

  String _busquedaTexto = '';
  int? _categoriaSeleccionadaId;
  double? _precioMin;
  double? _precioMax;
  bool _soloActivos = true;
  int? _cocinaCentralIdSeleccionada;
  bool _cargandoCategorias = false;
  bool _actualizandoCarrito = false;

  List<Producto> get productos => _model.productos;
  bool get isLoading => _model.isLoading || _cargandoCategorias;
  String? get error => _model.error;

  String get busquedaTexto => _busquedaTexto;
  int? get categoriaSeleccionadaId => _categoriaSeleccionadaId;
  double? get precioMin => _precioMin;
  double? get precioMax => _precioMax;
  bool get soloActivos => _soloActivos;

  bool get esCocinaCentral =>
      _interactor.obtenerTipoUsuario() == 'cocina_central';
  bool get esAdministrador =>
      _interactor.obtenerTipoUsuario() == 'administrador' ||
      _interactor.obtenerTipoUsuario() == 'superuser';
  bool get esRestaurante => _interactor.obtenerTipoUsuario() == 'restaurante';
  String get tipoUsuario => _interactor.obtenerTipoUsuario();
  bool get puedeCrearProductos => _interactor.puedeCrearEditarProductos();
  bool get actualizandoCarrito => _actualizandoCarrito;

  List<Categoria> get categoriasDisponibles => _model.categorias;
  ProductsModel get model => _model;

  ProductListViewModel() {
    _cargarCategorias();
  }

  Future<void> _cargarCategorias() async {
    _cargandoCategorias = true;
    notifyListeners();

    try {
      final categorias = await _interactor.obtenerCategorias();
      _model = _model.copyWith(categorias: categorias);
      print('Categorías cargadas: ${categorias.length}');
    } catch (e) {
      print('Error al cargar categorías: $e');
    } finally {
      _cargandoCategorias = false;
      notifyListeners();
    }
  }

  Future<void> cargarCarrito() async {
    if (!esRestaurante || _model.cocinaSeleccionada == null) {
      return;
    }

    try {
      final carritos = await _interactor.obtenerCarritos(
        cocinaCentralId: _model.cocinaSeleccionada!.id,
      );

      if (carritos.isNotEmpty) {
        Map<int, int> cantidades = {};
        for (var item in carritos.first.productos) {
          cantidades[item.productoId] = item.cantidad;
        }
        _model = _model.copyWith(cantidadesEnCarrito: cantidades);
        notifyListeners();
      }
    } catch (e) {
      print('Error al cargar carrito: $e');
    }
  }

  void establecerBusquedaTexto(String texto) {
    _busquedaTexto = texto;
    notifyListeners();
  }

  void establecerCategoria(int? categoriaId) {
    _categoriaSeleccionadaId = categoriaId;
    notifyListeners();
  }

  void establecerPrecioMin(String? valor) {
    _precioMin =
        (valor == null || valor.isEmpty) ? null : double.tryParse(valor);
    notifyListeners();
  }

  void establecerPrecioMax(String? valor) {
    _precioMax =
        (valor == null || valor.isEmpty) ? null : double.tryParse(valor);
    notifyListeners();
  }

  void establecerSoloActivos(bool valor) {
    _soloActivos = valor;
    notifyListeners();
  }

  void establecerCocinaCentral(int cocinaCentralId) {
    _cocinaCentralIdSeleccionada = cocinaCentralId;
    cargarProductos();
  }

  void limpiarFiltros() {
    _busquedaTexto = '';
    _categoriaSeleccionadaId = null;
    _precioMin = null;
    _precioMax = null;
    _soloActivos = true;
    notifyListeners();
  }

  void aplicarFiltros() {
    print(
      'Aplicando filtros. Búsqueda: $_busquedaTexto, Categoría: $_categoriaSeleccionadaId, PrecioMin: $_precioMin, PrecioMax: $_precioMax, SoloActivos: $_soloActivos',
    );

    final productosFiltrados = _model.filtrarProductosAvanzado(
      textoBusqueda: _busquedaTexto,
      categoriaId: _categoriaSeleccionadaId,
      precioMin: _precioMin,
      precioMax: _precioMax,
      soloActivos: _soloActivos,
    );

    print(
      'Productos filtrados: ${productosFiltrados.length} de ${_model.productos.length} totales',
    );

    notifyListeners();
  }

  List<Producto> get productosFiltrados {
    return _model.filtrarProductosAvanzado(
      textoBusqueda: _busquedaTexto,
      categoriaId: _categoriaSeleccionadaId,
      precioMin: _precioMin,
      precioMax: _precioMax,
      soloActivos: _soloActivos,
      cocinaCentralId: _cocinaCentralIdSeleccionada,
    );
  }

  int getCantidadEnCarrito(int productoId) {
    return _model.getCantidadEnCarrito(productoId);
  }

  Future<void> cargarProductos() async {
    _model = _model.copyWith(isLoading: true, error: null);
    notifyListeners();

    try {
      print(
        'Iniciando carga de productos. CocinaCentralId: $_cocinaCentralIdSeleccionada',
      );
      final nuevoModelo = await _interactor.obtenerProductos(
        cocinaCentralId: _cocinaCentralIdSeleccionada,
      );

      print('Productos cargados: ${nuevoModelo.productos.length}');

      _model = nuevoModelo.copyWith(
        isLoading: false,
        categorias: _model.categorias,
      );

      if (nuevoModelo.productos.isEmpty) {
        print('Advertencia: No se encontraron productos');
        _model = _model.copyWith(
          error: nuevoModelo.error ?? 'No se encontraron productos',
        );
      }

      notifyListeners();
    } catch (e) {
      print('Error al cargar productos: $e');
      _model = _model.copyWith(
        isLoading: false,
        error: 'Error al cargar productos: $e',
      );
      notifyListeners();
    }
  }

  Future<bool> agregarAlCarrito(int productoId, int cantidad) async {
    if (_model.cocinaSeleccionada == null) {
      _model = _model.copyWith(error: 'No hay cocina central seleccionada');
      notifyListeners();
      return false;
    }

    _actualizandoCarrito = true;
    notifyListeners();

    try {
      final resultado = await _interactor.agregarAlCarrito(
        productoId,
        cantidad,
        _model.cocinaSeleccionada!.id,
      );

      if (resultado) {
        Map<int, int> nuevasCantidades = Map.from(_model.cantidadesEnCarrito);

        if (cantidad <= 0) {
          nuevasCantidades.remove(productoId);
        } else {
          nuevasCantidades[productoId] = cantidad;
        }

        _model = _model.copyWith(cantidadesEnCarrito: nuevasCantidades);
      } else {
        _model = _model.copyWith(error: 'Error al agregar producto al carrito');
      }

      _actualizandoCarrito = false;
      notifyListeners();
      return resultado;
    } catch (e) {
      _model = _model.copyWith(error: 'Error al agregar al carrito: $e');
      _actualizandoCarrito = false;
      notifyListeners();
      return false;
    }
  }
}
