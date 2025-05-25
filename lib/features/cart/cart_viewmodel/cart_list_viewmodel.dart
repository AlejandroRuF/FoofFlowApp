import 'package:flutter/foundation.dart';
import 'package:foodflow_app/features/cart/cart_model/cart_model.dart';
import '../cart_interactor/cart_interactor.dart';

class CartListViewModel extends ChangeNotifier {
  final CartInteractor _interactor = CartInteractor();

  CartModel _model = CartModel(isLoading: true);

  CartModel get model => _model;

  CartListViewModel() {
    cargarCarritos();
  }

  Future<void> cargarCarritos({Map<String, dynamic>? filtros}) async {
    _setLoading(true);
    try {
      final carritos = await _interactor.obtenerCarritos(filtros: filtros);
      _model = _model.copyWith(
        carritos: carritos,
        isLoading: false,
        error: null,
        filtros: filtros ?? {},
      );
    } catch (e) {
      _model = _model.copyWith(
        isLoading: false,
        error: 'Error al cargar carritos: $e',
      );
      if (kDebugMode) {
        print('Error en cargarCarritos: $e');
      }
    }
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _model = _model.copyWith(isLoading: loading);
    notifyListeners();
  }
}
