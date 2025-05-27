import 'package:flutter/foundation.dart';
import 'package:foodflow_app/core/services/usuario_sesion_service.dart';
import 'package:foodflow_app/features/orders/orders_interactor/orders_interactor.dart';
import 'package:foodflow_app/features/orders/orders_model/orders_model.dart';
import 'package:foodflow_app/models/user_model.dart';

class OrderListViewModel extends ChangeNotifier {
  final OrdersInteractor _interactor = OrdersInteractor();
  final UserSessionService _sessionService = UserSessionService();

  OrdersModel _model = OrdersModel(isLoading: true);
  DateTime? _fechaInicio;
  DateTime? _fechaFin;
  User? _usuarioFiltro;

  OrdersModel get model => _model;
  DateTime? get fechaInicio => _fechaInicio;
  DateTime? get fechaFin => _fechaFin;
  User? get usuarioFiltro => _usuarioFiltro;

  OrderListViewModel() {
    cargarPedidos();
  }

  Future<void> cargarPedidos() async {
    _setLoading(true);
    try {
      final filtros = _construirFiltros();
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

  Map<String, dynamic> _construirFiltros() {
    final Map<String, dynamic> filtros = {};

    if (_fechaInicio != null) {
      filtros['fecha_pedido__gte'] =
          _fechaInicio!.toIso8601String().split('T')[0];
    }

    if (_fechaFin != null) {
      filtros['fecha_pedido__lte'] = _fechaFin!.toIso8601String().split('T')[0];
    }

    final usuarioActual = _sessionService.user;
    if (usuarioActual != null) {
      if (usuarioActual.tipoUsuario == 'restaurante') {
        filtros['restaurante'] = usuarioActual.id;

        if (_usuarioFiltro != null &&
            _usuarioFiltro!.tipoUsuario == 'cocina_central') {
          filtros['cocina_central'] = _usuarioFiltro!.id;
        }
      } else if (usuarioActual.tipoUsuario == 'cocina_central') {
        filtros['cocina_central'] = usuarioActual.id;

        if (_usuarioFiltro != null &&
            _usuarioFiltro!.tipoUsuario == 'restaurante') {
          filtros['restaurante'] = _usuarioFiltro!.id;
        }
      } else if (usuarioActual.tipoUsuario == 'empleado') {
        final permisos = _sessionService.permisos;
        final empleadorId = usuarioActual.empleadorId;

        if (empleadorId != null && permisos?.puedeVerPedidos == true) {
          final empleador = _model.usuariosRelacionados.firstWhere(
            (u) => u.id == empleadorId,
            orElse:
                () => User(
                  id: empleadorId,
                  email: '',
                  nombre: '',
                  tipoUsuario: '',
                ),
          );

          if (empleador.tipoUsuario == 'restaurante') {
            filtros['restaurante'] = empleadorId;
          } else if (empleador.tipoUsuario == 'cocina_central') {
            filtros['cocina_central'] = empleadorId;
          }
        }
      }
    }

    return filtros;
  }

  void setFechaInicio(DateTime? fecha) {
    _fechaInicio = fecha;
    cargarPedidos();
  }

  void setFechaFin(DateTime? fecha) {
    _fechaFin = fecha;
    cargarPedidos();
  }

  void setUsuarioFiltro(User? usuario) {
    _usuarioFiltro = usuario;
    cargarPedidos();
  }

  void limpiarFiltros() {
    _fechaInicio = null;
    _fechaFin = null;
    _usuarioFiltro = null;
    cargarPedidos();
  }

  void _setLoading(bool loading) {
    _model = _model.copyWith(isLoading: loading);
    notifyListeners();
  }
}
