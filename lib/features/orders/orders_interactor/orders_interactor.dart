import 'package:flutter/foundation.dart';
import 'package:foodflow_app/core/services/pedidos_service.dart';
import 'package:foodflow_app/core/services/usuario_services.dart';
import 'package:foodflow_app/core/services/usuario_sesion_service.dart';
import 'package:foodflow_app/models/pedido_model.dart';
import 'package:foodflow_app/models/user_model.dart';

class OrdersInteractor {
  final PedidosService _pedidosService = PedidosService();
  final UserService _userService = UserService();
  final UserSessionService _sessionService = UserSessionService();

  bool puedeVerPedidos() {
    final usuario = _sessionService.user;
    if (usuario == null) return false;

    if (usuario.isSuperuser || usuario.tipoUsuario == 'administrador') {
      return true;
    }

    if (usuario.tipoUsuario == 'restaurante' ||
        usuario.tipoUsuario == 'cocina_central') {
      return true;
    }

    if (usuario.tipoUsuario == 'empleado') {
      final permisos = _sessionService.permisos;
      return permisos?.puedeVerPedidos == true;
    }

    return false;
  }

  bool puedeCrearPedidos() {
    final usuario = _sessionService.user;
    if (usuario == null) return false;

    if (usuario.isSuperuser || usuario.tipoUsuario == 'administrador') {
      return true;
    }

    if (usuario.tipoUsuario == 'restaurante') {
      return true;
    }

    if (usuario.tipoUsuario == 'empleado') {
      final permisos = _sessionService.permisos;
      return permisos?.puedeCrearPedidos == true;
    }

    return false;
  }

  bool puedeEditarPedidos() {
    final usuario = _sessionService.user;
    if (usuario == null) return false;

    if (usuario.isSuperuser || usuario.tipoUsuario == 'administrador') {
      return true;
    }

    if (usuario.tipoUsuario == 'cocina_central') {
      return true;
    }

    if (usuario.tipoUsuario == 'restaurante') {
      return true;
    }

    if (usuario.tipoUsuario == 'empleado') {
      final permisos = _sessionService.permisos;
      return permisos?.puedeEditarPedidos == true;
    }

    return false;
  }

  Future<List<Pedido>> obtenerPedidos({Map<String, dynamic>? filtros}) async {
    if (!puedeVerPedidos()) {
      throw Exception('No tienes permisos para ver pedidos');
    }

    try {
      return await _pedidosService.obtenerPedidos(filtros: filtros);
    } catch (e) {
      if (kDebugMode) {
        print('Error en obtenerPedidos: $e');
      }
      rethrow;
    }
  }

  Future<Pedido?> obtenerPedidoDetalle(int pedidoId) async {
    if (!puedeVerPedidos()) {
      throw Exception('No tienes permisos para ver el detalle del pedido');
    }

    try {
      return await _pedidosService.obtenerPedidoDetalle(pedidoId);
    } catch (e) {
      if (kDebugMode) {
        print('Error en obtenerPedidoDetalle: $e');
      }
      rethrow;
    }
  }

  Future<List<User>> obtenerUsuariosRelacionados() async {
    try {
      final usuario = _sessionService.user;
      if (usuario == null) return [];

      List<User> usuarios = [];

      switch (usuario.tipoUsuario) {
        case 'restaurante':
          break;
        case 'cocina_central':
          break;
        case 'administrador':
        case 'superuser':
          break;
        case 'empleado':
          final permisos = _sessionService.permisos;
          if (permisos?.puedeVerUsuarios == true) {}
          break;
      }

      return usuarios;
    } catch (e) {
      if (kDebugMode) {
        print('Error en obtenerUsuariosRelacionados: $e');
      }
      return [];
    }
  }

  Future<bool> actualizarPedido(Pedido pedido) async {
    if (!puedeEditarPedidos()) {
      throw Exception('No tienes permisos para editar pedidos');
    }

    try {
      final resultado = await _pedidosService.actualizarPedido(pedido);
      return resultado;
    } catch (e) {
      if (kDebugMode) {
        print('Error en actualizarPedido: $e');
      }
      return false;
    }
  }

  Future<bool> cancelarPedido(int pedidoId, String motivo) async {
    if (!puedeEditarPedidos()) {
      throw Exception('No tienes permisos para cancelar pedidos');
    }

    try {
      final resultado = await _pedidosService.cancelarPedido(pedidoId, motivo);
      return resultado;
    } catch (e) {
      if (kDebugMode) {
        print('Error en cancelarPedido: $e');
      }
      return false;
    }
  }

  Future<bool> crearPedido(Pedido pedido) async {
    if (!puedeCrearPedidos()) {
      throw Exception('No tienes permisos para crear pedidos');
    }

    try {
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error en crearPedido: $e');
      }
      return false;
    }
  }
}
