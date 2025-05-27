import 'package:foodflow_app/core/services/inventario_service.dart';
import 'package:foodflow_app/core/services/productos_service.dart';
import 'package:foodflow_app/core/services/usuario_sesion_service.dart';
import 'package:foodflow_app/features/warehouse/warehouse_model/warehouse_model.dart';


class WarehouseInteractor {
  final InventarioService _inventarioService = InventarioService();
  final ProductosService _productosService = ProductosService();
  final UserSessionService _userSessionService = UserSessionService();

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
}
