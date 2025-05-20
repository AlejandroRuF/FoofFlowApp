import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:foodflow_app/models/metricas_ventas_model.dart';
import 'package:foodflow_app/models/prevision_demanda_model.dart';

class MetricasMockService {
  Future<Map<String, dynamic>> obtenerResumenMetricasMock(int usuarioId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 800));

      final random = Random();

      final double ingresosActuales = 10000 + random.nextDouble() * 5000;
      final double gastosActuales = 6000 + random.nextDouble() * 3000;
      final double beneficioActuales = ingresosActuales - gastosActuales;
      final int productosVendidosActuales = 150 + random.nextInt(100);

      final double ingresosAnteriores =
          ingresosActuales * (0.8 + random.nextDouble() * 0.3);
      final double gastosAnteriores =
          gastosActuales * (0.8 + random.nextDouble() * 0.3);
      final double beneficioAnteriores = ingresosAnteriores - gastosAnteriores;
      final int productosVendidosAnteriores =
          (productosVendidosActuales * (0.7 + random.nextDouble() * 0.4))
              .toInt();

      final double variacionIngresos =
          ((ingresosActuales - ingresosAnteriores) / ingresosAnteriores) * 100;
      final double variacionGastos =
          ((gastosActuales - gastosAnteriores) / gastosAnteriores) * 100;
      final double variacionBeneficio =
          ((beneficioActuales - beneficioAnteriores) / beneficioAnteriores) *
          100;
      final double variacionVentas =
          ((productosVendidosActuales - productosVendidosAnteriores) /
              productosVendidosAnteriores) *
          100;

      final List<MetricasVentas> metricasDetalle = [];

      for (int i = 1; i <= 5; i++) {
        metricasDetalle.add(
          MetricasVentas(
            id: i,
            usuarioId: usuarioId,
            productoId: i,
            anio: DateTime.now().year,
            mes: DateTime.now().month,
            totalVendido: 20 + random.nextInt(30),
            ingresos: 2000 + random.nextDouble() * 1000,
            gastos: 1200 + random.nextDouble() * 600,
            beneficio: 800 + random.nextDouble() * 400,
          ),
        );
      }

      return {
        'actual': {
          'ingresos': ingresosActuales,
          'gastos': gastosActuales,
          'beneficio': beneficioActuales,
          'productos_vendidos': productosVendidosActuales,
        },
        'anterior': {
          'ingresos': ingresosAnteriores,
          'gastos': gastosAnteriores,
          'beneficio': beneficioAnteriores,
          'productos_vendidos': productosVendidosAnteriores,
        },
        'variacion': {
          'ingresos': variacionIngresos,
          'gastos': variacionGastos,
          'beneficio': variacionBeneficio,
          'productos_vendidos': variacionVentas,
        },
        'metricas_detalle': metricasDetalle,
      };
    } catch (e) {
      if (kDebugMode) {
        print('Error en obtenerResumenMetricasMock: $e');
      }
      return {
        'actual': {
          'ingresos': 0.0,
          'gastos': 0.0,
          'beneficio': 0.0,
          'productos_vendidos': 0,
        },
        'anterior': {
          'ingresos': 0.0,
          'gastos': 0.0,
          'beneficio': 0.0,
          'productos_vendidos': 0,
        },
        'variacion': {
          'ingresos': 0.0,
          'gastos': 0.0,
          'beneficio': 0.0,
          'productos_vendidos': 0.0,
        },
        'metricas_detalle': [],
      };
    }
  }

  Future<Map<String, dynamic>> obtenerResumenPrevisionesMock(
    int restauranteId,
  ) async {
    try {
      await Future.delayed(const Duration(milliseconds: 800));

      final random = Random();

      final now = DateTime.now();
      final int diaActual = now.day;
      int tramoActual;

      if (diaActual <= 10) {
        tramoActual = 1;
      } else if (diaActual <= 20) {
        tramoActual = 2;
      } else {
        tramoActual = 3;
      }

      // Lista de productos de ejemplo
      final productosNombres = [
        'Hamburguesa',
        'Pizza',
        'Ensalada',
        'Pasta',
        'Sushi',
        'Pollo',
        'Tacos',
        'Helado',
        'Café',
        'Postre',
      ];

      final List<Map<String, dynamic>> previsionesTramoActual = [];
      final List<PrevisionDemanda> todasPrevisiones = [];

      int totalDemandaPrevista = 0;
      double sumaVariacion = 0;
      int contadorEstimadas = 0;

      for (int i = 0; i < 5; i++) {
        final int demandaPrevista = 30 + random.nextInt(100);
        final double variacion =
            (random.nextDouble() * 30) - 15; // Entre -15% y +15%
        final bool esEstimada = random.nextBool();

        totalDemandaPrevista += demandaPrevista;
        sumaVariacion += variacion;
        if (esEstimada) contadorEstimadas++;

        previsionesTramoActual.add({
          'id': i + 1,
          'producto_id': i + 1,
          'producto_nombre': productosNombres[i],
          'demanda_prevista': demandaPrevista,
          'variacion_porcentual': variacion,
          'es_estimada': esEstimada,
        });

        todasPrevisiones.add(
          PrevisionDemanda(
            id: i + 1,
            tramoMes: tramoActual,
            restauranteId: restauranteId,
            productoId: i + 1,
            mes: now.month,
            anyo: now.year,
            demandaPrevista: demandaPrevista,
            variacionPorcentual: variacion,
            esEstimada: esEstimada,
          ),
        );
      }

      final double promedioVariacion = sumaVariacion / 5;
      final double porcentajeEstimadas = (contadorEstimadas / 5) * 100;

      return {
        'total_demanda_prevista': totalDemandaPrevista,
        'promedio_variacion': promedioVariacion,
        'porcentaje_estimadas': porcentajeEstimadas,
        'tramo_actual': tramoActual,
        'previsiones_tramo_actual': previsionesTramoActual,
        'todas_previsiones': todasPrevisiones,
      };
    } catch (e) {
      if (kDebugMode) {
        print('Error en obtenerResumenPrevisionesMock: $e');
      }
      return {
        'total_demanda_prevista': 0,
        'promedio_variacion': 0.0,
        'porcentaje_estimadas': 0.0,
        'tramo_actual': 0,
        'previsiones_tramo_actual': [],
        'todas_previsiones': [],
      };
    }
  }
}
