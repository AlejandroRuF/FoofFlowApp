import 'package:flutter/material.dart';
import 'package:foodflow_app/features/warehouse/interactor/warehouse_interactor.dart';
import 'package:foodflow_app/features/warehouse/warehouse_model/warehouse_model.dart';

class WarehouseViewModel extends ChangeNotifier {
  final WarehouseInteractor _interactor = WarehouseInteractor();
  WarehouseModel _state = WarehouseModel();

  WarehouseModel get state => _state;

  bool get tienePermisoVerInventario =>
      _interactor.tienePermisoParaVerInventario();
  bool get tienePermisoModificarInventario =>
      _interactor.tienePermisoParaModificarInventario();

  WarehouseViewModel() {
    _verificarPermisos();
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
