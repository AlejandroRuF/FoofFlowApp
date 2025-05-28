import 'package:flutter/foundation.dart';
import 'package:foodflow_app/core/services/carrito_service.dart';
import 'package:foodflow_app/core/services/productos_service.dart';
import 'package:foodflow_app/models/carrito_model.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/services/api_services.dart';

class CartInteractor {
  final CarritoService _carritoService = CarritoService();
  final ProductosService _productosService = ProductosService();

  Future<List<Carrito>> obtenerCarritos({Map<String, dynamic>? filtros}) async {
    try {
      return await _carritoService.obtenerCarritos(filtros: filtros);
    } catch (e) {
      if (kDebugMode) {
        print('Error en obtenerCarritos: $e');
      }
      rethrow;
    }
  }

  Future<Carrito?> obtenerCarritoDetalle(int carritoId) async {
    try {
      return await _carritoService.obtenerCarritoDetalle(carritoId);
    } catch (e) {
      if (kDebugMode) {
        print('Error en obtenerCarritoDetalle: $e');
      }
      rethrow;
    }
  }

  Future<Carrito?> crearCarrito(Map<String, dynamic> data) async {
    try {
      return await _carritoService.crearCarrito(data);
    } catch (e) {
      if (kDebugMode) {
        print('Error en crearCarrito: $e');
      }
      rethrow;
    }
  }

  Future<Carrito?> actualizarCarrito(
    int carritoId,
    Map<String, dynamic> data,
  ) async {
    try {
      return await _carritoService.actualizarCarrito(carritoId, data);
    } catch (e) {
      if (kDebugMode) {
        print('Error en actualizarCarrito: $e');
      }
      rethrow;
    }
  }

  Future<bool> eliminarCarrito(int carritoId) async {
    try {
      return await _carritoService.eliminarCarrito(carritoId);
    } catch (e) {
      if (kDebugMode) {
        print('Error en eliminarCarrito: $e');
      }
      return false;
    }
  }

  Future<bool> agregarProductoAlCarrito(
    int productoId,
    int cantidad,
    int cocinaCentralId,
  ) async {
    try {
      return await _productosService.agregarAlCarrito(
        productoId,
        cantidad,
        cocinaCentralId,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error al agregar producto al carrito: $e');
      }
      return false;
    }
  }

  Future<bool> confirmarCarrito(int carritoId) async {
    try {
      final response = await ApiServices.dio.post(
        '${ApiEndpoints.carritos}$carritoId/confirmar/',
      );
      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        print('Error al confirmar carrito: $e');
      }
      return false;
    }
  }
}
