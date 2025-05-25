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

  Future<List<Pedido>> obtenerPedidos({Map<String, dynamic>? filtros}) async {
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
}
