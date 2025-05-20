import 'package:flutter/foundation.dart';
import 'package:foodflow_app/core/constants/api_endpoints.dart';
import 'package:foodflow_app/core/services/api_services.dart';
import 'package:foodflow_app/models/metricas_ventas_model.dart';

class MetricasVentasService {
  Future<List<MetricasVentas>> obtenerTodasMetricas() async {
    try {
      final response = await ApiServices.dio.get(ApiEndpoints.metricasVentas);

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((item) => MetricasVentas.fromJson(item)).toList();
      } else {
        if (kDebugMode) {
          print('Error al obtener métricas de ventas: ${response.statusCode}');
        }
        return [];
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error en obtenerTodasMetricas: $error');
      }
      return [];
    }
  }

  Future<List<MetricasVentas>> obtenerMetricasPorUsuario(int usuarioId) async {
    try {
      final response = await ApiServices.dio.get(
        '${ApiEndpoints.metricasVentas}?usuario=$usuarioId',
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((item) => MetricasVentas.fromJson(item)).toList();
      } else {
        if (kDebugMode) {
          print(
            'Error al obtener métricas del usuario: ${response.statusCode}',
          );
        }
        return [];
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error en obtenerMetricasPorUsuario: $error');
      }
      return [];
    }
  }

  Future<List<MetricasVentas>> obtenerMetricasFiltradas({
    int? usuarioId,
    int? productoId,
    int? mes,
    int? anio,
  }) async {
    try {
      Map<String, dynamic> queryParams = {};

      if (usuarioId != null) {
        queryParams['usuario'] = usuarioId.toString();
      }

      if (productoId != null) {
        queryParams['producto'] = productoId.toString();
      }

      if (mes != null) {
        queryParams['mes'] = mes.toString();
      }

      if (anio != null) {
        queryParams['anio'] = anio.toString();
      }

      final response = await ApiServices.dio.get(
        ApiEndpoints.metricasVentas,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((item) => MetricasVentas.fromJson(item)).toList();
      } else {
        if (kDebugMode) {
          print('Error al obtener métricas filtradas: ${response.statusCode}');
        }
        return [];
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error en obtenerMetricasFiltradas: $e');
      }
      return [];
    }
  }

  Future<Map<String, dynamic>> obtenerResumenMetricas(int usuarioId) async {
    try {
      final now = DateTime.now();
      final int anioActual = now.year;
      final int mesActual = now.month;

      final List<MetricasVentas> metricasActuales =
          await obtenerMetricasFiltradas(
            usuarioId: usuarioId,
            mes: mesActual,
            anio: anioActual,
          );

      final int mesAnterior = mesActual == 1 ? 12 : mesActual - 1;
      final int anioAnterior = mesActual == 1 ? anioActual - 1 : anioActual;

      final List<MetricasVentas> metricasAnteriores =
          await obtenerMetricasFiltradas(
            usuarioId: usuarioId,
            mes: mesAnterior,
            anio: anioAnterior,
          );

      Map<int, List<MetricasVentas>> metricasPorProductoActual = {};
      Map<int, List<MetricasVentas>> metricasPorProductoAnterior = {};

      for (var metrica in metricasActuales) {
        if (!metricasPorProductoActual.containsKey(metrica.productoId)) {
          metricasPorProductoActual[metrica.productoId] = [];
        }
        metricasPorProductoActual[metrica.productoId]!.add(metrica);
      }

      for (var metrica in metricasAnteriores) {
        if (!metricasPorProductoAnterior.containsKey(metrica.productoId)) {
          metricasPorProductoAnterior[metrica.productoId] = [];
        }
        metricasPorProductoAnterior[metrica.productoId]!.add(metrica);
      }

      double totalIngresos = 0;
      double totalGastos = 0;
      double totalBeneficio = 0;
      int totalProductosVendidos = 0;

      for (var metrica in metricasActuales) {
        totalIngresos += metrica.ingresos;
        totalGastos += metrica.gastos;
        totalBeneficio += metrica.beneficio;
        totalProductosVendidos += metrica.totalVendido;
      }

      double totalIngresosAnterior = 0;
      double totalGastosAnterior = 0;
      double totalBeneficioAnterior = 0;
      int totalProductosVendidosAnterior = 0;

      for (var metrica in metricasAnteriores) {
        totalIngresosAnterior += metrica.ingresos;
        totalGastosAnterior += metrica.gastos;
        totalBeneficioAnterior += metrica.beneficio;
        totalProductosVendidosAnterior += metrica.totalVendido;
      }

      double variacionIngresos =
          totalIngresosAnterior > 0
              ? ((totalIngresos - totalIngresosAnterior) /
                      totalIngresosAnterior) *
                  100
              : 0;

      double variacionGastos =
          totalGastosAnterior > 0
              ? ((totalGastos - totalGastosAnterior) / totalGastosAnterior) *
                  100
              : 0;

      double variacionBeneficio =
          totalBeneficioAnterior > 0
              ? ((totalBeneficio - totalBeneficioAnterior) /
                      totalBeneficioAnterior) *
                  100
              : 0;

      double variacionVentas =
          totalProductosVendidosAnterior > 0
              ? ((totalProductosVendidos - totalProductosVendidosAnterior) /
                      totalProductosVendidosAnterior) *
                  100
              : 0;

      List<Map<String, dynamic>> resumenPorProducto = [];

      Set<int> todosProductosIds = {};
      metricasPorProductoActual.keys.forEach(todosProductosIds.add);
      metricasPorProductoAnterior.keys.forEach(todosProductosIds.add);

      for (var productoId in todosProductosIds) {
        final metricasProductoActual =
            metricasPorProductoActual[productoId] ?? [];

        final metricasProductoAnterior =
            metricasPorProductoAnterior[productoId] ?? [];

        double productIngresos = 0;
        double productGastos = 0;
        double productBeneficio = 0;
        int productVendidos = 0;

        for (var m in metricasProductoActual) {
          productIngresos += m.ingresos;
          productGastos += m.gastos;
          productBeneficio += m.beneficio;
          productVendidos += m.totalVendido;
        }

        double productIngresosAnterior = 0;
        double productGastosAnterior = 0;
        double productBeneficioAnterior = 0;
        int productVendidosAnterior = 0;

        for (var m in metricasProductoAnterior) {
          productIngresosAnterior += m.ingresos;
          productGastosAnterior += m.gastos;
          productBeneficioAnterior += m.beneficio;
          productVendidosAnterior += m.totalVendido;
        }

        double prodVariacionIngresos =
            productIngresosAnterior > 0
                ? ((productIngresos - productIngresosAnterior) /
                        productIngresosAnterior) *
                    100
                : 0;

        double prodVariacionGastos =
            productGastosAnterior > 0
                ? ((productGastos - productGastosAnterior) /
                        productGastosAnterior) *
                    100
                : 0;

        double prodVariacionBeneficio =
            productBeneficioAnterior > 0
                ? ((productBeneficio - productBeneficioAnterior) /
                        productBeneficioAnterior) *
                    100
                : 0;

        double prodVariacionVentas =
            productVendidosAnterior > 0
                ? ((productVendidos - productVendidosAnterior) /
                        productVendidosAnterior) *
                    100
                : 0;

        resumenPorProducto.add({
          'producto_id': productoId,
          'actual': {
            'ingresos': productIngresos,
            'gastos': productGastos,
            'beneficio': productBeneficio,
            'productos_vendidos': productVendidos,
          },
          'anterior': {
            'ingresos': productIngresosAnterior,
            'gastos': productGastosAnterior,
            'beneficio': productBeneficioAnterior,
            'productos_vendidos': productVendidosAnterior,
          },
          'variacion': {
            'ingresos': prodVariacionIngresos,
            'gastos': prodVariacionGastos,
            'beneficio': prodVariacionBeneficio,
            'productos_vendidos': prodVariacionVentas,
          },
        });
      }

      return {
        'resumen_general': {
          'actual': {
            'ingresos': totalIngresos,
            'gastos': totalGastos,
            'beneficio': totalBeneficio,
            'productos_vendidos': totalProductosVendidos,
          },
          'anterior': {
            'ingresos': totalIngresosAnterior,
            'gastos': totalGastosAnterior,
            'beneficio': totalBeneficioAnterior,
            'productos_vendidos': totalProductosVendidosAnterior,
          },
          'variacion': {
            'ingresos': variacionIngresos,
            'gastos': variacionGastos,
            'beneficio': variacionBeneficio,
            'productos_vendidos': variacionVentas,
          },
        },
        'resumen_por_producto': resumenPorProducto,
        'metricas_detalle': metricasActuales,
      };
    } catch (e) {
      if (kDebugMode) {
        print('Error en obtenerResumenMetricas: $e');
      }
      return {
        'resumen_general': {
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
        },
        'resumen_por_producto': [],
        'metricas_detalle': [],
      };
    }
  }
}
