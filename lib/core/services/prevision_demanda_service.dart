import 'package:flutter/foundation.dart';
import 'package:foodflow_app/core/constants/api_endpoints.dart';
import 'package:foodflow_app/core/services/api_services.dart';
import 'package:foodflow_app/models/prevision_demanda_model.dart';

class PrevisionDemandaService {
  Future<List<PrevisionDemanda>> obtenerTodasPrevisiones() async {
    try {
      final response = await ApiServices.dio.get(ApiEndpoints.previsionDemanda);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((item) => PrevisionDemanda.fromJson(item)).toList();
      } else {
        if (kDebugMode) {
          print('Error al obtener previsiones de demanda: ${response.statusCode}');
        }
        return [];
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error en obtenerTodasPrevisiones: $e');
      }
      return [];
    }
  }
  
  Future<List<PrevisionDemanda>> obtenerPrevisionesPorRestaurante(int restauranteId) async {
    try {
      final response = await ApiServices.dio.get(
        '${ApiEndpoints.previsionDemanda}?restaurante=$restauranteId',
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((item) => PrevisionDemanda.fromJson(item)).toList();
      } else {
        if (kDebugMode) {
          print('Error al obtener previsiones del restaurante: ${response.statusCode}');
        }
        return [];
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error en obtenerPrevisionesPorRestaurante: $e');
      }
      return [];
    }
  }
  
  Future<List<PrevisionDemanda>> obtenerPrevisionesFiltradas({
    int? restauranteId,
    int? mes,
    int? anyo,
    int? tramoMes,
  }) async {
    try {
      Map<String, dynamic> queryParams = {};
      
      if (restauranteId != null) {
        queryParams['restaurante'] = restauranteId.toString();
      }
      
      if (mes != null) {
        queryParams['mes'] = mes.toString();
      }
      
      if (anyo != null) {
        queryParams['anyo'] = anyo.toString();
      }
      
      if (tramoMes != null) {
        queryParams['tramo_mes'] = tramoMes.toString();
      }
      
      final response = await ApiServices.dio.get(
        ApiEndpoints.previsionDemanda,
        queryParameters: queryParams,
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((item) => PrevisionDemanda.fromJson(item)).toList();
      } else {
        if (kDebugMode) {
          print('Error al obtener previsiones filtradas: ${response.statusCode}');
        }
        return [];
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error en obtenerPrevisionesFiltradas: $e');
      }
      return [];
    }
  }
  
  Future<Map<String, dynamic>> obtenerResumenPrevisiones(int restauranteId) async {
    try {
      final now = DateTime.now();
      final int anyoActual = now.year;
      final int mesActual = now.month;
      
      final List<PrevisionDemanda> previsionesActuales = await obtenerPrevisionesFiltradas(
        restauranteId: restauranteId,
        mes: mesActual,
        anyo: anyoActual,
      );
      
      final int diaActual = now.day;
      int tramoActual;
      
      if (diaActual <= 10) {
        tramoActual = 1;
      } else if (diaActual <= 20) {
        tramoActual = 2;
      } else {
        tramoActual = 3;
      }
      
      final previsionesTramoActual = previsionesActuales.where((p) => p.tramoMes == tramoActual).toList();
      
      int totalDemandaPrevista = 0;
      double promedioVariacion = 0.0;
      int contadorEstimadas = 0;
      
      for (var prevision in previsionesActuales) {
        totalDemandaPrevista += prevision.demandaPrevista;
        promedioVariacion += prevision.variacionPorcentual;
        if (prevision.esEstimada) contadorEstimadas++;
      }
      
      if (previsionesActuales.isNotEmpty) {
        promedioVariacion /= previsionesActuales.length;
      }
      
      double porcentajeEstimadas = previsionesActuales.isNotEmpty
          ? (contadorEstimadas / previsionesActuales.length) * 100
          : 0;
      
      return {
        'total_demanda_prevista': totalDemandaPrevista,
        'promedio_variacion': promedioVariacion,
        'porcentaje_estimadas': porcentajeEstimadas,
        'tramo_actual': tramoActual,
        'previsiones_tramo_actual': previsionesTramoActual,
        'todas_previsiones': previsionesActuales,
      };
    } catch (e) {
      if (kDebugMode) {
        print('Error en obtenerResumenPrevisiones: $e');
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