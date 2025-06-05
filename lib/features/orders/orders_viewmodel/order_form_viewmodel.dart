import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:foodflow_app/core/services/event_bus_service.dart';
import 'package:foodflow_app/core/services/usuario_sesion_service.dart';
import 'package:foodflow_app/features/orders/orders_interactor/orders_interactor.dart';
import 'package:foodflow_app/models/pedido_model.dart';
import 'package:foodflow_app/models/user_model.dart';

class OrderFormViewModel extends ChangeNotifier {
  final OrdersInteractor _interactor = OrdersInteractor();
  final UserSessionService _sessionService = UserSessionService();
  final EventBusService _eventBus = EventBusService();
  User? _propietario;

  Pedido? _pedido;
  bool _isLoading = false;
  String? _error;
  StreamSubscription<String>? _dataChangedSubscription;
  StreamSubscription<RefreshEvent>? _eventSubscription;

  Pedido? get pedido => _pedido;
  bool get isLoading => _isLoading;
  String? get error => _error;

  OrderFormViewModel() {
    _subscribeToEvents();
    _listenToEvents();
    _initPropietario();
  }

  Future<void> _initPropietario() async {
    try {
      _propietario = await _sessionService.obtenerPropietario();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error al obtener propietario: $e');
      }
    }
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
        cargarPedido(_pedido!.id);
      }
    });
  }

  void _subscribeToEvents() {
    _dataChangedSubscription = _eventBus.dataChangedStream.listen((eventKey) {
      if ((eventKey == 'order_update' ||
              eventKey == 'order_cancel' ||
              eventKey == 'order_create') &&
          _pedido?.id != null) {
        cargarPedido(_pedido!.id);
      }
    });
  }

  bool get puedeEditarRestauranteId {
    final usuario = _sessionService.user;
    if (usuario == null) return false;

    if (usuario.isSuperuser || usuario.tipoUsuario == 'administrador') {
      return _pedido == null;
    }
    return false;
  }

  bool get puedeEditarCocinaCentralId {
    final usuario = _sessionService.user;
    if (usuario == null) return false;

    if (usuario.isSuperuser || usuario.tipoUsuario == 'administrador') {
      return _pedido == null;
    }
    return false;
  }

  bool get puedeEditarFechaEntregaEstimada {
    final usuario = _sessionService.user;
    if (usuario == null) return false;

    return usuario.isSuperuser || usuario.tipoUsuario == 'administrador';
  }

  bool get puedeEditarFechaEntregaReal {
    final usuario = _sessionService.user;
    if (usuario == null) return false;

    if (usuario.isSuperuser || usuario.tipoUsuario == 'administrador') {
      return true;
    }

    if (usuario.tipoUsuario == 'cocina_central') {
      return true;
    }

    if (usuario.tipoUsuario == 'empleado') {
      final permisos = _sessionService.permisos;
      if (_propietario?.tipoUsuario != 'cocina_central') {
        return false;
      }
      return permisos?.puedeEditarPedidos == true;
    }

    return false;
  }

  bool get puedeEditarEstado {
    final usuario = _sessionService.user;
    if (usuario == null) return false;

    if (usuario.isSuperuser || usuario.tipoUsuario == 'administrador') {
      return true;
    }

    if (usuario.tipoUsuario == 'cocina_central') {
      return true;
    }

    if (usuario.tipoUsuario == 'empleado') {
      if (_propietario?.tipoUsuario != 'cocina_central') {
        return false;
      }
      final permisos = _sessionService.permisos;
      return permisos?.puedeEditarPedidos == true;
    }

    return false;
  }

  bool get puedeEditarNotas {
    final usuario = _sessionService.user;
    if (usuario == null) return false;

    if (usuario.isSuperuser || usuario.tipoUsuario == 'administrador') {
      return true;
    }

    if (usuario.tipoUsuario == 'restaurante') {
      return true;
    }

    if (usuario.tipoUsuario == 'empleado') {
      final permisos = _sessionService.permisos;
      if (_propietario?.tipoUsuario != 'restaurante') {
        return false;
      }
      return permisos?.puedeEditarPedidos == true;
    }

    return false;
  }

  bool get puedeEditarTipoPedido {
    final usuario = _sessionService.user;
    if (usuario == null) return false;

    return false;
  }

  bool get puedeEditarUrgente {
    final usuario = _sessionService.user;
    if (usuario == null) return false;

    if (usuario.isSuperuser || usuario.tipoUsuario == 'administrador') {
      return true;
    }

    if (usuario.tipoUsuario == 'restaurante') {
      return true;
    }

    if (usuario.tipoUsuario == 'empleado') {
      final permisos = _sessionService.permisos;
      if (_propietario?.tipoUsuario != 'restaurante') {
        return false;
      }
      return permisos?.puedeEditarPedidos == true;
    }

    return false;
  }

  bool get puedeEditarMotivoCancelacion {
    final usuario = _sessionService.user;
    if (usuario == null) return false;

    if (usuario.isSuperuser || usuario.tipoUsuario == 'administrador') {
      return true;
    }

    if (usuario.tipoUsuario == 'cocina_central') {
      return true;
    }

    if (usuario.tipoUsuario == 'empleado') {
      final permisos = _sessionService.permisos;
      if (_propietario?.tipoUsuario != 'cocina_central') {
        return false;
      }
      return permisos?.puedeEditarPedidos == true;
    }

    return false;
  }

  bool get esCampoSoloLectura => true;
  bool get puedeEditarId => false;
  bool get puedeEditarFechaPedido => false;
  bool get puedeEditarMontoTotal => false;

  bool get tieneAlgunCampoEditable {
    return puedeEditarRestauranteId ||
        puedeEditarCocinaCentralId ||
        puedeEditarFechaEntregaEstimada ||
        puedeEditarFechaEntregaReal ||
        puedeEditarEstado ||
        puedeEditarNotas ||
        puedeEditarTipoPedido ||
        puedeEditarUrgente ||
        puedeEditarMotivoCancelacion;
  }

  Future<void> cargarPedido(int pedidoId) async {
    _setLoading(true);
    try {
      final pedidoCargado = await _interactor.obtenerPedidoDetalle(pedidoId);
      _pedido = pedidoCargado;
      _error = null;
    } catch (e) {
      _error = 'Error al cargar el pedido: $e';
      if (kDebugMode) {
        print('Error en cargarPedido: $e');
      }
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> guardarCambios(Map<String, dynamic> cambios) async {
    if (_pedido == null) return false;

    _setLoading(true);
    try {
      final Map<String, dynamic> cambiosPermitidos = {};

      if (puedeEditarRestauranteId && cambios.containsKey('restauranteId')) {
        cambiosPermitidos['restauranteId'] = cambios['restauranteId'];
      }

      if (puedeEditarCocinaCentralId &&
          cambios.containsKey('cocinaCentralId')) {
        cambiosPermitidos['cocinaCentralId'] = cambios['cocinaCentralId'];
      }

      if (puedeEditarFechaEntregaEstimada &&
          cambios.containsKey('fechaEntregaEstimada')) {
        cambiosPermitidos['fechaEntregaEstimada'] =
            cambios['fechaEntregaEstimada'];
      }

      if (puedeEditarFechaEntregaReal &&
          cambios.containsKey('fechaEntregaReal')) {
        cambiosPermitidos['fechaEntregaReal'] = cambios['fechaEntregaReal'];
      }

      if (puedeEditarEstado && cambios.containsKey('estado')) {
        cambiosPermitidos['estado'] = cambios['estado'];
      }

      if (puedeEditarNotas && cambios.containsKey('notas')) {
        cambiosPermitidos['notas'] = cambios['notas'];
      }

      if (puedeEditarTipoPedido && cambios.containsKey('tipoPedido')) {
        cambiosPermitidos['tipoPedido'] = cambios['tipoPedido'];
      }

      if (puedeEditarUrgente && cambios.containsKey('urgente')) {
        cambiosPermitidos['urgente'] = cambios['urgente'];
      }

      if (puedeEditarMotivoCancelacion &&
          cambios.containsKey('motivoCancelacion')) {
        cambiosPermitidos['motivoCancelacion'] = cambios['motivoCancelacion'];
      }

      final Pedido pedidoActualizado = Pedido(
        id: _pedido!.id,
        restauranteId:
            cambiosPermitidos['restauranteId'] ?? _pedido!.restauranteId,
        restauranteNombre: _pedido!.restauranteNombre,
        cocinaCentralId:
            cambiosPermitidos['cocinaCentralId'] ?? _pedido!.cocinaCentralId,
        cocinaCentralNombre: _pedido!.cocinaCentralNombre,
        fechaPedido: _pedido!.fechaPedido,
        fechaEntregaEstimada:
            cambiosPermitidos['fechaEntregaEstimada'] ??
            _pedido!.fechaEntregaEstimada,
        fechaEntregaReal:
            cambiosPermitidos['fechaEntregaReal'] ?? _pedido!.fechaEntregaReal,
        estado: cambiosPermitidos['estado'] ?? _pedido!.estado,
        montoTotal: _pedido!.montoTotal,
        notas: cambiosPermitidos['notas'] ?? _pedido!.notas,
        tipoPedido: cambiosPermitidos['tipoPedido'] ?? _pedido!.tipoPedido,
        urgente: cambiosPermitidos['urgente'] ?? _pedido!.urgente,
        motivoCancelacion:
            cambiosPermitidos['motivoCancelacion'] ??
            _pedido!.motivoCancelacion,
        productos: _pedido!.productos,
      );

      final resultado = await _interactor.actualizarPedido(pedidoActualizado);
      if (resultado) {
        _pedido = pedidoActualizado;
        _error = null;
        _eventBus.publishDataChanged('order_update');
      } else {
        _error = 'No se pudo guardar los cambios';
      }
      return resultado;
    } catch (e) {
      _error = 'Error al guardar los cambios: $e';
      if (kDebugMode) {
        print('Error en guardarCambios: $e');
      }
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
