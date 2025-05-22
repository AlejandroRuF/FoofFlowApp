import 'package:flutter/material.dart';
import 'package:foodflow_app/features/warehouse/interactor/warehouse_interactor.dart';
import 'package:foodflow_app/features/warehouse/warehouse_model/warehouse_model.dart';
import 'package:foodflow_app/models/inventario_model.dart';
import 'package:foodflow_app/models/producto_model.dart';

class InventoryViewModel extends ChangeNotifier {
  final WarehouseInteractor _interactor = WarehouseInteractor();
  WarehouseModel _state = WarehouseModel();

  WarehouseModel get state => _state;

  bool get tienePermisoVerInventario =>
      _interactor.tienePermisoParaVerInventario();
  bool get tienePermisoModificarInventario =>
      _interactor.tienePermisoParaModificarInventario();

  List<Inventario> get inventarioFiltrado => _state.inventarioFiltrado;

  InventoryViewModel() {
    cargarInventario();
  }

  Future<void> cargarInventario() async {
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

  Future<void> cargarProductosDisponibles() async {
    try {
      final productosModel = await _interactor.obtenerProductosDisponibles();
      _state = _state.copyWith(
        productosDisponibles: productosModel.productosDisponibles,
      );
      notifyListeners();
    } catch (e) {}
  }

  Future<bool> actualizarStockProducto(int inventarioId, int nuevoStock) async {
    if (!tienePermisoModificarInventario) {
      return false;
    }

    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    final resultado = await _interactor.actualizarStockProducto(
      inventarioId,
      nuevoStock,
    );

    if (resultado) {
      await cargarInventario();
    } else {
      _state = _state.copyWith(
        isLoading: false,
        error: 'Error al actualizar el stock del producto',
      );
      notifyListeners();
    }

    return resultado;
  }

  Future<bool> agregarProductoAlInventario(int productoId, int cantidad) async {
    if (!tienePermisoModificarInventario) {
      return false;
    }

    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    final resultado = await _interactor.agregarProductoAlInventario(
      productoId,
      cantidad,
    );

    if (resultado) {
      await cargarInventario();
    } else {
      _state = _state.copyWith(
        isLoading: false,
        error: 'Error al agregar el producto al inventario',
      );
      notifyListeners();
    }

    return resultado;
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
