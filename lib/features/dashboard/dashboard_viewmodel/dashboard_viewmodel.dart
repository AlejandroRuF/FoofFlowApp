import 'package:flutter/foundation.dart';
import 'package:foodflow_app/core/services/usuario_sesion_service.dart';
import 'package:foodflow_app/features/dashboard/dashboard_interactor/dashboard_interactor.dart';
import 'package:foodflow_app/models/user_model.dart';

import '../dashboard_model/dashboard_model.dart';

class DashboardViewModel extends ChangeNotifier {
  final _interactor = DashboardInteractor();
  final _sessionService = UserSessionService();

  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _dashboardData;
  DashboardModel? _dashboardModel;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get dashboardData => _dashboardData;
  DashboardModel? get dashboardModel => _dashboardModel;

  Map<String, dynamic>? get metricasVentas {
    if (!tienePermisoVerMetricas) return <String, dynamic>{};
    return _dashboardData?['metricas_ventas'];
  }

  Map<String, dynamic>? get previsionDemanda {
    if (!tienePermisoVerPrevisionDemanda) return <String, dynamic>{};
    return _dashboardData?['previsiones_demanda'];
  }

  Map<String, dynamic>? get pedidosActivos {
    if (!tienePermisoVerPedidos) return <String, dynamic>{};
    return _dashboardData?['pedidos_activos'];
  }

  Map<String, dynamic>? get inventario {
    if (!tienePermisoVerInventario) return <String, dynamic>{};
    return _dashboardData?['inventario'];
  }

  Map<String, dynamic>? get incidencias {
    if (!tienePermisoVerIncidencias) return <String, dynamic>{};
    return _dashboardData?['incidencias'];
  }

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

  bool get tienePermisoVerPrevisionDemanda {
    if (tipoUsuario == 'empleado') {
      return _sessionService.permisos?.puedeVerPrevisionDemanda ?? false;
    }
    final tipo = tipoUsuario.toLowerCase();
    return tipo == 'administrador' || tipo == 'restaurante';
  }

  bool get tienePermisoVerPedidos {
    if (tipoUsuario == 'empleado') {
      return _sessionService.permisos?.puedeVerPedidos ?? false;
    }
    return true;
  }

  bool get tienePermisoVerInventario {
    if (tipoUsuario == 'empleado') {
      final permisos = _sessionService.permisos;
      final puedeVerProductos = permisos?.puedeVerProductos ?? false;
      final puedeVerAlmacenes = permisos?.puedeVerAlmacenes ?? false;
      return puedeVerProductos || puedeVerAlmacenes;
    }
    return true;
  }

  bool get tienePermisoVerIncidencias {
    if (tipoUsuario == 'empleado') {
      return _sessionService.permisos?.puedeVerIncidencias ?? false;
    }
    return true;
  }

  bool get tienePermisoVerMetricas {
    if (tipoUsuario == 'empleado') {
      return _sessionService.permisos?.puedeVerMetricas ?? false;
    }
    return true;
  }

  bool debeMostrarPrevisiones() => true;
  bool debeMostrarPedidos() => true;
  bool debeMostrarInventario() => true;
  bool debeMostrarIncidencias() => true;

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
