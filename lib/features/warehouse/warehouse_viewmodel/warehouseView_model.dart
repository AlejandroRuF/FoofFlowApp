import 'dart:async';
import 'package:flutter/material.dart';
import 'package:foodflow_app/features/warehouse/interactor/warehouse_interactor.dart';
import 'package:foodflow_app/features/warehouse/warehouse_model/warehouse_model.dart';
import 'package:foodflow_app/core/services/event_bus_service.dart';

class WarehouseViewModel extends ChangeNotifier {
  final WarehouseInteractor _interactor = WarehouseInteractor();
  final EventBusService _eventBus = EventBusService();
  WarehouseModel _state = WarehouseModel();
  StreamSubscription<String>? _dataChangedSubscription;

  WarehouseModel get state => _state;

  bool get tienePermisoVerInventario =>
      _interactor.tienePermisoParaVerInventario();
  bool get tienePermisoModificarInventario =>
      _interactor.tienePermisoParaModificarInventario();

  WarehouseViewModel() {
    _verificarPermisos();
    _subscribeToEvents();
  }

  @override
  void dispose() {
    _dataChangedSubscription?.cancel();
    super.dispose();
  }

  void _subscribeToEvents() {
    _dataChangedSubscription = _eventBus.dataChangedStream.listen((eventKey) {
      if (eventKey == 'responsive_scaffold_warehouse_refresh' ||
          eventKey == 'responsive_scaffold_inventory_refresh' ||
          eventKey == 'responsive_scaffold_all_refresh' ||
          eventKey == 'inventory_update' ||
          eventKey == 'inventory_add' ||
          eventKey == 'inventory_add_user' ||
          eventKey == 'inventory_bulk_add' ||
          eventKey == 'product_create' ||
          eventKey == 'product_update' ||
          eventKey == 'qr_stock_update') {
        cargarDatos();
      }
    });
  }

  void _verificarPermisos() {
    if (!tienePermisoVerInventario) {
      _state = _state.copyWith(
        error: 'No tienes permiso para acceder al almacén',
      );
      notifyListeners();
    }
  }

  Future<void> cargarDatos() async {
    _state = _state.copyWith(isLoading: true, error: null);
    notifyListeners();

    if (!tienePermisoVerInventario) {
      _state = _state.copyWith(
        isLoading: false,
        error: 'No tienes permiso para acceder al almacén',
      );
      notifyListeners();
      return;
    }

    try {
      final inventarioModel = await _interactor.obtenerInventario();
      _state = _state.copyWith(
        isLoading: false,
        inventarioItems: inventarioModel.inventarioItems,
        error: inventarioModel.error,
      );
    } catch (e) {
      _state = _state.copyWith(
        isLoading: false,
        error: 'Error al cargar datos del almacén: $e',
      );
    }
    notifyListeners();
  }

  void buscar(String query) {
    _state = _state.copyWith(busqueda: query);
    notifyListeners();
  }

  void toggleMostrarStockBajo() {
    _state = _state.copyWith(mostrarStockBajo: !_state.mostrarStockBajo);
    notifyListeners();
  }
}
