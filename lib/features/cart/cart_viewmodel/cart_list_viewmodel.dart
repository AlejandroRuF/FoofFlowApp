import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:foodflow_app/features/cart/cart_model/cart_model.dart';
import 'package:foodflow_app/core/services/event_bus_service.dart';
import '../cart_interactor/cart_interactor.dart';

class CartListViewModel extends ChangeNotifier {
  final CartInteractor _interactor = CartInteractor();
  final EventBusService _eventBus = EventBusService();

  CartModel _model = CartModel(isLoading: true);
  StreamSubscription<String>? _dataChangedSubscription;
  StreamSubscription<RefreshEvent>? _eventSubscription;

  CartModel get model => _model;

  CartListViewModel() {
    _subscribeToEvents();
    _listenToEvents();
    cargarCarritos();
  }

  @override
  void dispose() {
    _dataChangedSubscription?.cancel();
    _eventSubscription?.cancel();
    super.dispose();
  }

  void _listenToEvents() {
    _eventSubscription = _eventBus.stream.listen((event) {
      if (event.type == RefreshEventType.products ||
          event.type == RefreshEventType.all) {
        cargarCarritos();
      }
    });
  }

  void _subscribeToEvents() {
    _dataChangedSubscription = _eventBus.dataChangedStream.listen((eventKey) {
      if (eventKey == 'cart_updated' ||
          eventKey == 'cart_item_added' ||
          eventKey == 'cart_item_removed' ||
          eventKey == 'cart_item_updated' ||
          eventKey == 'cart_cleared' ||
          eventKey == 'product_update' ||
          eventKey == 'responsive_scaffold_cart_refresh' ||
          eventKey == 'responsive_scaffold_all_refresh') {
        cargarCarritos();
      }
    });
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
