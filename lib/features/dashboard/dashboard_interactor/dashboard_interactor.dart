import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:foodflow_app/core/services/incidencias_service.dart';
import 'package:foodflow_app/core/services/inventario_service.dart';
import 'package:foodflow_app/core/services/metricas_y_previsiones_service.dart';
import 'package:foodflow_app/core/services/pedidos_service.dart';
import 'package:foodflow_app/core/services/usuario_sesion_service.dart';
import 'package:foodflow_app/core/services/productos_service.dart';
import 'package:foodflow_app/models/user_model.dart';

class DashboardInteractor {
  final _metricasMockService = MetricasMockService();
  final _sessionService = UserSessionService();
  final _pedidosService = PedidosService();
  final _inventarioService = InventarioService();
  final _incidenciasService = IncidenciasService();
  final _productosService = ProductosService();
  final _random = Random();

  static const int _maxDemandaPrevista = 150;
  static const int _minDemandaPrevista = 10;
  static const double _maxVariacionPorcentual = 25.0;
  static const double _minVariacionPorcentual = -20.0;

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
          resultado['previsiones_demanda'] = await _generarPrevisionesDemanda();
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
            resultado['previsiones_demanda'] =
                await _generarPrevisionesDemanda();
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

  Future<Map<String, dynamic>> _generarPrevisionesDemanda() async {
    try {
      final productos = await _productosService.obtenerProductos();

      final DateTime ahora = DateTime.now();
      final int diaDelMes = ahora.day;

      int tramoActual;
      if (diaDelMes <= 10) {
        tramoActual = 1;
      } else if (diaDelMes <= 20) {
        tramoActual = 2;
      } else {
        tramoActual = 3;
      }

      final productosSeleccionados = productos.toList();

      final List<Map<String, dynamic>> previsionesTramoActual = [];

      for (int i = 0; i < productosSeleccionados.length; i++) {
        final producto = productosSeleccionados[i];
        final demandaPrevista =
            _minDemandaPrevista +
            _random.nextInt(_maxDemandaPrevista - _minDemandaPrevista + 1);
        final demandaAnterior =
            _minDemandaPrevista +
            _random.nextInt(_maxDemandaPrevista - _minDemandaPrevista + 1);
        final variacionPorcentual =
            demandaAnterior > 0
                ? ((demandaPrevista - demandaAnterior) / demandaAnterior * 100)
                : 0.0;
        final variacionLimitada = variacionPorcentual.clamp(
          _minVariacionPorcentual,
          _maxVariacionPorcentual,
        );

        previsionesTramoActual.add({
          'producto_id': producto.id,
          'producto_nombre': producto.nombre,
          'demanda_prevista': demandaPrevista,
          'demanda_anterior': demandaAnterior,
          'variacion_porcentual': variacionLimitada,
          'fecha_inicio_tramo': DateTime(
            ahora.year,
            ahora.month,
            _obtenerDiaInicioTramo(tramoActual),
          ),
          'fecha_fin_tramo': DateTime(
            ahora.year,
            ahora.month,
            _obtenerDiaFinTramo(tramoActual, ahora),
          ),
        });
      }

      return {
        'tramo_actual': tramoActual,
        'previsiones_tramo_actual': previsionesTramoActual,
        'fecha_actualizacion': ahora.toIso8601String(),
        'total_productos_prevision': previsionesTramoActual.length,
      };
    } catch (e) {
      if (kDebugMode) {
        print('Error al generar previsiones de demanda: $e');
      }
      return {
        'tramo_actual': 1,
        'previsiones_tramo_actual': [],
        'fecha_actualizacion': DateTime.now().toIso8601String(),
        'total_productos_prevision': 0,
      };
    }
  }

  int _obtenerDiaInicioTramo(int tramo) {
    switch (tramo) {
      case 1:
        return 1;
      case 2:
        return 11;
      case 3:
        return 21;
      default:
        return 1;
    }
  }

  int _obtenerDiaFinTramo(int tramo, DateTime fecha) {
    switch (tramo) {
      case 1:
        return 10;
      case 2:
        return 20;
      case 3:
        return DateTime(fecha.year, fecha.month + 1, 0).day;
      default:
        return 10;
    }
  }

  Future<Map<String, dynamic>> recargarDatosDashboard() async {
    return await obtenerDatosDashboard();
  }
}
