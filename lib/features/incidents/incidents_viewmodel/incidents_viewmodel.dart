import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:foodflow_app/features/incidents/incidents_model/incidents_model.dart';
import 'package:foodflow_app/models/incidencia_model.dart';
import 'package:foodflow_app/models/pedido_model.dart';

import '../incidents_interactor/incidents_interactor.dart';

class IncidentsViewModel extends ChangeNotifier {
  final IncidentsInteractor _interactor = IncidentsInteractor();

  IncidentsModel _model = IncidentsModel();

  List<Incidencia> get incidencias => _model.incidencias;
  bool get isLoading => _model.isLoading;
  String? get error => _model.error;
  final Map<String, dynamic> _filtrosActivos = {};
  Map<String, dynamic> get filtrosActivos => _filtrosActivos;
  String _busquedaTexto = '';
  String _estadoSeleccionado = '';
  int? _pedidoSeleccionado;
  int? _productoSeleccionado;
  int? _usuarioSeleccionado;
  DateTime? _fechaDesde;
  DateTime? _fechaHasta;
  bool get puedeVerIncidencias => _interactor.puedeVerIncidencias();
  bool get puedeCrearIncidencias => _interactor.puedeCrearIncidencias();
  String get tipoUsuario => _interactor.obtenerTipoUsuario();

  List<Incidencia> get incidenciasFiltradas {
    return _model.filtrarIncidencias(
      textoBusqueda: _busquedaTexto,
      estado: _estadoSeleccionado,
      pedidoId: _pedidoSeleccionado,
      productoId: _productoSeleccionado,
      usuarioId: _usuarioSeleccionado,
      fechaDesde: _fechaDesde,
      fechaHasta: _fechaHasta,
    );
  }

  void establecerBusquedaTexto(String texto) {
    _busquedaTexto = texto;
    notifyListeners();
  }

  void establecerEstadoFiltro(String estado) {
    _estadoSeleccionado = estado;
    notifyListeners();
  }

  void establecerPedidoFiltro(int? pedidoId) {
    _pedidoSeleccionado = pedidoId;
    notifyListeners();
  }

  void establecerProductoFiltro(int? productoId) {
    _productoSeleccionado = productoId;
    notifyListeners();
  }

  void establecerUsuarioFiltro(int? usuarioId) {
    _usuarioSeleccionado = usuarioId;
    notifyListeners();
  }

  DateTime? _normalizarFecha(DateTime? fecha, {required bool alFinalDelDia}) {
    if (fecha == null) return null;
    return DateTime(
      fecha.year,
      fecha.month,
      fecha.day,
      alFinalDelDia ? 23 : 0,
      alFinalDelDia ? 59 : 0,
      alFinalDelDia ? 59 : 0,
    );
  }

  void establecerFechaDesde(DateTime? fecha) {
    fecha = _normalizarFecha(fecha, alFinalDelDia: false);
    _fechaDesde = fecha;
    _filtrosActivos['fecha_desde'] = fecha;
    if (kDebugMode) {
      print("fecha desde $_fechaDesde");
    }
    notifyListeners();
  }

  void establecerFechaHasta(DateTime? fecha) {
    fecha = _normalizarFecha(fecha, alFinalDelDia: true);
    _fechaHasta = fecha;
    _filtrosActivos['fecha_hasta'] = fecha;
    if (kDebugMode) {
      print("fecha hasta $_fechaHasta");
    }
    notifyListeners();
  }

  void limpiarFiltros() {
    _busquedaTexto = '';
    _estadoSeleccionado = '';
    _pedidoSeleccionado = null;
    _productoSeleccionado = null;
    _usuarioSeleccionado = null;
    _fechaDesde = null;
    _fechaHasta = null;
    notifyListeners();
  }

  Future<void> cargarIncidencias() async {
    _model = _model.copyWith(isLoading: true, error: null);
    notifyListeners();

    try {
      Map<String, dynamic>? filtrosAPI;
      if (_estadoSeleccionado.isNotEmpty ||
          _pedidoSeleccionado != null ||
          _productoSeleccionado != null ||
          _usuarioSeleccionado != null) {
        filtrosAPI = {};

        if (_estadoSeleccionado.isNotEmpty) {
          filtrosAPI['estado'] = _estadoSeleccionado;
        }
        if (_pedidoSeleccionado != null) {
          filtrosAPI['pedido'] = _pedidoSeleccionado.toString();
        }
        if (_productoSeleccionado != null) {
          filtrosAPI['producto'] = _productoSeleccionado.toString();
        }
        if (_usuarioSeleccionado != null) {
          filtrosAPI['reportado_por'] = _usuarioSeleccionado.toString();
        }
      }

      final nuevosResultados = await _interactor.obtenerIncidencias(
        filtros: filtrosAPI,
      );

      _model = nuevosResultados.copyWith(isLoading: false);
      notifyListeners();
    } catch (e) {
      _model = _model.copyWith(
        isLoading: false,
        error: 'Error al cargar incidencias: $e',
      );
      notifyListeners();
    }
  }

  Future<List<Pedido>> obtenerPedidosUsuario() async {
    return await _interactor.obtenerPedidosUsuario();
  }

  Future<bool> crearIncidencia({
    required int pedidoId,
    required int productoId,
    required int nuevaCantidad,
    required String descripcion,
  }) async {
    try {
      final resultado = await _interactor.crearIncidencia(
        pedidoId: pedidoId,
        productoId: productoId,
        nuevaCantidad: nuevaCantidad,
        descripcion: descripcion,
      );

      if (resultado) {
        await cargarIncidencias();
      }

      return resultado;
    } catch (e) {
      _model = _model.copyWith(error: 'Error al crear incidencia: $e');
      notifyListeners();
      return false;
    }
  }
}
