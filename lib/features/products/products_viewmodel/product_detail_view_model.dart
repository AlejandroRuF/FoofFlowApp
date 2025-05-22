import 'package:flutter/material.dart';
import 'package:foodflow_app/features/products/products_interactor/products_interactor.dart';
import 'package:foodflow_app/features/products/products_model/products_model.dart';
import 'package:foodflow_app/models/producto_model.dart';

class ProductDetailViewModel extends ChangeNotifier {
  final ProductsInteractor _interactor = ProductsInteractor();

  ProductsModel _model = ProductsModel();
  Producto? get producto => _model.productoSeleccionado;
  bool get isLoading => _model.isLoading;
  String? get error => _model.error;

  bool get puedeEditarProducto => _interactor.puedeCrearEditarProductos();

  Future<void> cargarProducto(int productoId) async {
    _model = _model.copyWith(isLoading: true, error: null);
    notifyListeners();

    try {
      final nuevoModelo = await _interactor.obtenerProductoDetalle(productoId);
      _model = nuevoModelo.copyWith(isLoading: false);
      notifyListeners();
    } catch (e) {
      _model = _model.copyWith(
        isLoading: false,
        error: 'Error al cargar detalles del producto: $e',
      );
      notifyListeners();
    }
  }
}
