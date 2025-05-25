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
      // Obtiene pedidos completos con productos embebidos
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
      // Obtiene pedido con lista productos ya dentro del objeto Pedido
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
          // Implementar lógica específica si se requiere
          break;
        case 'cocina_central':
          // Implementar lógica específica si se requiere
          break;
        case 'administrador':
        case 'superuser':
          // Implementar lógica específica si se requiere
          break;
        case 'empleado':
          // Implementar lógica específica si se requiere
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
      // Asume que el servicio tiene método para actualizar pedido
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
      // Asume que el servicio tiene método para cancelar pedido
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
