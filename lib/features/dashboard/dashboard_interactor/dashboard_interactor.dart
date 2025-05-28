import 'package:flutter/foundation.dart';
import 'package:foodflow_app/core/services/incidencias_service.dart';
import 'package:foodflow_app/core/services/inventario_service.dart';
import 'package:foodflow_app/core/services/metricas_y_previsiones_service.dart';
import 'package:foodflow_app/core/services/pedidos_service.dart';
import 'package:foodflow_app/core/services/usuario_sesion_service.dart';
import 'package:foodflow_app/models/user_model.dart';

class DashboardInteractor {
  final _metricasMockService = MetricasMockService();
  final _sessionService = UserSessionService();
  final _pedidosService = PedidosService();
  final _inventarioService = InventarioService();
  final _incidenciasService = IncidenciasService();

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

      resultado['metricas_ventas'] = await _metricasMockService
          .obtenerResumenMetricasMock(usuarioId);

      if (tipoUsuario == 'administrador' ||
          tipoUsuario == 'restaurante' ||
          tipoUsuario == 'cocina_central' ||
          (tipoUsuario == 'empleado' &&
              (_sessionService.permisos?.puedeVerPedidos ?? false))) {
        final pedidosActivos =
            await _pedidosService.obtenerResumenPedidosDashboard();
        resultado['pedidos_activos'] = pedidosActivos;
      }

      switch (tipoUsuario) {
        case 'administrador':
        case 'restaurante':
          resultado['previsiones_demanda'] = await _metricasMockService
              .obtenerResumenPrevisionesMock(usuarioId);
          resultado['inventario'] =
              await _inventarioService.obtenerResumenInventarioDashboard();
          resultado['incidencias'] =
              await _incidenciasService.obtenerResumenIncidenciasDashboard();
          break;

        case 'cocina_central':
          resultado['inventario'] =
              await _inventarioService.obtenerResumenInventarioDashboard();
          resultado['incidencias'] =
              await _incidenciasService.obtenerResumenIncidenciasDashboard();
          break;

        case 'empleado':
          final permisos = _sessionService.permisos;
          final puedeVerProductos = permisos?.puedeVerProductos ?? false;
          final puedeVerAlmacenes = permisos?.puedeVerAlmacenes ?? false;

          if (puedeVerProductos || puedeVerAlmacenes) {
            resultado['inventario'] =
                await _inventarioService.obtenerResumenInventarioDashboard();
          }

          if (_sessionService.permisos?.puedeVerIncidencias ?? false) {
            resultado['incidencias'] =
                await _incidenciasService.obtenerResumenIncidenciasDashboard();
          }

          if (_sessionService.permisos?.puedeVerPrevisionDemanda ?? false) {
            resultado['previsiones_demanda'] = await _metricasMockService
                .obtenerResumenPrevisionesMock(usuarioId);
          }
          break;

        default:
          if (kDebugMode) {
            print(
              'Tipo de usuario no reconocido: $tipoUsuario, usando perfil por defecto',
            );
          }
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
