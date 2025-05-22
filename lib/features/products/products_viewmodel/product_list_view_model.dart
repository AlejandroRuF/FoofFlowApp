import 'package:flutter/material.dart';
import 'package:foodflow_app/features/products/products_interactor/products_interactor.dart';
import 'package:foodflow_app/features/products/products_model/products_model.dart';
import 'package:foodflow_app/models/producto_model.dart';

class ProductListViewModel extends ChangeNotifier {
  final ProductsInteractor _interactor = ProductsInteractor();

  ProductsModel _model = ProductsModel();

  List<Producto> get productos => _model.productos;
  bool get isLoading => _model.isLoading;
  String? get error => _model.error;

  String _busqueda = '';
  String get busqueda => _busqueda;

  bool _mostrarProductosInactivos = false;
  bool get mostrarProductosInactivos => _mostrarProductosInactivos;

  int? _cocinaCentralIdSeleccionada;

  ProductListViewModel();

  bool get esCocinaCentral =>
      _interactor.obtenerTipoUsuario() == 'cocina_central';
  bool get esAdministrador =>
      _interactor.obtenerTipoUsuario() == 'administrador' ||
      _interactor.obtenerTipoUsuario() == 'superuser';
  bool get esRestaurante => _interactor.obtenerTipoUsuario() == 'restaurante';
  String get tipoUsuario => _interactor.obtenerTipoUsuario();
  bool get puedeCrearProductos => _interactor.puedeCrearEditarProductos();

  void establecerCocinaCentral(int cocinaCentralId) {
    _cocinaCentralIdSeleccionada = cocinaCentralId;
    cargarProductos();
  }

  void establecerBusqueda(String busqueda) {
    _busqueda = busqueda;
    notifyListeners();
  }

  void toggleMostrarInactivos() {
    _mostrarProductosInactivos = !_mostrarProductosInactivos;
    cargarProductos();
  }

  List<Producto> get productosFiltrados {
    var productosFiltrados = _model.filtrarProductosPorNombre(_busqueda);

    if (!_mostrarProductosInactivos) {
      productosFiltrados = productosFiltrados.where((p) => p.isActive).toList();
    }

    return productosFiltrados;
  }

  Future<void> cargarProductos() async {
    _model = _model.copyWith(isLoading: true, error: null);
    notifyListeners();

    try {
      final nuevoModelo = await _interactor.obtenerProductos(
        cocinaCentralId: _cocinaCentralIdSeleccionada,
      );

      _model = nuevoModelo.copyWith(isLoading: false);
      notifyListeners();
    } catch (e) {
      _model = _model.copyWith(
        isLoading: false,
        error: 'Error al cargar productos: $e',
      );
      notifyListeners();
    }
  }

  Future<bool> agregarAlCarrito(int productoId, int cantidad) async {
    if (_model.cocinaSeleccionada == null) {
      _model = _model.copyWith(error: 'No hay cocina central seleccionada');
      notifyListeners();
      return false;
    }

    try {
      final resultado = await _interactor.agregarAlCarrito(
        productoId,
        cantidad,
        _model.cocinaSeleccionada!.id,
      );

      if (!resultado) {
        _model = _model.copyWith(error: 'Error al agregar producto al carrito');
      }

      return resultado;
    } catch (e) {
      _model = _model.copyWith(error: 'Error al agregar al carrito: $e');
      notifyListeners();
      return false;
    }
  }
}
