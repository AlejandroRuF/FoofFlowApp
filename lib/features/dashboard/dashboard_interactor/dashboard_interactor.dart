import 'package:flutter/foundation.dart';
import 'package:foodflow_app/core/services/metricas_y_previsiones_service.dart';
import 'package:foodflow_app/core/services/user_sesion_service.dart';
import 'package:foodflow_app/models/user_model.dart';

class DashboardInteractor {
  final _metricasMockService = MetricasMockService();
  final _sessionService = UserSessionService();

  Future<Map<String, dynamic>> obtenerDatosDashboard() async {
    try {
      final User? currentUser = _sessionService.user;

      if (currentUser == null) {
        if (kDebugMode) {
          print('No hay usuario en sesión');
        }
        return {'error': 'No hay usuario en sesión', 'success': false};
      }

      final int usuarioId = currentUser.id;
      final String tipoUsuario = currentUser.tipoUsuario;

      Map<String, dynamic> resultado = {
        'success': true,
        'tipo_usuario': tipoUsuario,
        'usuario': currentUser,
      };

      switch (tipoUsuario) {
        case 'administrador':
          resultado['metricas_ventas'] = await _metricasMockService
              .obtenerResumenMetricasMock(usuarioId);
          resultado['previsiones_demanda'] = await _metricasMockService
              .obtenerResumenPrevisionesMock(usuarioId);
          break;

        case 'cocina_central':
          resultado['metricas_ventas'] = await _metricasMockService
              .obtenerResumenMetricasMock(usuarioId);
          break;

        case 'restaurante':
          resultado['metricas_ventas'] = await _metricasMockService
              .obtenerResumenMetricasMock(usuarioId);
          resultado['previsiones_demanda'] = await _metricasMockService
              .obtenerResumenPrevisionesMock(usuarioId);
          break;

        case 'empleado':
          resultado['metricas_ventas'] = await _metricasMockService
              .obtenerResumenMetricasMock(usuarioId);
          break;

        default:
          if (kDebugMode) {
            print(
              'Tipo de usuario no reconocido: $tipoUsuario, usando perfil por defecto',
            );
          }
          resultado['metricas_ventas'] = await _metricasMockService
              .obtenerResumenMetricasMock(usuarioId);
          resultado['previsiones_demanda'] = await _metricasMockService
              .obtenerResumenPrevisionesMock(usuarioId);
          break;
      }

      return resultado;
    } catch (e) {
      if (kDebugMode) {
        print('Error en obtenerDatosDashboard: $e');
      }
      return {
        'error': 'Error al obtener datos del dashboard: $e',
        'success': false,
      };
    }
  }

  Future<Map<String, dynamic>> recargarDatosDashboard() async {
    return await obtenerDatosDashboard();
  }
}
