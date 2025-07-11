import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:foodflow_app/models/carrito_model.dart';
import 'package:foodflow_app/core/services/usuario_sesion_service.dart';
import 'package:foodflow_app/models/producto_model.dart';
import 'package:foodflow_app/models/pedido_producto_model.dart';
import 'package:foodflow_app/core/services/productos_service.dart';
import 'package:foodflow_app/core/services/event_bus_service.dart';

import '../cart_interactor/cart_interactor.dart';

class CartDetailViewModel extends ChangeNotifier {
  final CartInteractor _interactor = CartInteractor();
  final ProductosService _productosService = ProductosService();
  final UserSessionService _sessionService = UserSessionService();
  final EventBusService _eventBus = EventBusService();

  Carrito? _carrito;
  Map<int, Producto> _productosById = {};
  bool _isLoading = false;
  String? _error;
  StreamSubscription<String>? _dataChangedSubscription;
  StreamSubscription<RefreshEvent>? _eventSubscription;
  Timer? _debounceTimer;

  Map<int, bool> _actualizandoProductos = {};

  Carrito? get carrito => _carrito;
  Map<int, Producto> get productosById => _productosById;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<int, bool> get actualizandoProductos => _actualizandoProductos;

  CartDetailViewModel() {
    _subscribeToEvents();
    _listenToEvents();
  }

  @override
  void dispose() {
    _dataChangedSubscription?.cancel();
    _eventSubscription?.cancel();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _listenToEvents() {
    _eventSubscription = _eventBus.stream.listen((event) {
      if ((event.type == RefreshEventType.products ||
              event.type == RefreshEventType.all) &&
          _carrito?.id != null) {
        _debouncedCargarCarritoDetalle();
      }
    });
  }

  void _subscribeToEvents() {
    _dataChangedSubscription = _eventBus.dataChangedStream.listen((eventKey) {
      if ((eventKey == 'cart_updated' ||
              eventKey == 'cart_item_added' ||
              eventKey == 'cart_item_removed' ||
              eventKey == 'cart_item_updated' ||
              eventKey == 'cart_cleared' ||
              eventKey == 'product_update') &&
          _carrito?.id != null) {
        _debouncedCargarCarritoDetalle();
      }
    });
  }

  void _debouncedCargarCarritoDetalle() {
    if (_carrito?.id == null) return;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      cargarCarritoDetalle(_carrito!.id);
    });
  }

  Future<void> cargarCarritoDetalle(int carritoId) async {
    _setLoading(true);
    try {
      final carritoDetalle = await _interactor.obtenerCarritoDetalle(carritoId);
      _carrito = carritoDetalle;
      _error = null;
      if (carritoDetalle != null) {
        await _fetchProductosRelacionados(carritoDetalle);
      }
    } catch (e) {
      _error = 'Error al cargar el detalle del carrito: $e';
      if (kDebugMode) {
        print('Error en cargarCarritoDetalle: $e');
      }
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _fetchProductosRelacionados(Carrito carrito) async {
    final ids = carrito.productos.map((e) => e.productoId).toSet().toList();
    try {
      final productos = await _productosService.obtenerProductosPorIds(ids);
      _productosById = {for (var p in productos) p.id: p};
    } catch (e) {
      if (kDebugMode) {
        print('Error obteniendo productos del carrito: $e');
      }
      _productosById = {};
    }
  }

  Future<bool> actualizarCarrito(Carrito carritoActualizado) async {
    _setLoading(true);
    try {
      final resultado = await _interactor.actualizarCarrito(
        carritoActualizado.id,
        carritoActualizado.toJson(),
      );
      if (resultado != null) {
        _carrito = resultado;
        await _fetchProductosRelacionados(resultado);
        _error = null;
        _eventBus.publishDataChanged('cart_updated');
        return true;
      } else {
        _error = 'No se pudo actualizar el carrito';
        return false;
      }
    } catch (e) {
      _error = 'Error al actualizar el carrito: $e';
      if (kDebugMode) {
        print('Error en actualizarCarrito: $e');
      }
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> eliminarCarrito() async {
    if (_carrito == null) return false;

    _setLoading(true);
    try {
      final resultado = await _interactor.eliminarCarrito(_carrito!.id);
      if (resultado) {
        _carrito = null;
        _productosById = {};
        _error = null;
        _eventBus.publishDataChanged('cart_cleared');
      } else {
        _error = 'No se pudo eliminar el carrito';
      }
      return resultado;
    } catch (e) {
      _error = 'Error al eliminar el carrito: $e';
      if (kDebugMode) {
        print('Error en eliminarCarrito: $e');
      }
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> actualizarCantidadProducto(
    int productoId,
    int nuevaCantidad,
  ) async {
    if (_carrito == null) return false;

    _actualizandoProductos[productoId] = true;
    notifyListeners();

    try {
      final cocina = _carrito!.cocinaCentralId;

      final resultado = await _productosService.agregarAlCarrito(
        productoId,
        nuevaCantidad,
        cocina,
      );

      if (resultado) {
        await cargarCarritoDetalle(_carrito!.id);
        _eventBus.publishDataChanged('cart_item_updated');
        return true;
      } else {
        _error = 'No se pudo actualizar el producto';
        return false;
      }
    } catch (e) {
      _error = 'Error al actualizar producto: $e';
      if (kDebugMode) {
        print('Error en actualizarCantidadProducto: $e');
      }
      return false;
    } finally {
      _actualizandoProductos.remove(productoId);
      notifyListeners();
    }
  }

  Future<bool> eliminarProducto(int productoId) async {
    final resultado = await actualizarCantidadProducto(productoId, 0);
    if (resultado) {
      _eventBus.publishDataChanged('cart_item_removed');
    }
    return resultado;
  }

  Future<bool> confirmarCarrito() async {
    if (_carrito == null) return false;

    _setLoading(true);
    try {
      final resultado = await _interactor.confirmarCarrito(_carrito!.id);
      if (resultado) {
        await cargarCarritoDetalle(_carrito!.id);
        _eventBus.publishDataChanged('cart_updated');
        return true;
      } else {
        _error = 'No se pudo confirmar el carrito';
        return false;
      }
    } catch (e) {
      _error = 'Error al confirmar el carrito: $e';
      if (kDebugMode) {
        print('Error en confirmarCarrito: $e');
      }
      return false;
    } finally {
      _setLoading(false);
    }
  }

  bool puedeEditarCarrito() {
    final usuario = _sessionService.user;
    if (usuario == null || _carrito == null) return false;
    if (_carrito!.estado != 'carrito') return false;

    if (usuario.isSuperuser || usuario.tipoUsuario == 'administrador') {
      return true;
    }
    if (usuario.tipoUsuario == 'restaurante' &&
        _carrito!.restauranteId == usuario.id) {
      return true;
    }
    if (usuario.tipoUsuario == 'empleado' &&
        _sessionService.permisos?.puedeEditarPedidos == true) {
      final empleador = usuario.propietarioId;
      if (empleador != null && empleador == _carrito!.restauranteId) {
        return true;
      }
    }
    return false;
  }

  bool puedeEliminarCarrito() => puedeEditarCarrito();
  bool puedeConfirmarCarrito() => puedeEditarCarrito();

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  bool estaActualizandoProducto(int productoId) {
    return _actualizandoProductos[productoId] ?? false;
  }
}
