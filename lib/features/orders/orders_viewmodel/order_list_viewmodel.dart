import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:foodflow_app/core/services/usuario_sesion_service.dart';
import 'package:foodflow_app/core/services/event_bus_service.dart';
import 'package:foodflow_app/features/orders/orders_interactor/orders_interactor.dart';
import 'package:foodflow_app/features/orders/orders_model/orders_model.dart';
import 'package:foodflow_app/models/user_model.dart';
import 'package:foodflow_app/models/pedido_model.dart';

class OrderListViewModel extends ChangeNotifier {
  final OrdersInteractor _interactor = OrdersInteractor();
  final UserSessionService _sessionService = UserSessionService();
  final EventBusService _eventBus = EventBusService();

  OrdersModel _model = OrdersModel(isLoading: true);
  DateTime? _ultimaActualizacion;
  StreamSubscription<String>? _dataChangedSubscription;
  StreamSubscription<RefreshEvent>? _eventSubscription;
  Timer? _debounceTimer;

  String _estadoSeleccionado = '';
  String _tipoPedidoSeleccionado = '';
  bool? _urgenteSeleccionado;
  double? _importeMin;
  double? _importeMax;
  String _busquedaTexto = '';
  DateTime? _fechaInicio;
  DateTime? _fechaFin;

  OrdersModel get model => _model;
  DateTime? get ultimaActualizacion => _ultimaActualizacion;

  String get estadoSeleccionado => _estadoSeleccionado;
  String get tipoPedidoSeleccionado => _tipoPedidoSeleccionado;
  bool? get urgenteSeleccionado => _urgenteSeleccionado;
  double? get importeMin => _importeMin;
  double? get importeMax => _importeMax;
  String get busquedaTexto => _busquedaTexto;
  DateTime? get fechaInicio => _fechaInicio;
  DateTime? get fechaFin => _fechaFin;

  bool get puedeVerPedidos => _interactor.puedeVerPedidos();
  bool get puedeCrearPedidos => _interactor.puedeCrearPedidos();
  bool get puedeEditarPedidos => _interactor.puedeEditarPedidos();

  List<Pedido> get pedidosFiltrados {
    if (!puedeVerPedidos) {
      return [];
    }

    return _model.filtrarPedidos(
      estado: _estadoSeleccionado,
      tipoPedido: _tipoPedidoSeleccionado,
      urgente: _urgenteSeleccionado,
      importeMin: _importeMin,
      importeMax: _importeMax,
      textoBusqueda: _busquedaTexto,
      fechaInicio: _fechaInicio,
      fechaFin: _fechaFin,
    );
  }

  OrderListViewModel() {
    _subscribeToEvents();
    _listenToEvents();
    _verificarPermisosYCargar();
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
      if (event.type == RefreshEventType.orders ||
          event.type == RefreshEventType.all) {
        _debouncedCargarPedidos();
      }
    });
  }

  void _subscribeToEvents() {
    _dataChangedSubscription = _eventBus.dataChangedStream.listen((eventKey) {
      if (eventKey == 'order_created' ||
          eventKey == 'order_updated' ||
          eventKey == 'order_status_changed' ||
          eventKey == 'responsive_scaffold_orders_refresh' ||
          eventKey == 'responsive_scaffold_all_refresh') {
        _debouncedCargarPedidos();
      }
    });
  }

  void _debouncedCargarPedidos() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      cargarPedidos();
    });
  }

  Future<void> _verificarPermisosYCargar() async {
    if (!puedeVerPedidos) {
      _model = _model.copyWith(
        isLoading: false,
        error: 'No tienes permisos para acceder a la gestión de pedidos',
      );
      notifyListeners();
      return;
    }
    await cargarPedidos();
  }

  Future<void> cargarPedidos() async {
    if (!puedeVerPedidos) {
      _model = _model.copyWith(
        isLoading: false,
        error: 'No tienes permisos para ver pedidos',
      );
      notifyListeners();
      return;
    }

    _setLoading(true);
    try {
      final filtros = _construirFiltrosAPI();
      final pedidos = await _interactor.obtenerPedidos(filtros: filtros);
      final usuarios = await _interactor.obtenerUsuariosRelacionados();

      _model = _model.copyWith(
        pedidos: pedidos,
        usuariosRelacionados: usuarios,
        isLoading: false,
        error: null,
        filtros: filtros,
      );
      _ultimaActualizacion = DateTime.now();
    } catch (e) {
      _model = _model.copyWith(
        isLoading: false,
        error: 'Error al cargar pedidos: $e',
      );
      if (kDebugMode) {
        print('Error en cargarPedidos: $e');
      }
    }
    notifyListeners();
  }

  Future<void> forzarRecarga() async {
    _ultimaActualizacion = null;
    await cargarPedidos();
  }

  Map<String, dynamic> _construirFiltrosAPI() {
    final Map<String, dynamic> filtros = {};

    if (_fechaInicio != null) {
      filtros['fecha_pedido__gte'] =
          _fechaInicio!.toIso8601String().split('T')[0];
    }
    if (_fechaFin != null) {
      filtros['fecha_pedido__lte'] = _fechaFin!.toIso8601String().split('T')[0];
    }

    if (_estadoSeleccionado.isNotEmpty) {
      filtros['estado'] = _estadoSeleccionado;
    }

    if (_tipoPedidoSeleccionado.isNotEmpty) {
      filtros['tipo_pedido'] = _tipoPedidoSeleccionado;
    }

    if (_urgenteSeleccionado != null) {
      filtros['urgente'] = _urgenteSeleccionado.toString();
    }

    if (_importeMin != null) {
      filtros['monto_total__gte'] = _importeMin;
    }
    if (_importeMax != null) {
      filtros['monto_total__lte'] = _importeMax;
    }

    final usuarioActual = _sessionService.user;
    if (usuarioActual != null) {
      if (usuarioActual.tipoUsuario == 'restaurante') {
        filtros['restaurante'] = usuarioActual.id;
      } else if (usuarioActual.tipoUsuario == 'cocina_central') {
        filtros['cocina_central'] = usuarioActual.id;
      } else if (usuarioActual.tipoUsuario == 'empleado') {
        final permisos = _sessionService.permisos;
        final empleadorId = usuarioActual.empleadorId;

        if (empleadorId != null && permisos?.puedeVerPedidos == true) {
          filtros['empleador_id'] = empleadorId;
        }
      }
    }

    return filtros;
  }

  void setEstadoFiltro(String estado) {
    if (!puedeVerPedidos) return;
    _estadoSeleccionado = estado;
    notifyListeners();
  }

  void setTipoPedidoFiltro(String tipoPedido) {
    if (!puedeVerPedidos) return;
    _tipoPedidoSeleccionado = tipoPedido;
    notifyListeners();
  }

  void setUrgenteFiltro(bool? urgente) {
    if (!puedeVerPedidos) return;
    _urgenteSeleccionado = urgente;
    notifyListeners();
  }

  void setImporteMin(double? min) {
    if (!puedeVerPedidos) return;
    _importeMin = min;
    notifyListeners();
  }

  void setImporteMax(double? max) {
    if (!puedeVerPedidos) return;
    _importeMax = max;
    notifyListeners();
  }

  void setBusquedaTexto(String texto) {
    if (!puedeVerPedidos) return;
    _busquedaTexto = texto;
    notifyListeners();
  }

  void setFechaInicio(DateTime? fecha) {
    if (!puedeVerPedidos) return;
    _fechaInicio = fecha;
    notifyListeners();
  }

  void setFechaFin(DateTime? fecha) {
    if (!puedeVerPedidos) return;
    _fechaFin = fecha;
    notifyListeners();
  }

  void limpiarFiltros() {
    if (!puedeVerPedidos) return;
    _estadoSeleccionado = '';
    _tipoPedidoSeleccionado = '';
    _urgenteSeleccionado = null;
    _importeMin = null;
    _importeMax = null;
    _busquedaTexto = '';
    _fechaInicio = null;
    _fechaFin = null;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _model = _model.copyWith(isLoading: loading);
    notifyListeners();
  }
}
