import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:foodflow_app/core/constants/api_endpoints.dart';
import 'package:foodflow_app/core/services/api_services.dart';
import 'package:foodflow_app/models/pedido_model.dart';
import 'package:foodflow_app/models/pedido_producto_model.dart';

class PedidosService {
  static final PedidosService _instance = PedidosService._internal();
  factory PedidosService() => _instance;
  PedidosService._internal();

  Future<List<Pedido>> obtenerPedidos({Map<String, dynamic>? filtros}) async {
    try {
      String url = ApiEndpoints.pedidos;

      if (filtros != null && filtros.isNotEmpty) {
        url += '?';
        filtros.forEach((key, value) {
          url += '$key=$value&';
        });
        url = url.substring(0, url.length - 1);
      }

      final response = await ApiServices.dio.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> pedidosData = response.data;

        return pedidosData.map((pedido) => Pedido.fromJson(pedido)).toList();
      }

      return [];
    } catch (e) {
      if (kDebugMode) {
        print('Error al obtener pedidos: $e');
      }
      return [];
    }
  }

  Future<Pedido?> obtenerPedidoDetalle(int pedidoId) async {
    try {
      final response = await ApiServices.dio.get(
        '${ApiEndpoints.pedidos}$pedidoId/',
      );

      if (response.statusCode == 200) {
        final pedidoData = response.data;

        final productosResponse = await ApiServices.dio.get(
          '${ApiEndpoints.pedidoProductos}?pedido_id=$pedidoId',
        );

        if (productosResponse.statusCode == 200) {
          final List<dynamic> productosData = productosResponse.data;
          final productos =
              productosData
                  .map((producto) => PedidoProducto.fromJson(producto))
                  .toList();

          pedidoData['productos'] = productosData;

          return Pedido.fromJson(pedidoData);
        }

        return Pedido.fromJson(pedidoData);
      }

      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error al obtener detalle del pedido: $e');
      }
      return null;
    }
  }

  Future<Map<String, dynamic>> obtenerResumenPedidosDashboard() async {
    try {
      final pedidos = await obtenerPedidos(
        filtros: {'estado__in': 'pendiente,en_proceso,enviado'},
      );

      if (pedidos.isEmpty) {
        return {
          'lista': [],
          'total': 0,
          'pendientes': 0,
          'en_proceso': 0,
          'completados': 0,
        };
      }

      int pendientes = 0;
      int enProceso = 0;
      int completados = 0;

      for (final pedido in pedidos) {
        switch (pedido.estado) {
          case 'pendiente':
            pendientes++;
            break;
          case 'en_proceso':
          case 'enviado':
            enProceso++;
            break;
          case 'completado':
            completados++;
            break;
        }
      }

      final lista =
          pedidos.map((pedido) => pedido.toResumenDashboard()).toList();

      return {
        'lista': lista,
        'total': pedidos.length,
        'pendientes': pendientes,
        'en_proceso': enProceso,
        'completados': completados,
      };
    } catch (e) {
      if (kDebugMode) {
        print('Error al obtener resumen de pedidos: $e');
      }
      return {
        'lista': [],
        'total': 0,
        'pendientes': 0,
        'en_proceso': 0,
        'completados': 0,
      };
    }
  }

  Future<List<PedidoProducto>> obtenerProductosPedido(int pedidoId) async {
    try {
      final response = await ApiServices.dio.get(
        '${ApiEndpoints.pedidoProductos}?pedido_id=$pedidoId',
      );

      if (response.statusCode == 200) {
        final List<dynamic> productosData = response.data;
        return productosData
            .map((producto) => PedidoProducto.fromJson(producto))
            .toList();
      }

      return [];
    } catch (e) {
      if (kDebugMode) {
        print('Error al obtener productos del pedido: $e');
      }
      return [];
    }
  }
}
