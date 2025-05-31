import 'package:flutter/foundation.dart';
import 'package:foodflow_app/core/services/inventario_service.dart';
import 'package:foodflow_app/core/services/productos_service.dart';
import 'package:foodflow_app/core/services/usuario_sesion_service.dart';
import 'package:foodflow_app/core/services/usuario_services.dart';
import 'package:foodflow_app/features/warehouse/warehouse_model/warehouse_model.dart';
import 'package:foodflow_app/models/user_model.dart';
import 'package:foodflow_app/models/inventario_model.dart';
import 'package:foodflow_app/models/producto_model.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/services/api_services.dart';
import '../../../models/categoria_model.dart';

class WarehouseInteractor {
  final InventarioService _inventarioService = InventarioService();
  final ProductosService _productosService = ProductosService();
  final UserSessionService _userSessionService = UserSessionService();
  final UserService _userService = UserService();

  Future<WarehouseModel> obtenerInventario() async {
    try {
      final inventario = await _inventarioService.obtenerInventario();
      return WarehouseModel(inventarioItems: inventario);
    } catch (e) {
      return WarehouseModel(error: 'Error al obtener inventario: $e');
    }
  }

  Future<WarehouseModel> obtenerProductosDisponibles() async {
    try {
      final productos = await _productosService.obtenerProductos();
      return WarehouseModel(productosDisponibles: productos);
    } catch (e) {
      return WarehouseModel(
        error: 'Error al obtener productos disponibles: $e',
      );
    }
  }

  Future<List<Inventario>> obtenerInventarioDeCocina(
    int cocinaCentralId,
  ) async {
    try {
      final response = await ApiServices.dio.get(
        '${ApiEndpoints.almacenes}?usuario=$cocinaCentralId',
      );

      if (response.statusCode == 200) {
        final List<dynamic> inventarioData = response.data;

        final inventarioLista =
            inventarioData.map((item) => Inventario.fromJson(item)).toList();

        return inventarioLista;
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  Future<List<Producto>> obtenerProductosDeCocina(int cocinaCentralId) async {
    try {
      final productos = await _productosService.obtenerProductos(
        cocinaCentralId: cocinaCentralId,
      );
      return productos;
    } catch (e) {
      return [];
    }
  }

  Future<bool> actualizarStockProducto(int inventarioId, int nuevoStock) async {
    try {
      final response = await _inventarioService.actualizarStock(
        inventarioId,
        nuevoStock,
      );
      return response;
    } catch (e) {
      return false;
    }
  }

  Future<bool> agregarProductoAlInventario(int productoId, int cantidad) async {
    try {
      final response = await _inventarioService.agregarProductoAlInventario(
        productoId,
        cantidad,
      );
      return response;
    } catch (e) {
      return false;
    }
  }

  Future<bool> agregarProductoAlInventarioDeUsuario(
    int productoId,
    int cantidad,
    int usuarioId,
  ) async {
    try {
      final response = await _inventarioService
          .agregarProductoAlInventarioDeUsuario(
            productoId,
            cantidad,
            usuarioId,
          );
      return response;
    } catch (e) {
      return false;
    }
  }

  Future<bool> actualizarStockPorQR(
    int productoId,
    int cantidad,
    bool esSuma,
  ) async {
    try {
      final operacion = esSuma ? cantidad : -cantidad;
      final response = await _inventarioService.actualizarStockPorQR(
        productoId,
        operacion,
      );
      return response;
    } catch (e) {
      return false;
    }
  }

  Future<List<User>> obtenerTodosLosUsuarios() async {
    try {
      return await _userService.obtenerTodosLosUsuarios();
    } catch (e) {
      return [];
    }
  }

  Future<List<User>> obtenerCocinasDeUsuario(int usuarioId) async {
    try {
      return await _userService.obtenerCocinasDeUsuario(usuarioId);
    } catch (e) {
      return [];
    }
  }

  Future<List<User>> obtenerUsuariosParaSeleccion() async {
    try {
      final usuarios = await _userService.obtenerTodosLosUsuarios();
      return usuarios
          .where(
            (user) =>
                user.tipoUsuario == 'restaurante' ||
                user.tipoUsuario == 'cocina_central',
          )
          .toList();
    } catch (e) {
      return [];
    }
  }

  bool esAdmin() {
    final usuario = _userSessionService.user;
    return usuario?.tipoUsuario == 'administrador' ||
        usuario?.isSuperuser == true;
  }

  bool esRestauranteOCocina() {
    final usuario = _userSessionService.user;
    return usuario?.tipoUsuario == 'restaurante' ||
        usuario?.tipoUsuario == 'cocina_central';
  }

  bool esEmpleado() {
    final usuario = _userSessionService.user;
    return usuario?.tipoUsuario == 'empleado';
  }

  int? obtenerIdUsuarioParaInventario() {
    final usuario = _userSessionService.user;
    if (esRestauranteOCocina()) {
      return usuario?.id;
    } else if (esEmpleado()) {
      return usuario?.empleadorId ?? usuario?.propietarioId;
    }
    return null;
  }

  Map<String, dynamic> obtenerConfiguracionFlujoAgregarProducto() {
    if (esAdmin()) {
      return {
        'flujo': 'admin',
        'requiereSeleccionUsuario': true,
        'requiereSeleccionCocina': true,
      };
    } else if (esRestauranteOCocina()) {
      return {
        'flujo': 'restaurante_cocina',
        'requiereSeleccionUsuario': false,
        'requiereSeleccionCocina': true,
        'usuarioId': _userSessionService.user?.id,
      };
    } else if (esEmpleado()) {
      return {
        'flujo': 'empleado',
        'requiereSeleccionUsuario': false,
        'requiereSeleccionCocina': false,
        'usuarioId': obtenerIdUsuarioParaInventario(),
      };
    }
    return {
      'flujo': 'no_permitido',
      'error': 'No tienes permisos para agregar productos al inventario',
    };
  }

  bool tienePermisoParaVerInventario() {
    final usuario = _userSessionService.user;
    if (usuario == null) return false;

    if (usuario.tipoUsuario == 'administrador' || usuario.isSuperuser) {
      return true;
    }

    if (usuario.tipoUsuario == 'cocina_central' ||
        usuario.tipoUsuario == 'restaurante') {
      return true;
    }

    if (usuario.tipoUsuario == 'empleado') {
      final permisos = _userSessionService.permisos;
      return permisos?.puedeVerAlmacenes ?? false;
    }

    return false;
  }

  bool tienePermisoParaModificarInventario() {
    final usuario = _userSessionService.user;
    if (usuario == null) return false;

    if (usuario.tipoUsuario == 'administrador' || usuario.isSuperuser) {
      return true;
    }

    if (usuario.tipoUsuario == 'cocina_central' ||
        usuario.tipoUsuario == 'restaurante') {
      return true;
    }

    if (usuario.tipoUsuario == 'empleado') {
      final permisos = _userSessionService.permisos;
      return permisos?.puedeModificarAlmacenes ?? false;
    }

    return false;
  }

  Future<WarehouseModel> obtenerCategorias() async {
    try {
      final response = await ApiServices.dio.get(ApiEndpoints.categorias);

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        final categorias =
            data.map((item) => Categoria.fromJson(item)).toList();

        return WarehouseModel(categorias: categorias);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error al obtener categorías: $e');
      }
    }

    return WarehouseModel(categorias: []);
  }
}
