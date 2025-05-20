import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:foodflow_app/features/dashboard/dashboard_interactor/dashboard_interactor.dart';
import 'package:foodflow_app/models/user_model.dart';

import '../dashboard_model/dashboard_model.dart';

class DashboardViewModel extends ChangeNotifier {
  final _interactor = DashboardInteractor();

  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _dashboardData;
  DashboardModel? _dashboardModel;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get dashboardData => _dashboardData;
  DashboardModel? get dashboardModel => _dashboardModel;

  Map<String, dynamic>? get metricasVentas =>
      _dashboardData?['metricas_ventas'];
  Map<String, dynamic>? get previsionDemanda =>
      _dashboardData?['previsiones_demanda'];
  String get tipoUsuario => _dashboardData?['tipo_usuario'] ?? 'desconocido';
  User? get usuario => _dashboardData?['usuario'];

  Future<void> cargarDatosDashboard() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final resultado = await _interactor.obtenerDatosDashboard();

      if (resultado['success'] == true) {
        _dashboardData = resultado;
        _dashboardModel = DashboardModel.fromInteractorData(resultado);
      } else {
        _errorMessage = resultado['error'] ?? 'Error al cargar el dashboard';
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error en cargarDatosDashboard: $e');
      }
      _errorMessage = 'Error al cargar los datos del dashboard: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> recargarDatos() async {
    try {
      final resultado = await _interactor.recargarDatosDashboard();

      if (resultado['success'] == true) {
        _dashboardData = resultado;
        _dashboardModel = DashboardModel.fromInteractorData(resultado);
        _errorMessage = null;
      } else {
        _errorMessage = resultado['error'] ?? 'Error al recargar el dashboard';
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error en recargarDatos: $e');
      }
      _errorMessage = 'Error al recargar los datos: $e';
    } finally {
      notifyListeners();
    }
  }

  bool debeMostrarPrevisiones() {
    final tipo = tipoUsuario.toLowerCase();
    return tipo == 'administrador' || tipo == 'restaurante';
  }

  String obtenerFechaActualizacionTexto() {
    if (_dashboardModel == null) {
      return 'No disponible';
    }

    final fecha = _dashboardModel!.fechaActualizacion;
    return 'Actualizado: ${fecha.day}/${fecha.month}/${fecha.year} ${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}';
  }

  bool hayMetricasDisponibles() {
    return metricasVentas != null &&
        metricasVentas!.isNotEmpty &&
        metricasVentas!['actual'] != null;
  }

  bool hayPrevisionesDisponibles() {
    return previsionDemanda != null &&
        previsionDemanda!.isNotEmpty &&
        previsionDemanda!['previsiones_tramo_actual'] != null;
  }

  Map<String, dynamic>? obtenerProductoMasPopular() {
    if (!hayPrevisionesDisponibles()) {
      return null;
    }

    final previsiones = previsionDemanda!['previsiones_tramo_actual'] as List;
    if (previsiones.isEmpty) {
      return null;
    }

    Map<String, dynamic>? mejorProducto;
    int maxDemanda = 0;

    for (final prevision in previsiones) {
      final demanda = prevision['demanda_prevista'] as int? ?? 0;
      if (demanda > maxDemanda) {
        maxDemanda = demanda;
        mejorProducto = prevision;
      }
    }

    return mejorProducto;
  }

  double obtenerPorcentajeCrecimiento() {
    if (!hayMetricasDisponibles()) {
      return 0.0;
    }

    final variacion = metricasVentas!['variacion'];
    if (variacion == null) {
      return 0.0;
    }

    return variacion['beneficio'] as double? ?? 0.0;
  }
}
