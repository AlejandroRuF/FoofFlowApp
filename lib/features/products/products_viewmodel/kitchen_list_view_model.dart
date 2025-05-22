import 'package:flutter/material.dart';
import 'package:foodflow_app/features/products/products_interactor/products_interactor.dart';
import 'package:foodflow_app/features/products/products_model/products_model.dart';
import 'package:foodflow_app/models/user_model.dart';

class KitchenListViewModel extends ChangeNotifier {
  final ProductsInteractor _interactor = ProductsInteractor();

  ProductsModel _model = ProductsModel();
  List<User> get cocinas => _model.cocinas;
  bool get isLoading => _model.isLoading;
  String? get error => _model.error;
  String _busqueda = '';
  String get busqueda => _busqueda;

  KitchenListViewModel() {
    cargarCocinaCentrales();
  }

  void establecerBusqueda(String busqueda) {
    _busqueda = busqueda;
    notifyListeners();
  }

  List<User> get cocinasFiltradas {
    return _model.filtrarCocinasPorNombre(_busqueda);
  }

  Future<void> cargarCocinaCentrales() async {
    _model = _model.copyWith(isLoading: true, error: null);
    notifyListeners();

    try {
      final nuevoModelo = await _interactor.obtenerCocinaCentrales();

      _model = nuevoModelo.copyWith(isLoading: false);
      notifyListeners();
    } catch (e) {
      _model = _model.copyWith(
        isLoading: false,
        error: 'Error al cargar cocinas centrales: $e',
      );
      notifyListeners();
    }
  }
}
