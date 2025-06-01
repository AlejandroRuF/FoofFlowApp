import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:foodflow_app/core/constants/api_endpoints.dart';
import 'package:foodflow_app/core/services/api_services.dart';
import 'package:foodflow_app/models/user_model.dart';

import '../../models/cocina_central_restaurante_model.dart';

class CocinaCentralRestauranteService {
  static final CocinaCentralRestauranteService _instance =
      CocinaCentralRestauranteService._internal();
  factory CocinaCentralRestauranteService() => _instance;
  CocinaCentralRestauranteService._internal();

  static final String _endpoint =
      '${ApiEndpoints.getFullUrl(ApiEndpoints.cocinaCentralRestaurante)}';

  Future<List<CocinaCentralRestaurante>> obtenerTodasLasRelaciones() async {
    try {
      final response = await ApiServices.dio.get(_endpoint);

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data
            .map((json) => CocinaCentralRestaurante.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Error al obtener relaciones cocina-restaurante: $e');
    }
  }

  Future<List<CocinaCentralRestaurante>> obtenerRelacionesPorRestaurante(
    int restauranteId,
  ) async {
    try {
      final todasLasRelaciones = await obtenerTodasLasRelaciones();

      return todasLasRelaciones
          .where((relacion) => relacion.restauranteId == restauranteId)
          .toList();
    } catch (e) {
      throw Exception('Error al obtener relaciones del restaurante: $e');
    }
  }

  Future<List<CocinaCentralRestaurante>> obtenerRelacionesPorCocina(
    int cocinaCentralId,
  ) async {
    try {
      final todasLasRelaciones = await obtenerTodasLasRelaciones();

      return todasLasRelaciones
          .where((relacion) => relacion.cocinaCentralId == cocinaCentralId)
          .toList();
    } catch (e) {
      throw Exception('Error al obtener relaciones de la cocina: $e');
    }
  }

  Future<List<User>> obtenerCocinasDeRestaurante(int restauranteId) async {
    try {
      final relaciones = await obtenerRelacionesPorRestaurante(restauranteId);

      if (relaciones.isEmpty) {
        return [];
      }

      if (kDebugMode) {
        print('***Relaciones encontradas para restaurante $restauranteId***');
        for (var relacion in relaciones) {
          print('Relación: ${relacion.toString()}');
        }
      }

      final List<int> cocinasIds =
          relaciones.map((relacion) => relacion.cocinaCentralId).toList();

      if (cocinasIds.isNotEmpty) {
        final cocinasResponse = await ApiServices.dio.get(ApiEndpoints.usuario);

        if (cocinasResponse.statusCode == 200) {
          final List<dynamic> cocinasData = cocinasResponse.data;

          final cocinasFiltered =
              cocinasData
                  .where((userData) => cocinasIds.contains(userData['id']))
                  .map((json) => User.fromJson(json))
                  .toList();

          if (kDebugMode) {
            print('Cocinas filtradas: ${cocinasFiltered.length}');
            for (var cocina in cocinasFiltered) {
              print('Cocina encontrada: ${cocina.id} - ${cocina.nombre}');
            }
          }

          return cocinasFiltered;
        }
      }

      return [];
    } catch (e) {
      if (kDebugMode) {
        print('Error al obtener cocinas del restaurante: $e');
      }
      throw Exception('Error al obtener cocinas del restaurante: $e');
    }
  }

  Future<List<User>> obtenerRestaurantesDeCocina(int cocinaCentralId) async {
    try {
      final relaciones = await obtenerRelacionesPorCocina(cocinaCentralId);

      if (relaciones.isEmpty) {
        return [];
      }

      if (kDebugMode) {
        print('***Relaciones encontradas para cocina $cocinaCentralId***');
        for (var relacion in relaciones) {
          print('Relación: ${relacion.toString()}');
        }
      }

      final List<int> restaurantesIds =
          relaciones.map((relacion) => relacion.restauranteId).toList();

      if (restaurantesIds.isNotEmpty) {
        final restaurantesResponse = await ApiServices.dio.get(
          '${ApiEndpoints.usuario}?ids=${restaurantesIds.join(',')}',
        );

        if (restaurantesResponse.statusCode == 200) {
          final List<dynamic> restaurantesData = restaurantesResponse.data;
          return restaurantesData.map((json) => User.fromJson(json)).toList();
        }
      }

      return [];
    } catch (e) {
      throw Exception('Error al obtener restaurantes de la cocina: $e');
    }
  }

  Future<bool> crearRelacion(CocinaCentralRestauranteRequest relacion) async {
    try {
      final response = await ApiServices.dio.post(
        _endpoint,
        data: relacion.toJson(),
      );

      return response.statusCode == 201;
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 400) {
        throw Exception('La relación ya existe o los datos son inválidos');
      }
      throw Exception('Error al crear la relación: $e');
    }
  }

  Future<bool> eliminarRelacion(int relacionId) async {
    try {
      final response = await ApiServices.dio.delete('$_endpoint/$relacionId');
      return response.statusCode == 204;
    } catch (e) {
      throw Exception('Error al eliminar la relación: $e');
    }
  }

  Future<bool> eliminarRelacionPorIds(
    int cocinaCentralId,
    int restauranteId,
  ) async {
    try {
      final relaciones = await obtenerTodasLasRelaciones();
      final relacion = relaciones.firstWhere(
        (rel) =>
            rel.cocinaCentralId == cocinaCentralId &&
            rel.restauranteId == restauranteId,
        orElse: () => throw Exception('Relación no encontrada'),
      );

      return await eliminarRelacion(relacion.id);
    } catch (e) {
      throw Exception('Error al eliminar la relación: $e');
    }
  }

  Future<bool> existeRelacion(int cocinaCentralId, int restauranteId) async {
    try {
      final relaciones = await obtenerTodasLasRelaciones();
      return relaciones.any(
        (rel) =>
            rel.cocinaCentralId == cocinaCentralId &&
            rel.restauranteId == restauranteId,
      );
    } catch (e) {
      return false;
    }
  }

  Future<List<User>> obtenerCocinasDisponiblesParaRestaurante(
    int restauranteId,
  ) async {
    try {
      final todasLasCocinasResponse = await ApiServices.dio.get(
        '${ApiEndpoints.usuario}?tipo_usuario=cocina_central',
      );

      if (todasLasCocinasResponse.statusCode != 200) {
        return [];
      }

      final List<dynamic> todasLasCocinas = todasLasCocinasResponse.data;
      final cocinasAsignadas = await obtenerCocinasDeRestaurante(restauranteId);
      final idsCocinasAsignadas = cocinasAsignadas.map((c) => c.id).toSet();

      final cocinasDisponibles =
          todasLasCocinas
              .map((json) => User.fromJson(json))
              .where((cocina) => !idsCocinasAsignadas.contains(cocina.id))
              .toList();

      return cocinasDisponibles;
    } catch (e) {
      throw Exception('Error al obtener cocinas disponibles: $e');
    }
  }

  Future<List<User>> obtenerRestaurantesDisponiblesParaCocina(
    int cocinaCentralId,
  ) async {
    try {
      final todosLosRestaurantesResponse = await ApiServices.dio.get(
        '${ApiEndpoints.usuario}?tipo_usuario=restaurante',
      );

      if (todosLosRestaurantesResponse.statusCode != 200) {
        return [];
      }
      final List<dynamic> todosLosRestaurantes =
          todosLosRestaurantesResponse.data;
      final restaurantesAsignados = await obtenerRestaurantesDeCocina(
        cocinaCentralId,
      );
      final idsRestaurantesAsignados =
          restaurantesAsignados.map((r) => r.id).toSet();
      final restaurantesDisponibles =
          todosLosRestaurantes
              .map((json) => User.fromJson(json))
              .where(
                (restaurante) =>
                    !idsRestaurantesAsignados.contains(restaurante.id),
              )
              .toList();

      return restaurantesDisponibles;
    } catch (e) {
      throw Exception('Error al obtener restaurantes disponibles: $e');
    }
  }
}
