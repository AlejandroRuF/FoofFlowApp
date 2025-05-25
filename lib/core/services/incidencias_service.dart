import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:foodflow_app/core/constants/api_endpoints.dart';
import 'package:foodflow_app/core/services/api_services.dart';
import 'package:foodflow_app/models/incidencia_model.dart';

class IncidenciasService {
  static final IncidenciasService _instance = IncidenciasService._internal();
  factory IncidenciasService() => _instance;
  IncidenciasService._internal();

  Future<List<Incidencia>> obtenerIncidencias({
    Map<String, dynamic>? filtros,
  }) async {
    try {
      String url = ApiEndpoints.incidencias;

      if (filtros != null && filtros.isNotEmpty) {
        url += '?';
        filtros.forEach((key, value) {
          url += '$key=$value&';
        });
        url = url.substring(0, url.length - 1);
      }

      final response = await ApiServices.dio.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> incidenciasData = response.data;

        // Ya no hace falta enriquecer, toda la info viene en la respuesta
        final incidencias =
            incidenciasData
                .map((incidenciaData) => Incidencia.fromJson(incidenciaData))
                .toList();

        return List<Incidencia>.from(incidencias);
      }

      return [];
    } catch (e) {
      if (kDebugMode) {
        print('Error al obtener incidencias: $e');
      }
      return [];
    }
  }

  Future<Incidencia?> obtenerIncidenciaDetalle(int incidenciaId) async {
    try {
      final response = await ApiServices.dio.get(
        '${ApiEndpoints.incidencias}$incidenciaId/',
      );

      if (response.statusCode == 200) {
        final incidenciaData = response.data;

        // Toda la info viene ya en el detalle
        return Incidencia.fromJson(incidenciaData);
      }

      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error al obtener detalle de la incidencia: $e');
      }
      return null;
    }
  }

  Future<bool> crearIncidencia({
    required int pedidoId,
    required int productoId,
    required int nuevaCantidad,
    required String descripcion,
  }) async {
    try {
      final data = {
        'pedido': pedidoId,
        'producto': productoId,
        'nueva_cantidad': nuevaCantidad,
        'descripcion': descripcion,
      };

      final response = await ApiServices.dio.post(
        ApiEndpoints.incidencias,
        data: data,
      );

      return response.statusCode == 201;
    } catch (e) {
      if (kDebugMode) {
        print('Error al crear incidencia: $e');
      }
      return false;
    }
  }

  Future<Map<String, dynamic>> obtenerResumenIncidenciasDashboard() async {
    try {
      final incidencias = await obtenerIncidencias();

      if (incidencias.isEmpty) {
        return {
          'lista': [],
          'pendientes': 0,
          'en_proceso': 0,
          'resueltas': 0,
          'alta_prioridad': 0,
          'total': 0,
        };
      }

      int pendientes = 0;
      int enProceso = 0;
      int resueltas = 0;
      int altaPrioridad = 0;

      final List<Map<String, dynamic>> listaEnriquecida = [];

      for (final incidencia in incidencias) {
        switch (incidencia.estado) {
          case 'pendiente':
            pendientes++;
            altaPrioridad++;
            break;
          case 'en_proceso':
            enProceso++;
            break;
          case 'resuelta':
            resueltas++;
            break;
        }

        listaEnriquecida.add(incidencia.toResumenDashboard());
      }

      return {
        'lista': listaEnriquecida,
        'pendientes': pendientes,
        'en_proceso': enProceso,
        'resueltas': resueltas,
        'alta_prioridad': altaPrioridad,
        'total': incidencias.length,
      };
    } catch (e) {
      if (kDebugMode) {
        print('Error al obtener resumen de incidencias: $e');
      }
      return {
        'lista': [],
        'pendientes': 0,
        'en_proceso': 0,
        'resueltas': 0,
        'alta_prioridad': 0,
        'total': 0,
      };
    }
  }

  Future<bool> marcarComoResuelta(int incidenciaId) async {
    try {
      final response = await ApiServices.dio.patch(
        '${ApiEndpoints.incidencias}$incidenciaId/',
        data: {'estado': 'resuelta'},
      );
      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        print('Error al marcar incidencia como resuelta: $e');
      }
      return false;
    }
  }

  Future<bool> cancelarIncidencia(int incidenciaId) async {
    try {
      final response = await ApiServices.dio.patch(
        '${ApiEndpoints.incidencias}$incidenciaId/',
        data: {'estado': 'cancelada'},
      );
      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        print('Error al cancelar incidencia: $e');
      }
      return false;
    }
  }
}
