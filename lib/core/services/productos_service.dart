import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:foodflow_app/core/constants/api_endpoints.dart';
import 'package:foodflow_app/core/services/api_services.dart';
import 'package:foodflow_app/core/services/usuario_sesion_service.dart';
import 'package:foodflow_app/models/producto_model.dart';
import 'package:foodflow_app/models/user_model.dart';

class ProductosService {
  static final ProductosService _instance = ProductosService._internal();
  factory ProductosService() => _instance;
  ProductosService._internal();

  Future<List<User>> obtenerCocinaCentrales() async {
    try {
      final response = await ApiServices.dio.get(
        '${ApiEndpoints.usuario}?tipo_usuario=cocina_central',
      );

      if (response.statusCode == 200) {
        final List<dynamic> usuariosData = response.data;
        return usuariosData
            .map((usuario) => User.fromJson(usuario))
            .where((usuario) => usuario.tipoUsuario == 'cocina_central')
            .toList();
      }
      return [];
    } catch (e) {
      if (kDebugMode) {
        print('Error al obtener cocinas centrales: $e');
      }
      return [];
    }
  }

  Future<List<Producto>> obtenerProductos({
    int? cocinaCentralId,
    bool incluirInactivos = false,
  }) async {
    try {
      String url = ApiEndpoints.productos;

      Map<String, dynamic> queryParams = {};

      if (cocinaCentralId != null) {
        queryParams['cocina_central'] = cocinaCentralId;
      }

      if (!incluirInactivos) {
        queryParams['is_active'] = 'true';
      }

      final response = await ApiServices.dio.get(
        url,
        queryParameters: queryParams,
      );

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

  Future<Producto?> obtenerProductoDetalle(int productoId) async {
    try {
      final response = await ApiServices.dio.get(
        '${ApiEndpoints.productos}$productoId/',
      );

      if (response.statusCode == 200) {
        return Producto.fromJson(response.data);
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error al obtener detalle del producto: $e');
      }
      return null;
    }
  }

  Future<bool> crearProducto(Map<String, dynamic> datos) async {
    try {
      final response = await ApiServices.dio.post(
        ApiEndpoints.productos,
        data: datos,
      );

      return response.statusCode == 201;
    } catch (e) {
      if (kDebugMode) {
        print('Error al crear producto: $e');
      }
      return false;
    }
  }

  Future<bool> actualizarProducto(
    int productoId,
    Map<String, dynamic> datos,
    File? imagen,
  ) async {
    try {
      if (imagen != null) {
        final formData = FormData.fromMap(datos);
        formData.files.add(
          MapEntry(
            'imagen',
            await MultipartFile.fromFile(
              imagen.path,
              filename: 'imagen_producto.jpg',
            ),
          ),
        );

        final response = await ApiServices.dio.patch(
          '${ApiEndpoints.productos}$productoId/',
          data: formData,
        );

        return response.statusCode == 200;
      } else {
        final response = await ApiServices.dio.patch(
          '${ApiEndpoints.productos}$productoId/',
          data: datos,
        );

        return response.statusCode == 200;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error al actualizar producto: $e');
      }
      return false;
    }
  }

  Future<bool> agregarAlCarrito(
    int productoId,
    int cantidad,
    int cocinaCentralId,
  ) async {
    try {
      final userSession = UserSessionService();
      final userId = userSession.user?.id;

      if (userId == null) {
        return false;
      }

      final response = await ApiServices.dio.get(
        '${ApiEndpoints.pedidos}?estado=carrito',
      );

      int? pedidoId;

      if (response.statusCode == 200) {
        final List<dynamic> carritos = response.data;
        for (var carrito in carritos) {
          if (carrito['cocina_central'] == cocinaCentralId) {
            pedidoId = carrito['id'];
            break;
          }
        }
      }

      if (pedidoId == null) {
        final nuevoPedidoResponse = await ApiServices.dio.post(
          ApiEndpoints.pedidos,
          data: {
            'cocina_central': cocinaCentralId,
            'estado': 'carrito',
            'tipo_pedido': 'normal',
            'urgente': false,
          },
        );

        if (nuevoPedidoResponse.statusCode != 201) {
          return false;
        }

        pedidoId = nuevoPedidoResponse.data['id'];
      }

      final productoResponse = await ApiServices.dio.post(
        ApiEndpoints.pedidoProductos,
        data: {
          'pedido': pedidoId,
          'producto': productoId,
          'cantidad': cantidad,
        },
      );

      return productoResponse.statusCode == 201;
    } catch (e) {
      if (kDebugMode) {
        print('Error al agregar producto al carrito: $e');
      }
      return false;
    }
  }

  Future<int> verificarCarritoExistente(int cocinaCentralId) async {
    try {
      final response = await ApiServices.dio.get(
        '${ApiEndpoints.pedidos}?estado=carrito&cocina_central=$cocinaCentralId',
      );

      if (response.statusCode == 200) {
        final List<dynamic> carritos = response.data;
        if (carritos.isNotEmpty) {
          return carritos[0]['id'];
        }
      }
      return 0;
    } catch (e) {
      if (kDebugMode) {
        print('Error al verificar carrito existente: $e');
      }
      return -1;
    }
  }
}
