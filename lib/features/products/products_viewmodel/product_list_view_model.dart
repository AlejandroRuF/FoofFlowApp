import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:foodflow_app/features/products/products_interactor/products_interactor.dart';
import 'package:foodflow_app/features/products/products_model/products_model.dart';
import 'package:foodflow_app/models/producto_model.dart';
import 'package:foodflow_app/models/categoria_model.dart';
import 'package:foodflow_app/core/services/event_bus_service.dart';

class ProductListViewModel extends ChangeNotifier {
  final ProductsInteractor _interactor = ProductsInteractor();
  final EventBusService _eventBus = EventBusService();

  ProductsModel _model = ProductsModel();
  StreamSubscription<String>? _dataChangedSubscription;
  StreamSubscription<RefreshEvent>? _eventSubscription;

  String _busquedaTexto = '';
  int? _categoriaSeleccionadaId;
  double? _precioMin;
  double? _precioMax;
  bool _soloActivos = true;
  int? _cocinaCentralIdSeleccionada;
  bool _cargandoCategorias = false;
  bool _esRestaurante = false;
  Map<int, bool> _actualizandoProductos = {};

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

  bool get esRestaurante => _esRestaurante;

  String get tipoUsuario => _interactor.obtenerTipoUsuario();
  bool get puedeCrearProductos => _interactor.puedeCrearEditarProductos();
  bool get actualizandoCarrito =>
      _actualizandoProductos.values.any((element) => element);

  List<Categoria> get categoriasDisponibles => _model.categorias;
  ProductsModel get model => _model;

  bool get muestraPantallaRestaurante {
    final tipo = _interactor.obtenerTipoUsuario();
    return tipo == 'restaurante' || (tipo == 'empleado' && _esRestaurante);
  }

  bool get muestraPantallaCocinaCentral {
    final tipo = _interactor.obtenerTipoUsuario();
    return tipo == 'administrador' ||
        tipo == 'cocina_central' ||
        (tipo == 'empleado' && !_esRestaurante);
  }

  ProductListViewModel() {
    _cargarCategorias();
    _subscribeToEvents();
    _listenToEvents();
    _verificarTipoUsuario();
  }

  @override
  void dispose() {
    _dataChangedSubscription?.cancel();
    _eventSubscription?.cancel();
    super.dispose();
  }

  bool estaActualizandoProducto(int productoId) {
    return _actualizandoProductos[productoId] ?? false;
  }

  Future<void> _verificarTipoUsuario() async {
    final tipoUsuario = _interactor.obtenerTipoUsuario();

    if (tipoUsuario == 'restaurante') {
      _esRestaurante = true;
    } else if (tipoUsuario == 'empleado') {
      final esRestauranteOEmpleado =
          await _interactor.esRestauranteOEmpleadoRestaurante();
      _esRestaurante = esRestauranteOEmpleado;
      if (kDebugMode) {
        print('Es empleado de restaurante: $_esRestaurante');
      }
    } else {
      _esRestaurante = false;
    }

    notifyListeners();
  }

  void _listenToEvents() {
    _eventSubscription = _eventBus.stream.listen((event) {
      if (event.type == RefreshEventType.products ||
          event.type == RefreshEventType.all) {
        cargarProductos();
      }
    });
  }

  void _subscribeToEvents() {
    _dataChangedSubscription = _eventBus.dataChangedStream.listen((eventKey) {
      if (eventKey == 'responsive_scaffold_products_refresh' ||
          eventKey == 'responsive_scaffold_inventory_refresh' ||
          eventKey == 'responsive_scaffold_all_refresh' ||
          eventKey == 'product_create' ||
          eventKey == 'product_update' ||
          eventKey == 'inventory_update' ||
          eventKey == 'inventory_add' ||
          eventKey == 'inventory_add_user' ||
          eventKey == 'inventory_bulk_add' ||
          eventKey == 'qr_stock_update') {
        cargarProductos();
      }
      if (eventKey == 'cart_update') {
        cargarCarrito();
      }
    });
  }

  Future<void> _cargarCategorias() async {
    _cargandoCategorias = true;
    notifyListeners();

    try {
      final categorias = await _interactor.obtenerCategorias();
      _model = _model.copyWith(categorias: categorias);
      if (kDebugMode) {
        print('Categorías cargadas: ${categorias.length}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error al cargar categorías: $e');
      }
    } finally {
      _cargandoCategorias = false;
      notifyListeners();
    }
  }

  Future<void> cargarCarrito() async {
    if (!muestraPantallaRestaurante || _model.cocinaSeleccionada == null) {
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
      if (kDebugMode) {
        print('Error al cargar carrito: $e');
      }
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
    if (kDebugMode) {
      print(
        'Aplicando filtros. Búsqueda: $_busquedaTexto, Categoría: $_categoriaSeleccionadaId, PrecioMin: $_precioMin, PrecioMax: $_precioMax, SoloActivos: $_soloActivos',
      );
    }

    final productosFiltrados = _model.filtrarProductosAvanzado(
      textoBusqueda: _busquedaTexto,
      categoriaId: _categoriaSeleccionadaId,
      precioMin: _precioMin,
      precioMax: _precioMax,
      soloActivos: _soloActivos,
    );

    if (kDebugMode) {
      print(
        'Productos filtrados: ${productosFiltrados.length} de ${_model.productos.length} totales',
      );
    }

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
      if (kDebugMode) {
        print(
          'Iniciando carga de productos. CocinaCentralId: $_cocinaCentralIdSeleccionada',
        );
      }
      final nuevoModelo = await _interactor.obtenerProductos(
        cocinaCentralId: _cocinaCentralIdSeleccionada,
      );

      if (kDebugMode) {
        print('Productos cargados: ${nuevoModelo.productos.length}');
      }

      _model = nuevoModelo.copyWith(
        isLoading: false,
        categorias: _model.categorias,
      );

      if (nuevoModelo.productos.isEmpty) {
        if (kDebugMode) {
          print('Advertencia: No se encontraron productos');
        }
        _model = _model.copyWith(
          error: nuevoModelo.error ?? 'No se encontraron productos',
        );
      }

      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error al cargar productos: $e');
      }
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

    _actualizandoProductos[productoId] = true;
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
        _eventBus.publishDataChanged('cart_update');
      } else {
        _model = _model.copyWith(error: 'Error al agregar producto al carrito');
      }

      _actualizandoProductos[productoId] = false;
      notifyListeners();
      return resultado;
    } catch (e) {
      _model = _model.copyWith(error: 'Error al agregar al carrito: $e');
      _actualizandoProductos[productoId] = false;
      notifyListeners();
      return false;
    }
  }
}
