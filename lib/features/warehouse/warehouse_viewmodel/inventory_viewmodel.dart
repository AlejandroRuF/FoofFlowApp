import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:foodflow_app/core/services/usuario_services.dart';
import 'package:foodflow_app/core/services/usuario_sesion_service.dart';
import 'package:foodflow_app/core/services/event_bus_service.dart';
import 'package:foodflow_app/features/warehouse/interactor/warehouse_interactor.dart';
import 'package:foodflow_app/features/warehouse/warehouse_model/warehouse_model.dart';
import 'package:foodflow_app/models/inventario_model.dart';
import 'package:foodflow_app/models/user_model.dart';
import 'package:foodflow_app/models/producto_model.dart';

class InventoryViewModel extends ChangeNotifier {
  final WarehouseInteractor _interactor = WarehouseInteractor();
  final UserService _userService = UserService();
  final UserSessionService _userSessionService = UserSessionService();
  final EventBusService _eventBus = EventBusService();

  WarehouseModel _state = WarehouseModel();
  StreamSubscription<String>? _dataChangedSubscription;
  Timer? _debounceTimer;

  WarehouseModel get state => _state;

  bool get tienePermisoVerInventario =>
      _interactor.tienePermisoParaVerInventario();
  bool get tienePermisoModificarInventario =>
      _interactor.tienePermisoParaModificarInventario();

  List<Inventario> get inventarioFiltrado => _state.inventarioFiltrado;

  InventoryViewModel() {
    cargarInventario();
    cargarCategorias();
    _subscribeToEvents();
  }

  @override
  void dispose() {
    _dataChangedSubscription?.cancel();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _subscribeToEvents() {
    _dataChangedSubscription = _eventBus.dataChangedStream.listen((eventKey) {
      if (eventKey == 'responsive_scaffold_inventory_refresh' ||
          eventKey == 'responsive_scaffold_warehouse_refresh' ||
          eventKey == 'responsive_scaffold_all_refresh' ||
          eventKey == 'inventory_add' ||
          eventKey == 'inventory_add_user' ||
          eventKey == 'inventory_bulk_add' ||
          eventKey == 'product_create' ||
          eventKey == 'product_update') {
        _debouncedCargarInventario();
      }
    });
  }

  void _debouncedCargarInventario() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      cargarInventario();
    });
  }

  Future<void> cargarInventario() async {
    _state = _state.copyWith(isLoading: true, error: null);
    notifyListeners();

    if (!tienePermisoVerInventario) {
      _state = _state.copyWith(
        isLoading: false,
        error: 'No tienes permiso para acceder al almacén',
      );
      notifyListeners();
      return;
    }

    try {
      final inventarioModel = await _interactor.obtenerInventario();
      await cargarProductosDisponibles();
      _state = _state.copyWith(
        isLoading: false,
        inventarioItems: inventarioModel.inventarioItems,
        error: inventarioModel.error,
      );
    } catch (e) {
      _state = _state.copyWith(
        isLoading: false,
        error: 'Error al cargar datos del almacén: $e',
      );
    }
    notifyListeners();
  }

  Future<void> cargarProductosDisponibles() async {
    try {
      final productosModel = await _interactor.obtenerProductosDisponibles();
      _state = _state.copyWith(
        productosDisponibles: productosModel.productosDisponibles,
      );
      notifyListeners();
    } catch (e) {}
  }

  Future<List<Producto>> cargarProductosDeCocina(int cocinaCentralId) async {
    try {
      final todosLosProductos = await _interactor.obtenerProductosDisponibles();
      final productosDeEstaCocina =
          todosLosProductos.productosDisponibles
              .where((producto) => producto.cocinaCentralId == cocinaCentralId)
              .toList();

      if (productosDeEstaCocina.isNotEmpty) {
        for (int i = 0; i < productosDeEstaCocina.length && i < 3; i++) {
          final producto = productosDeEstaCocina[i];
        }
      } else {
        final cocinasConProductos =
            todosLosProductos.productosDisponibles
                .map((p) => p.cocinaCentralId)
                .toSet()
                .toList();
      }

      return productosDeEstaCocina;
    } catch (e) {
      return [];
    }
  }

  Future<void> cargarCategorias() async {
    try {
      final categoriasModel = await _interactor.obtenerCategorias();
      _state = _state.copyWith(categorias: categoriasModel.categorias);
      notifyListeners();
    } catch (e) {}
  }

  void actualizarStockLocal(int inventarioId, int nuevoStock) {
    final inventarioItems = List<Inventario>.from(_state.inventarioItems);
    final index = inventarioItems.indexWhere((item) => item.id == inventarioId);

    if (index != -1) {
      inventarioItems[index] = Inventario(
        id: inventarioItems[index].id,
        usuarioId: inventarioItems[index].usuarioId,
        usuarioNombre: inventarioItems[index].usuarioNombre,
        productoId: inventarioItems[index].productoId,
        productoNombre: inventarioItems[index].productoNombre,
        stockActual: nuevoStock,
      );

      _state = _state.copyWith(inventarioItems: inventarioItems);
      notifyListeners();
    }
  }

  Future<bool> actualizarStockProducto(int inventarioId, int nuevoStock) async {
    if (!tienePermisoModificarInventario) {
      return false;
    }

    actualizarStockLocal(inventarioId, nuevoStock);

    final resultado = await _interactor.actualizarStockProducto(
      inventarioId,
      nuevoStock,
    );

    if (!resultado) {
      await cargarInventario();
      _state = _state.copyWith(
        error: 'Error al actualizar el stock del producto',
      );
      notifyListeners();
    }

    return resultado;
  }

  Future<bool> agregarProductoAlInventario(int productoId, int cantidad) async {
    if (!tienePermisoModificarInventario) {
      return false;
    }

    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    final resultado = await _interactor.agregarProductoAlInventario(
      productoId,
      cantidad,
    );

    if (resultado) {
      await cargarInventario();
      _eventBus.publishDataChanged('inventory_add');
    } else {
      _state = _state.copyWith(
        isLoading: false,
        error: 'Error al agregar el producto al inventario',
      );
      notifyListeners();
    }

    return resultado;
  }

  Future<bool> agregarProductoAlInventarioDeUsuario(
    int productoId,
    int cantidad,
    int usuarioId,
  ) async {
    if (!tienePermisoModificarInventario) {
      return false;
    }

    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    final resultado = await _interactor.agregarProductoAlInventarioDeUsuario(
      productoId,
      cantidad,
      usuarioId,
    );

    if (resultado) {
      await cargarInventario();
      _eventBus.publishDataChanged('inventory_add_user');
    } else {
      _state = _state.copyWith(
        isLoading: false,
        error: 'Error al agregar el producto al inventario del usuario',
      );
      notifyListeners();
    }

    return resultado;
  }

  Future<List<User>> obtenerTodosLosUsuarios() async {
    try {
      return await _userService.obtenerTodosLosUsuarios();
    } catch (e) {
      return [];
    }
  }

  Future<List<User>> obtenerCocinasDeUsuario(int usuarioId) async {
    try {
      final cocinasRelacionadas = await _userService.obtenerCocinasDeUsuario(
        usuarioId,
      );
      return cocinasRelacionadas
          .where((cocina) => cocina.tipoUsuario == 'cocina_central')
          .toList();
    } catch (e) {
      return [];
    }
  }

  User? get usuarioActual => _userSessionService.user;

  bool get esAdmin =>
      usuarioActual?.tipoUsuario == 'administrador' ||
      usuarioActual?.isSuperuser == true;

  bool get esRestauranteOCocina =>
      usuarioActual?.tipoUsuario == 'restaurante' ||
      usuarioActual?.tipoUsuario == 'cocina_central';

  bool get esEmpleado => usuarioActual?.tipoUsuario == 'empleado';

  int? get idUsuarioParaInventario {
    if (esRestauranteOCocina) {
      return usuarioActual?.id;
    } else if (esEmpleado) {
      return usuarioActual?.propietarioId;
    }
    return null;
  }

  Future<List<User>> obtenerUsuariosParaSeleccion() async {
    try {
      final usuarios = await _userService.obtenerTodosLosUsuarios();
      return usuarios
          .where(
            (user) =>
                user.tipoUsuario == 'restaurante' ||
                user.tipoUsuario == 'cocina_central',
          )
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<User>> obtenerCocinasParaUsuario(int usuarioId) async {
    try {
      return await obtenerCocinasDeUsuario(usuarioId);
    } catch (e) {
      return [];
    }
  }

  Map<String, dynamic> obtenerFlujoAgregarProducto() {
    if (esAdmin) {
      return {
        'flujo': 'admin',
        'requiereSeleccionUsuario': true,
        'requiereSeleccionCocina': true,
      };
    } else if (esRestauranteOCocina) {
      return {
        'flujo': 'restaurante_cocina',
        'requiereSeleccionUsuario': false,
        'requiereSeleccionCocina': true,
        'usuarioId': usuarioActual?.id,
      };
    } else if (esEmpleado) {
      return {
        'flujo': 'empleado',
        'requiereSeleccionUsuario': false,
        'requiereSeleccionCocina': true,
        'usuarioId': idUsuarioParaInventario,
      };
    }
    return {
      'flujo': 'no_permitido',
      'error': 'No tienes permisos para agregar productos al inventario',
    };
  }

  Future<bool> agregarMultiplesProductosAlInventario(
    Map<int, int> productosYCantidades,
    int usuarioDestinoId,
  ) async {
    if (!tienePermisoModificarInventario) {
      return false;
    }

    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    try {
      bool todoExitoso = true;

      for (final entry in productosYCantidades.entries) {
        final productoId = entry.key;
        final cantidad = entry.value;

        if (cantidad > 0) {
          final resultado = await _interactor
              .agregarProductoAlInventarioDeUsuario(
                productoId,
                cantidad,
                usuarioDestinoId,
              );

          if (!resultado) {
            todoExitoso = false;
          }
        }
      }

      if (todoExitoso) {
        await cargarInventario();
        _eventBus.publishDataChanged('inventory_bulk_add');
        _state = _state.copyWith(isLoading: false);
      } else {
        _state = _state.copyWith(
          isLoading: false,
          error: 'Algunos productos no pudieron ser agregados',
        );
      }

      notifyListeners();
      return todoExitoso;
    } catch (e) {
      _state = _state.copyWith(
        isLoading: false,
        error: 'Error al agregar productos al inventario: $e',
      );
      notifyListeners();
      return false;
    }
  }

  void buscar(String query) {
    _state = _state.copyWith(busqueda: query);
    notifyListeners();
  }

  void toggleMostrarStockBajo(bool valor) {
    _state = _state.copyWith(mostrarStockBajo: valor);
    notifyListeners();
  }

  void establecerStockMinimo(String? valor) {
    _state = _state.copyWith(
      stockMinimo:
          (valor == null || valor.isEmpty) ? null : double.tryParse(valor),
    );
    notifyListeners();
  }

  void establecerStockMaximo(String? valor) {
    _state = _state.copyWith(
      stockMaximo:
          (valor == null || valor.isEmpty) ? null : double.tryParse(valor),
    );
    notifyListeners();
  }

  void establecerCategoria(int? categoriaId) {
    _state = _state.copyWith(categoriaIdSeleccionada: categoriaId);
    notifyListeners();
  }

  void toggleSoloActivos(bool soloActivos) {
    _state = _state.copyWith(soloActivos: soloActivos);
    notifyListeners();
  }

  void limpiarFiltros() {
    _state = WarehouseModel(
      inventarioItems: _state.inventarioItems,
      productosDisponibles: _state.productosDisponibles,
      categorias: _state.categorias,
      isLoading: _state.isLoading,
      error: _state.error,
      productoSeleccionado: _state.productoSeleccionado,
      busqueda: '',
      mostrarStockBajo: false,
      stockMinimo: null,
      stockMaximo: null,
      categoriaIdSeleccionada: null,
      soloActivos: true,
    );
    notifyListeners();
  }

  void aplicarFiltros() {
    notifyListeners();
  }

  Future<bool> agregarProductosComoEmpleado(
    Map<int, int> productosYCantidades,
  ) async {
    if (!esEmpleado || !tienePermisoModificarInventario) {
      return false;
    }

    final empleadorId = idUsuarioParaInventario;
    if (empleadorId == null) {
      return false;
    }

    return await agregarMultiplesProductosAlInventario(
      productosYCantidades,
      empleadorId,
    );
  }

  Future<List<Producto>> obtenerProductosParaEmpleado() async {
    if (!esEmpleado) {
      return [];
    }

    final empleadorId = idUsuarioParaInventario;
    if (kDebugMode) {
      print('idUsuarioParaInventario ${idUsuarioParaInventario}');
    }
    if (empleadorId == null) {
      return [];
    }

    try {
      final productosModel = await _interactor.obtenerProductosDisponibles();
      if (kDebugMode) {
        print('obtenerProductosDisponibles ${productosModel.toString()}}');
      }
      final empleador = await _userSessionService.obtenerPropietario();
      return productosModel.productosDisponibles.toList();
    } catch (e) {
      return [];
    }
  }
}
