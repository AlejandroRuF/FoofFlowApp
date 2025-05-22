import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:foodflow_app/core/constants/api_endpoints.dart';
import 'package:foodflow_app/core/services/api_services.dart';
import 'package:foodflow_app/models/inventario_model.dart';
import 'package:foodflow_app/models/producto_model.dart';

class InventarioService {
  static final InventarioService _instance = InventarioService._internal();

  factory InventarioService() => _instance;

  InventarioService._internal();

  Future<List<Inventario>> obtenerInventario() async {
    try {
      final response = await ApiServices.dio.get(ApiEndpoints.almacenes);

      if (response.statusCode == 200) {
        final List<dynamic> almacenData = response.data;

        return almacenData.map((item) => Inventario.fromJson(item)).toList();
      }

      return [];
    } catch (e) {
      if (kDebugMode) {
        print('Error al obtener inventario: $e');
      }
      return [];
    }
  }

  Future<List<Producto>> obtenerProductos({
    Map<String, dynamic>? filtros,
  }) async {
    try {
      String url = ApiEndpoints.productos;

      if (filtros != null && filtros.isNotEmpty) {
        url += '?';
        filtros.forEach((key, value) {
          url += '$key=$value&';
        });
        url = url.substring(0, url.length - 1);
      }

      final response = await ApiServices.dio.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> productosData = response.data;

        return productosData
            .map((producto) => Producto.fromJson(producto))
            .toList();
      }

      return [];
    } catch (e) {
      if (kDebugMode) {
        print('Error al obtener productos: $e');
      }
      return [];
    }
  }

  Future<Map<String, dynamic>> obtenerResumenInventarioDashboard() async {
    try {
      final almacenes = await obtenerInventario();

      if (almacenes.isEmpty) {
        return {
          'items': [],
          'total_productos': 0,
          'stock_bajo_count': 0,
          'valor_total': 0,
        };
      }

      int stockBajoCount = 0;
      double valorTotal = 0;

      final items =
          almacenes.map((almacen) {
            final esStockBajo = almacen.stockActual < 10;

            if (esStockBajo) {
              stockBajoCount++;
            }

            valorTotal += almacen.stockActual * 0;

            return almacen.toResumenDashboard();
          }).toList();

      return {
        'items': items,
        'total_productos': almacenes.length,
        'stock_bajo_count': stockBajoCount,
        'valor_total': valorTotal.round(),
      };
    } catch (e) {
      if (kDebugMode) {
        print('Error al obtener resumen de inventario: $e');
      }
      return {
        'items': [],
        'total_productos': 0,
        'stock_bajo_count': 0,
        'valor_total': 0,
      };
    }
  }

  Future<bool> actualizarStock(int inventarioId, int nuevoStock) async {
    try {
      final response = await ApiServices.dio.patch(
        '${ApiEndpoints.almacenes}$inventarioId/',
        data: {'stock_actual': nuevoStock},
      );

      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        print('Error al actualizar stock: $e');
      }
      return false;
    }
  }

  Future<bool> agregarProductoAlInventario(int productoId, int cantidad) async {
    try {
      final response = await ApiServices.dio.post(
        ApiEndpoints.almacenes,
        data: {'producto_id': productoId, 'stock_actual': cantidad},
      );

      return response.statusCode == 201;
    } catch (e) {
      if (kDebugMode) {
        print('Error al agregar producto al inventario: $e');
      }
      return false;
    }
  }

  Future<bool> actualizarStockPorQR(int productoId, int cantidad) async {
    try {
      final response = await ApiServices.dio.get(
        '${ApiEndpoints.almacenes}?producto_id=$productoId',
      );

      if (response.statusCode == 200) {
        final List<dynamic> inventarioData = response.data;
        if (inventarioData.isEmpty) {
          if (cantidad > 0) {
            return agregarProductoAlInventario(productoId, cantidad);
          }
          return false;
        }

        final inventarioItem = Inventario.fromJson(inventarioData[0]);
        final nuevoStock = inventarioItem.stockActual + cantidad;

        if (nuevoStock < 0) {
          return false;
        }

        return actualizarStock(inventarioItem.id, nuevoStock);
      }

      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Error al actualizar stock por QR: $e');
      }
      return false;
    }
  }
}
