import 'dart:io';

import 'package:foodflow_app/core/services/categoria_service.dart';
import 'package:foodflow_app/core/services/productos_service.dart';
import 'package:foodflow_app/core/services/usuario_sesion_service.dart';
import 'package:foodflow_app/core/services/carrito_service.dart';
import 'package:foodflow_app/features/products/products_model/products_model.dart';
import 'package:foodflow_app/models/categoria_model.dart';
import 'package:foodflow_app/models/producto_model.dart';
import 'package:foodflow_app/models/user_model.dart';
import 'package:foodflow_app/models/carrito_model.dart';

class ProductsInteractor {
  final ProductosService _productosService = ProductosService();
  final CategoriaService _categoriaService = CategoriaService();
  final UserSessionService _userSessionService = UserSessionService();
  final CarritoService _carritoService = CarritoService();

  Future<ProductsModel> obtenerCocinaCentrales() async {
    try {
      final cocinas = await _productosService.obtenerCocinaCentrales();
      return ProductsModel(cocinas: cocinas);
    } catch (e) {
      return ProductsModel(error: 'Error al obtener cocinas centrales: $e');
    }
  }

  Future<List<Categoria>> obtenerCategorias() async {
    try {
      return await _categoriaService.obtenerCategorias();
    } catch (e) {
      print('Error al obtener categorías: $e');
      return [];
    }
  }

  Future<ProductsModel> obtenerProductos({int? cocinaCentralId}) async {
    try {
      final usuario = _userSessionService.user;

      if (usuario == null) {
        return ProductsModel(error: 'No hay usuario autenticado');
      }

      List<Producto> productos = [];

      if (usuario.tipoUsuario == 'cocina_central') {
        productos = await _productosService.obtenerProductos(
          cocinaCentralId: usuario.id,
        );
      } else if (usuario.tipoUsuario == 'empleado' &&
          usuario.propietarioId != null) {
        final empleador = await _userSessionService.obtenerPropietario();
        if (empleador?.tipoUsuario == 'cocina_central') {
          productos = await _productosService.obtenerProductos(
            cocinaCentralId: empleador!.id,
          );
        }
        if (empleador?.tipoUsuario == 'restaurante') {
          productos = await _productosService.obtenerProductos(
            cocinaCentralId: cocinaCentralId,
          );
        }
      } else if (usuario.tipoUsuario == 'restaurante' &&
          cocinaCentralId != null) {
        productos = await _productosService.obtenerProductos(
          cocinaCentralId: cocinaCentralId,
        );
      } else if ((usuario.tipoUsuario == 'administrador' ||
              usuario.isSuperuser) &&
          cocinaCentralId != null) {
        productos = await _productosService.obtenerProductos(
          cocinaCentralId: cocinaCentralId,
        );
      } else if (usuario.tipoUsuario == 'administrador' ||
          usuario.isSuperuser) {
        productos = await _productosService.obtenerProductos();
      }

      User? cocinaSeleccionada;
      if (cocinaCentralId != null) {
        final cocinas = await _productosService.obtenerCocinaCentrales();
        if (cocinas.isNotEmpty) {
          try {
            cocinaSeleccionada = cocinas.firstWhere(
              (cocina) => cocina.id == cocinaCentralId,
            );
          } catch (_) {
            cocinaSeleccionada = cocinas.first;
          }
        }
      }

      Map<int, int> cantidadesEnCarrito = {};
      final empleador = await _userSessionService.obtenerPropietario();

      if ((usuario.tipoUsuario == 'restaurante' ||
              (usuario.tipoUsuario == 'empleado' &&
                  empleador?.tipoUsuario == 'restaurante')) &&
          cocinaCentralId != null) {
        try {
          final carritos = await _carritoService.obtenerCarritos(
            filtros: {'cocina_central': cocinaCentralId.toString()},
          );

          if (carritos.isNotEmpty) {
            for (var item in carritos.first.productos) {
              cantidadesEnCarrito[item.productoId] = item.cantidad;
            }
          }
        } catch (e) {
          print('Error al cargar carrito: $e');
        }
      }

      return ProductsModel(
        productos: productos,
        cocinaSeleccionada: cocinaSeleccionada,
        cantidadesEnCarrito: cantidadesEnCarrito,
      );
    } catch (e) {
      return ProductsModel(error: 'Error al obtener productos: $e');
    }
  }

  Future<User?> _obtenerDatosEmpleador(int empleadorId) async {
    try {
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<ProductsModel> obtenerProductoDetalle(int productoId) async {
    try {
      final producto = await _productosService.obtenerProductoDetalle(
        productoId,
      );
      if (producto == null) {
        return ProductsModel(error: 'No se encontró el producto');
      }
      return ProductsModel(productoSeleccionado: producto);
    } catch (e) {
      return ProductsModel(error: 'Error al obtener detalle del producto: $e');
    }
  }

  Future<bool> crearProducto(Map<String, dynamic> datos, File? imagen) async {
    return await _productosService.crearProducto(datos, imagen);
  }

  Future<bool> actualizarProducto(
    int productoId,
    Map<String, dynamic> datos,
    File? imagen,
  ) async {
    final resultado = await _productosService.actualizarProducto(
      productoId,
      datos,
      imagen,
    );

    if (resultado) {
      await _invalidarCacheProducto(productoId);
    }

    return resultado;
  }

  Future<void> _invalidarCacheProducto(int productoId) async {
    try {
      await _productosService.obtenerProductoDetalle(productoId);
    } catch (e) {
      print('Error al invalidar cache del producto: $e');
    }
  }

  Future<bool> agregarAlCarrito(
    int productoId,
    int cantidad,
    int cocinaCentralId,
  ) async {
    return await _productosService.agregarAlCarrito(
      productoId,
      cantidad,
      cocinaCentralId,
    );
  }

  Future<List<Carrito>> obtenerCarritos({int? cocinaCentralId}) async {
    if (cocinaCentralId == null) return [];

    try {
      final carritos = await _carritoService.obtenerCarritos(
        filtros: {'cocina_central': cocinaCentralId.toString()},
      );
      return carritos;
    } catch (e) {
      print('Error al obtener carritos: $e');
      return [];
    }
  }

  bool puedeVerProductos() {
    final usuario = _userSessionService.user;
    if (usuario == null) return false;

    if (usuario.tipoUsuario == 'administrador' || usuario.isSuperuser) {
      return true;
    }

    if (usuario.tipoUsuario == 'cocina_central') {
      return true;
    }

    if (usuario.tipoUsuario == 'restaurante') {
      return true;
    }

    if (usuario.tipoUsuario == 'empleado') {
      final permisos = _userSessionService.permisos;
      return permisos?.puedeVerProductos ?? false;
    }

    return false;
  }

  bool puedeCrearEditarProductos() {
    final usuario = _userSessionService.user;
    if (usuario == null) return false;

    if (usuario.tipoUsuario == 'administrador' ||
        usuario.isSuperuser ||
        usuario.tipoUsuario == 'cocina_central') {
      return true;
    }

    if (usuario.tipoUsuario == 'empleado') {
      final permisos = _userSessionService.permisos;
      return permisos?.puedeCrearProductos ?? false;
    }

    return false;
  }

  Future<bool> esRestauranteOEmpleadoRestaurante() async {
    final usuario = _userSessionService.user;
    if (usuario == null) return false;

    if (usuario.tipoUsuario == 'restaurante') {
      return true;
    }

    if (usuario.tipoUsuario == 'empleado' && usuario.propietarioId != null) {
      final empleador = await _userSessionService.obtenerPropietario();
      return empleador?.tipoUsuario == 'restaurante';
    }

    return false;
  }

  String obtenerTipoUsuario() {
    return _userSessionService.user?.tipoUsuario ?? '';
  }

  Future obtenerPropietario() async {
    return await _userSessionService.obtenerPropietario();
  }
}
