import 'package:flutter/foundation.dart';
import 'package:foodflow_app/core/services/carrito_service.dart';
import 'package:foodflow_app/models/carrito_model.dart';

class CartInteractor {
  final CarritoService _carritoService = CarritoService();

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
}
