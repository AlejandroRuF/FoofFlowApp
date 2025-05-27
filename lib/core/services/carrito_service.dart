import 'package:flutter/foundation.dart';
import 'package:foodflow_app/core/constants/api_endpoints.dart';
import 'package:foodflow_app/core/services/api_services.dart';
import 'package:foodflow_app/models/carrito_model.dart';

class CarritoService {
  static final CarritoService _instance = CarritoService._internal();
  factory CarritoService() => _instance;
  CarritoService._internal();

  Future<List<Carrito>> obtenerCarritos({Map<String, dynamic>? filtros}) async {
    try {
      String url = ApiEndpoints.carritos;

      if (filtros != null && filtros.isNotEmpty) {
        url += '?';
        filtros.forEach((key, value) {
          url += '$key=$value&';
        });
        url = url.substring(0, url.length - 1);
      }

      final response = await ApiServices.dio.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> carritosData = response.data;
        return carritosData
            .map((carrito) => Carrito.fromJson(carrito))
            .toList();
      }
      return [];
    } catch (e) {
      if (kDebugMode) {
        print('Error al obtener carritos: $e');
      }
      return [];
    }
  }

  Future<Carrito?> obtenerCarritoDetalle(int carritoId) async {
    try {
      final response = await ApiServices.dio.get(
        ApiEndpoints.carritoPorId(carritoId),
      );
      if (response.statusCode == 200) {
        return Carrito.fromJson(response.data);
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error al obtener detalle del carrito: $e');
      }
      return null;
    }
  }

  Future<Carrito?> crearCarrito(Map<String, dynamic> data) async {
    try {
      final response = await ApiServices.dio.post(
        ApiEndpoints.carritos,
        data: data,
      );
      if (response.statusCode == 201) {
        return Carrito.fromJson(response.data);
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error al crear carrito: $e');
      }
      return null;
    }
  }

  Future<Carrito?> actualizarCarrito(
    int carritoId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await ApiServices.dio.patch(
        ApiEndpoints.carritoPorId(carritoId),
        data: data,
      );
      if (response.statusCode == 200) {
        return Carrito.fromJson(response.data);
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error al actualizar carrito: $e');
      }
      return null;
    }
  }

  Future<bool> eliminarCarrito(int carritoId) async {
    try {
      final response = await ApiServices.dio.delete(
        ApiEndpoints.carritoPorId(carritoId),
      );
      return response.statusCode == 204;
    } catch (e) {
      if (kDebugMode) {
        print('Error al eliminar carrito: $e');
      }
      return false;
    }
  }
}
