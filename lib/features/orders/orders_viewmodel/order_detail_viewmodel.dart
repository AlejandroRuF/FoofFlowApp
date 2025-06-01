import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:foodflow_app/core/services/usuario_sesion_service.dart';
import 'package:foodflow_app/features/orders/orders_interactor/orders_interactor.dart';
import 'package:foodflow_app/models/pedido_model.dart';
import 'package:foodflow_app/core/services/event_bus_service.dart';

class OrderDetailViewModel extends ChangeNotifier {
  final OrdersInteractor _interactor = OrdersInteractor();
  final UserSessionService _sessionService = UserSessionService();
  final EventBusService _eventBus = EventBusService();

  Pedido? _pedido;
  bool _isLoading = false;
  String? _error;
  StreamSubscription<String>? _dataChangedSubscription;
  StreamSubscription<RefreshEvent>? _eventSubscription;

  Pedido? get pedido => _pedido;
  bool get isLoading => _isLoading;
  String? get error => _error;

  OrderDetailViewModel() {
    _subscribeToEvents();
    _listenToEvents();
  }

  @override
  void dispose() {
    _dataChangedSubscription?.cancel();
    _eventSubscription?.cancel();
    super.dispose();
  }

  void _listenToEvents() {
    _eventSubscription = _eventBus.stream.listen((event) {
      if ((event.type == RefreshEventType.orders ||
              event.type == RefreshEventType.all) &&
          _pedido?.id != null) {
        cargarPedidoDetalle(_pedido!.id);
      }
    });
  }

  void _subscribeToEvents() {
    _dataChangedSubscription = _eventBus.dataChangedStream.listen((eventKey) {
      if ((eventKey == 'order_update' ||
              eventKey == 'order_cancel' ||
              eventKey == 'order_create') &&
          _pedido?.id != null) {
        cargarPedidoDetalle(_pedido!.id);
      }
    });
  }

  Future<void> cargarPedidoDetalle(int pedidoId) async {
    _setLoading(true);
    try {
      final pedidoDetalle = await _interactor.obtenerPedidoDetalle(pedidoId);
      _pedido = pedidoDetalle;
      _error = null;
    } catch (e) {
      _error = 'Error al cargar el detalle del pedido: $e';
      if (kDebugMode) {
        print('Error en cargarPedidoDetalle: $e');
      }
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> actualizarPedido(Pedido pedidoActualizado) async {
    _setLoading(true);
    try {
      final resultado = await _interactor.actualizarPedido(pedidoActualizado);
      if (resultado) {
        _pedido = pedidoActualizado;
        _error = null;
        _eventBus.publishDataChanged('order_update');
      } else {
        _error = 'No se pudo actualizar el pedido';
      }
      return resultado;
    } catch (e) {
      _error = 'Error al actualizar el pedido: $e';
      if (kDebugMode) {
        print('Error en actualizarPedido: $e');
      }
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> cancelarPedido(String motivo) async {
    if (_pedido == null) return false;

    _setLoading(true);
    try {
      final resultado = await _interactor.cancelarPedido(_pedido!.id, motivo);
      if (resultado) {
        await cargarPedidoDetalle(_pedido!.id);
        _eventBus.publishDataChanged('order_cancel');
      } else {
        _error = 'No se pudo cancelar el pedido';
      }
      return resultado;
    } catch (e) {
      _error = 'Error al cancelar el pedido: $e';
      if (kDebugMode) {
        print('Error en cancelarPedido: $e');
      }
      return false;
    } finally {
      _setLoading(false);
    }
  }

  bool puedeCambiarEstado() {
    final usuario = _sessionService.user;
    if (usuario == null || _pedido == null) return false;

    if (usuario.isSuperuser || usuario.tipoUsuario == 'administrador') {
      return true;
    }

    if (usuario.tipoUsuario == 'cocina_central' &&
        _pedido!.cocinaCentralId == usuario.id) {
      return true;
    }

    if (usuario.tipoUsuario == 'restaurante' &&
        _pedido!.restauranteId == usuario.id) {
      return true;
    }

    if (usuario.tipoUsuario == 'empleado' &&
        _sessionService.permisos?.puedeEditarPedidos == true) {
      final empleador = usuario.propietarioId;
      if (empleador != null) {
        return true;
      }
    }

    return false;
  }

  bool puedeCancelarPedido() {
    final usuario = _sessionService.user;
    if (usuario == null || _pedido == null) return false;

    final estadosCancelables = ['pendiente', 'en_proceso'];
    if (!estadosCancelables.contains(_pedido!.estado)) {
      return false;
    }

    if (usuario.isSuperuser || usuario.tipoUsuario == 'administrador') {
      return true;
    }

    if (usuario.tipoUsuario == 'restaurante' &&
        _pedido!.restauranteId == usuario.id) {
      return true;
    }

    if (usuario.tipoUsuario == 'cocina_central' &&
        _pedido!.cocinaCentralId == usuario.id) {
      return true;
    }

    if (usuario.tipoUsuario == 'empleado' &&
        _sessionService.permisos?.puedeEditarPedidos == true) {
      final empleador = usuario.propietarioId;
      if (empleador != null) {
        return true;
      }
    }

    return false;
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
