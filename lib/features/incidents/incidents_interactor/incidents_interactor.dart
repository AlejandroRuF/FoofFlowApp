import 'package:foodflow_app/core/services/incidencias_service.dart';
import 'package:foodflow_app/core/services/pedidos_service.dart';
import 'package:foodflow_app/core/services/productos_service.dart';
import 'package:foodflow_app/core/services/usuario_sesion_service.dart';
import 'package:foodflow_app/features/incidents/incidents_model/incidents_model.dart';
import 'package:foodflow_app/models/pedido_model.dart';
import 'package:foodflow_app/models/pedido_producto_model.dart';

class IncidentsInteractor {
  final IncidenciasService _incidenciasService = IncidenciasService();
  final PedidosService _pedidosService = PedidosService();
  final ProductosService _productosService = ProductosService();
  final UserSessionService _userSessionService = UserSessionService();

  Future<IncidentsModel> obtenerIncidencias({
    Map<String, dynamic>? filtros,
  }) async {
    try {
      final incidencias = await _incidenciasService.obtenerIncidencias(
        filtros: filtros,
      );
      return IncidentsModel(incidencias: incidencias);
    } catch (e) {
      return IncidentsModel(error: 'Error al obtener incidencias: $e');
    }
  }

  Future<IncidentsModel> obtenerIncidenciaDetalle(int incidenciaId) async {
    try {
      final incidencia = await _incidenciasService.obtenerIncidenciaDetalle(
        incidenciaId,
      );
      if (incidencia == null) {
        return IncidentsModel(error: 'No se encontró la incidencia');
      }
      return IncidentsModel(incidenciaSeleccionada: incidencia);
    } catch (e) {
      return IncidentsModel(
        error: 'Error al obtener detalle de la incidencia: $e',
      );
    }
  }

  Future<bool> crearIncidencia({
    required int pedidoId,
    required int productoId,
    required int nuevaCantidad,
    required String descripcion,
  }) async {
    try {
      return await _incidenciasService.crearIncidencia(
        pedidoId: pedidoId,
        productoId: productoId,
        nuevaCantidad: nuevaCantidad,
        descripcion: descripcion,
      );
    } catch (e) {
      return false;
    }
  }

  Future<bool> resolverIncidencia(int incidenciaId) async {
    try {
      return await _incidenciasService.resolverIncidencia(incidenciaId);
    } catch (e) {
      return false;
    }
  }

  Future<bool> cancelarIncidencia(int incidenciaId) async {
    try {
      return await _incidenciasService.cancelarIncidencia(incidenciaId);
    } catch (e) {
      return false;
    }
  }

  Future<List<Pedido>> obtenerPedidosUsuario() async {
    try {
      return await _pedidosService.obtenerPedidos();
    } catch (e) {
      return [];
    }
  }

  Future<List<PedidoProducto>> obtenerProductosPedido(int pedidoId) async {
    try {
      final productosDelPedido = await _pedidosService.obtenerProductosPedido(
        pedidoId,
      );

      if (productosDelPedido.isEmpty) {
        return [];
      }

      final todosLosProductos = await _productosService.obtenerProductos();
      final mapaProductos = {
        for (var producto in todosLosProductos) producto.id: producto.nombre,
      };

      final productosEnriquecidos =
          productosDelPedido.map((producto) {
            return PedidoProducto(
              id: producto.id,
              pedidoId: producto.pedidoId,
              productoId: producto.productoId,
              productoNombre:
                  mapaProductos[producto.productoId] ??
                  'Producto #${producto.productoId}',
              cantidad: producto.cantidad,
              precioUnitario: producto.precioUnitario,
            );
          }).toList();

      return productosEnriquecidos;
    } catch (e) {
      print('Error al obtener productos del pedido: $e');
      return [];
    }
  }

  bool puedeVerIncidencias() {
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
      return permisos?.puedeVerIncidencias ?? false;
    }

    return false;
  }

  bool puedeCrearIncidencias() {
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
      return permisos?.puedeCrearIncidencias ?? false;
    }

    return false;
  }

  String obtenerTipoUsuario() {
    return _userSessionService.user?.tipoUsuario ?? '';
  }
}
