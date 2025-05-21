import 'package:flutter/foundation.dart';
import 'package:foodflow_app/features/orders/orders_interactor/orders_interactor.dart';
import 'package:foodflow_app/models/pedido_model.dart';

class OrderFormViewModel extends ChangeNotifier {
  final OrdersInteractor _interactor = OrdersInteractor();

  Pedido? _pedido;
  bool _isLoading = false;
  String? _error;

  Pedido? get pedido => _pedido;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> cargarPedido(int pedidoId) async {
    _setLoading(true);
    try {
      final pedidoCargado = await _interactor.obtenerPedidoDetalle(pedidoId);
      _pedido = pedidoCargado;
      _error = null;
    } catch (e) {
      _error = 'Error al cargar el pedido: $e';
      if (kDebugMode) {
        print('Error en cargarPedido: $e');
      }
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> guardarCambios(Map<String, dynamic> cambios) async {
    if (_pedido == null) return false;

    _setLoading(true);
    try {
      final Pedido pedidoActualizado = Pedido(
        id: _pedido!.id,
        restauranteId: _pedido!.restauranteId,
        restauranteNombre: _pedido!.restauranteNombre,
        cocinaCentralId: _pedido!.cocinaCentralId,
        cocinaCentralNombre: _pedido!.cocinaCentralNombre,
        fechaPedido: _pedido!.fechaPedido,
        fechaEntregaEstimada:
            cambios['fechaEntregaEstimada'] ?? _pedido!.fechaEntregaEstimada,
        fechaEntregaReal:
            cambios['fechaEntregaReal'] ?? _pedido!.fechaEntregaReal,
        estado: cambios['estado'] ?? _pedido!.estado,
        montoTotal: _pedido!.montoTotal,
        notas: cambios['notas'] ?? _pedido!.notas,
        tipoPedido: _pedido!.tipoPedido,
        urgente: cambios['urgente'] ?? _pedido!.urgente,
        motivoCancelacion:
            cambios['motivoCancelacion'] ?? _pedido!.motivoCancelacion,
        productos: _pedido!.productos,
      );

      final resultado = await _interactor.actualizarPedido(pedidoActualizado);
      if (resultado) {
        _pedido = pedidoActualizado;
        _error = null;
      } else {
        _error = 'No se pudo guardar los cambios';
      }
      return resultado;
    } catch (e) {
      _error = 'Error al guardar los cambios: $e';
      if (kDebugMode) {
        print('Error en guardarCambios: $e');
      }
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
