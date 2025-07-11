import 'package:foodflow_app/core/services/incidencias_service.dart';
import 'package:foodflow_app/core/services/pedidos_service.dart';
import 'package:foodflow_app/core/services/productos_service.dart';
import 'package:foodflow_app/core/services/usuario_services.dart';
import 'package:foodflow_app/core/services/usuario_sesion_service.dart';
import 'package:foodflow_app/core/services/event_bus_service.dart';
import 'package:foodflow_app/features/incidents/incidents_model/incidents_model.dart';
import 'package:foodflow_app/models/pedido_model.dart';
import 'package:foodflow_app/models/pedido_producto_model.dart';
import 'package:foodflow_app/models/producto_model.dart';
import 'package:foodflow_app/models/user_model.dart';

class IncidentsInteractor {
  final IncidenciasService _incidenciasService = IncidenciasService();
  final PedidosService _pedidosService = PedidosService();
  final ProductosService _productosService = ProductosService();
  final UserService _userService = UserService();
  final UserSessionService _userSessionService = UserSessionService();
  final EventBusService _eventBus = EventBusService();

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
      final resultado = await _incidenciasService.crearIncidencia(
        pedidoId: pedidoId,
        productoId: productoId,
        nuevaCantidad: nuevaCantidad,
        descripcion: descripcion,
      );
      if (resultado) {
        _eventBus.publishDataChanged('incidents.created');
      }
      return resultado;
    } catch (e) {
      return false;
    }
  }

  Future<bool> resolverIncidencia(int incidenciaId) async {
    try {
      final resultado = await _incidenciasService.resolverIncidencia(
        incidenciaId,
      );
      if (resultado) {
        _eventBus.publishDataChanged('incidents.resolved');
      }
      return resultado;
    } catch (e) {
      return false;
    }
  }

  Future<bool> cancelarIncidencia(int incidenciaId) async {
    try {
      final resultado = await _incidenciasService.cancelarIncidencia(
        incidenciaId,
      );
      if (resultado) {
        _eventBus.publishDataChanged('incidents.cancelled');
      }
      return resultado;
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

  Future<List<Producto>> obtenerProductos() async {
    try {
      return await _productosService.obtenerProductos();
    } catch (e) {
      return [];
    }
  }

  Future<List<User>> obtenerUsuarios() async {
    try {
      final usuario = _userSessionService.user;
      if (usuario == null) return [];

      if (usuario.tipoUsuario == 'administrador' ||
          usuario.isSuperuser ||
          usuario.tipoUsuario == 'cocina_central') {
        final usuarios = await _userService.obtenerTodosLosUsuarios();
        return usuarios
            .where(
              (u) => !['administrador', 'empleado'].contains(u.tipoUsuario),
            )
            .toList();
      }

      return [];
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
