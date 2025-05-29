import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
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
        final List<Producto> productos = [];

        for (var productoJson in productosData) {
          try {
            final producto = Producto.fromJson(productoJson);
            productos.add(producto);
          } catch (e) {
            if (kDebugMode) {
              print('Error al procesar producto individual: $e');
            }
          }
        }

        if (kDebugMode) {
          print('Productos procesados con éxito: ${productos.length}');
        }

        return productos;
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

  Future<bool> crearProducto(Map<String, dynamic> datos, File? imagen) async {
    try {
      dynamic requestData;
      Options? requestOptions;

      if (imagen != null) {
        // Si hay imagen, usar FormData
        final Map<String, dynamic> formDataMap = {};

        // Agregar la imagen
        formDataMap['imagen'] = await MultipartFile.fromFile(
          imagen.path,
          filename:
              'imagen_producto_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );

        // Agregar otros campos de datos
        datos.forEach((key, value) {
          if (value != null) {
            formDataMap[key] = value;
          }
        });

        requestData = FormData.fromMap(formDataMap);
        requestOptions = Options(
          headers: {'Content-Type': 'multipart/form-data'},
        );
      } else {
        // Si no hay imagen, usar JSON normal
        requestData = datos;
        requestOptions = Options(headers: {'Content-Type': 'application/json'});
      }

      final response = await ApiServices.dio.post(
        ApiEndpoints.productos,
        data: requestData,
        options: requestOptions,
      );

      bool resultado = response.statusCode == 201;

      // Si la creación fue exitosa y había imagen, limpiar cache
      if (resultado && imagen != null) {
        await _limpiarCacheImagenes();
      }

      return resultado;
    } catch (e) {
      if (kDebugMode) {
        print('Error al crear producto: $e');
        if (e is DioException) {
          print('Response data: ${e.response?.data}');
          print('Status code: ${e.response?.statusCode}');
        }
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
      bool resultado = false;

      if (imagen != null) {
        // Cuando hay imagen, solo enviar imagen y is_active (si está presente)
        final Map<String, dynamic> formDataFields = {
          'imagen': await MultipartFile.fromFile(
            imagen.path,
            filename:
                'imagen_producto_${DateTime.now().millisecondsSinceEpoch}.jpg',
          ),
        };

        // Corregir: usar 'is_active' en lugar de 'activo'
        if (datos.containsKey('is_active')) {
          formDataFields['is_active'] = datos['is_active'];
        }

        final formData = FormData.fromMap(formDataFields);

        final response = await ApiServices.dio.patch(
          '${ApiEndpoints.productos}$productoId/',
          data: formData,
          options: Options(headers: {'Content-Type': 'multipart/form-data'}),
        );

        resultado = response.statusCode == 200;
      } else {
        // Sin imagen, solo permitir cambios en is_active
        final datosPermitidos = <String, dynamic>{};

        // Corregir: usar 'is_active' en lugar de 'activo'
        if (datos.containsKey('is_active')) {
          datosPermitidos['is_active'] = datos['is_active'];
        }

        // Si no hay campos permitidos para actualizar, no hacer la petición
        if (datosPermitidos.isEmpty) {
          if (kDebugMode) {
            print('No hay campos permitidos para actualizar');
          }
          return true; // Retornar true porque técnicamente no hay error
        }

        final response = await ApiServices.dio.patch(
          '${ApiEndpoints.productos}$productoId/',
          data: datosPermitidos,
          options: Options(headers: {'Content-Type': 'application/json'}),
        );

        resultado = response.statusCode == 200;
      }

      // Si la actualización fue exitosa, limpiar cache y recargar producto
      if (resultado) {
        if (imagen != null) {
          await _limpiarCacheImagenes();
        }
        await _actualizarProductoLocal(productoId);
      }

      return resultado;
    } catch (e) {
      if (kDebugMode) {
        print('Error al actualizar producto: $e');
        if (e is DioException) {
          print('Response data: ${e.response?.data}');
          print('Status code: ${e.response?.statusCode}');
        }
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
        '${ApiEndpoints.carritos}?cocina_central=$cocinaCentralId',
      );

      int? carritoId;
      if (response.statusCode == 200) {
        final List<dynamic> carritos = response.data;
        if (carritos.isNotEmpty) {
          carritoId = carritos.first['id'];
        }
      }

      if (carritoId == null) {
        final nuevoCarritoResponse = await ApiServices.dio.post(
          ApiEndpoints.carritos,
          data: {'cocina_central': cocinaCentralId},
        );
        if (nuevoCarritoResponse.statusCode != 201) {
          return false;
        }
        carritoId = nuevoCarritoResponse.data['id'];
      }

      if (cantidad <= 0) {
        final productosCarritoResponse = await ApiServices.dio.get(
          '${ApiEndpoints.pedidoProductos}?pedido=$carritoId',
        );

        if (productosCarritoResponse.statusCode == 200) {
          final List<dynamic> productosCarrito = productosCarritoResponse.data;
          final existente = productosCarrito.firstWhere(
            (item) =>
                item['producto'] == productoId && item['pedido'] == carritoId,
            orElse: () => null,
          );

          if (existente != null) {
            final quitarResponse = await ApiServices.dio.delete(
              '${ApiEndpoints.pedidoProductos}${existente['id']}/',
            );
            return quitarResponse.statusCode == 204;
          }
          return true;
        }
        return false;
      } else {
        final productosCarritoResponse = await ApiServices.dio.get(
          '${ApiEndpoints.pedidoProductos}?pedido=$carritoId',
        );

        if (productosCarritoResponse.statusCode == 200) {
          final List<dynamic> productosCarrito = productosCarritoResponse.data;
          final existente = productosCarrito.firstWhere(
            (item) =>
                item['producto'] == productoId && item['pedido'] == carritoId,
            orElse: () => null,
          );

          if (existente != null) {
            final patchResponse = await ApiServices.dio.patch(
              '${ApiEndpoints.pedidoProductos}${existente['id']}/',
              data: {'cantidad': cantidad},
            );
            return patchResponse.statusCode == 200;
          }
        }

        final productoResponse = await ApiServices.dio.post(
          ApiEndpoints.pedidoProductos,
          data: {
            'pedido': carritoId,
            'producto': productoId,
            'cantidad': cantidad,
          },
        );
        return productoResponse.statusCode == 201;
      }
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

  Future<List<Producto>> obtenerProductosPorIds(List<int> ids) async {
    if (ids.isEmpty) return [];
    try {
      final response = await ApiServices.dio.get(
        '${ApiEndpoints.productos}?ids=${ids.join(',')}',
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        List<Producto> productos = [];

        for (var item in data) {
          try {
            productos.add(Producto.fromJson(item));
          } catch (e) {
            if (kDebugMode) {
              print('Error al procesar producto por ID: $e');
            }
          }
        }

        return productos;
      }
      return [];
    } catch (e) {
      if (kDebugMode) {
        print('Error al obtener productos por ids: $e');
      }
      return [];
    }
  }

  Future<void> _limpiarCacheImagenes() async {
    try {
      // Limpiar cache de imágenes usando cached_network_image
      await DefaultCacheManager().emptyCache();
    } catch (e) {
      if (kDebugMode) {
        print('Error al limpiar cache de imágenes: $e');
      }
    }
  }

  Future<void> _actualizarProductoLocal(int productoId) async {
    try {
      final productoActualizado = await obtenerProductoDetalle(productoId);
      if (productoActualizado != null) {
        // El producto actualizado se obtiene del servidor
        // Los ViewModels que usen este servicio deberán refrescar sus datos
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error al actualizar producto local: $e');
      }
    }
  }
}
