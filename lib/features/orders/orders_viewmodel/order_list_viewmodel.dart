import 'package:flutter/foundation.dart';
import 'package:foodflow_app/core/services/usuario_sesion_service.dart';
import 'package:foodflow_app/features/orders/orders_interactor/orders_interactor.dart';
import 'package:foodflow_app/features/orders/orders_model/orders_model.dart';
import 'package:foodflow_app/models/user_model.dart';
import 'package:foodflow_app/models/pedido_model.dart';

class OrderListViewModel extends ChangeNotifier {
  final OrdersInteractor _interactor = OrdersInteractor();
  final UserSessionService _sessionService = UserSessionService();

  OrdersModel _model = OrdersModel(isLoading: true);

  String _estadoSeleccionado = '';
  String _tipoPedidoSeleccionado = '';
  bool? _urgenteSeleccionado;
  double? _importeMin;
  double? _importeMax;
  String _busquedaTexto = '';
  DateTime? _fechaInicio;
  DateTime? _fechaFin;

  OrdersModel get model => _model;

  String get estadoSeleccionado => _estadoSeleccionado;
  String get tipoPedidoSeleccionado => _tipoPedidoSeleccionado;
  bool? get urgenteSeleccionado => _urgenteSeleccionado;
  double? get importeMin => _importeMin;
  double? get importeMax => _importeMax;
  String get busquedaTexto => _busquedaTexto;
  DateTime? get fechaInicio => _fechaInicio;
  DateTime? get fechaFin => _fechaFin;

  List<Pedido> get pedidosFiltrados {
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
    cargarPedidos();
  }

  Future<void> cargarPedidos() async {
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

        if (empleadorId != null && permisos?.puedeVerPedidos == true) {}
      }
    }

    return filtros;
  }

  void setEstadoFiltro(String estado) {
    _estadoSeleccionado = estado;
    notifyListeners();
  }

  void setTipoPedidoFiltro(String tipoPedido) {
    _tipoPedidoSeleccionado = tipoPedido;
    notifyListeners();
  }

  void setUrgenteFiltro(bool? urgente) {
    _urgenteSeleccionado = urgente;
    notifyListeners();
  }

  void setImporteMin(double? min) {
    _importeMin = min;
    notifyListeners();
  }

  void setImporteMax(double? max) {
    _importeMax = max;
    notifyListeners();
  }

  void setBusquedaTexto(String texto) {
    _busquedaTexto = texto;
    notifyListeners();
  }

  void setFechaInicio(DateTime? fecha) {
    _fechaInicio = fecha;
    notifyListeners();
  }

  void setFechaFin(DateTime? fecha) {
    _fechaFin = fecha;
    notifyListeners();
  }

  void limpiarFiltros() {
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
