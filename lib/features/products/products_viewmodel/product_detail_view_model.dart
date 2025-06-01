import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:foodflow_app/features/products/products_interactor/products_interactor.dart';
import 'package:foodflow_app/features/products/products_model/products_model.dart';
import 'package:foodflow_app/models/producto_model.dart';
import 'package:foodflow_app/core/services/event_bus_service.dart';

class ProductDetailViewModel extends ChangeNotifier {
  final ProductsInteractor _interactor = ProductsInteractor();
  final EventBusService _eventBus = EventBusService();

  ProductsModel _model = ProductsModel();
  StreamSubscription<String>? _dataChangedSubscription;
  StreamSubscription<RefreshEvent>? _eventSubscription;

  Producto? get producto => _model.productoSeleccionado;
  bool get isLoading => _model.isLoading;
  String? get error => _model.error;

  bool get puedeEditarProducto => _interactor.puedeCrearEditarProductos();

  ProductDetailViewModel() {
    _subscribeToEvents();
    _listenToEvents();
  }

  @override
  void dispose() {
    _dataChangedSubscription?.cancel();
    _eventSubscription?.cancel();
    super.dispose();
  }

  void _listenToEvents() {
    _eventSubscription = _eventBus.stream.listen((event) {
      if ((event.type == RefreshEventType.products ||
              event.type == RefreshEventType.all) &&
          producto?.id != null) {
        refrescarProducto();
      }
    });
  }

  void _subscribeToEvents() {
    _dataChangedSubscription = _eventBus.dataChangedStream.listen((eventKey) {
      if ((eventKey == 'product_update' ||
              eventKey == 'product_create' ||
              eventKey == 'inventory_update' ||
              eventKey == 'inventory_add' ||
              eventKey == 'inventory_add_user' ||
              eventKey == 'inventory_bulk_add' ||
              eventKey == 'qr_stock_update') &&
          producto?.id != null) {
        refrescarProducto();
      }
    });
  }

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

  Future<void> refrescarProducto() async {
    if (producto?.id != null) {
      await cargarProducto(producto!.id);
    }
  }

  String obtenerUrlImagenConTimestamp(String? urlImagen) {
    if (urlImagen == null || urlImagen.isEmpty) return '';
    return '$urlImagen?v=${DateTime.now().millisecondsSinceEpoch}';
  }

  Future<bool> actualizarProductoYRefrescar(
    int productoId,
    Map<String, dynamic> datos,
    File? imagen,
  ) async {
    try {
      _model = _model.copyWith(isLoading: true, error: null);
      notifyListeners();

      final resultado = await _interactor.actualizarProducto(
        productoId,
        datos,
        imagen,
      );

      if (resultado) {
        await cargarProducto(productoId);
        _eventBus.publishDataChanged('product_update');
      } else {
        _model = _model.copyWith(
          isLoading: false,
          error: 'Error al actualizar el producto',
        );
        notifyListeners();
      }

      return resultado;
    } catch (e) {
      _model = _model.copyWith(
        isLoading: false,
        error: 'Error al actualizar producto: $e',
      );
      notifyListeners();
      return false;
    }
  }

  String? obtenerImagenUrlConTimestamp() {
    if (producto == null) return null;

    final imagenUrl = producto!.getImagenUrlCompleta();
    if (imagenUrl == null || imagenUrl.isEmpty) return null;

    return obtenerUrlImagenConTimestamp(imagenUrl);
  }

  String? obtenerImagenQrUrlConTimestamp() {
    if (producto == null) return null;

    final imagenQrUrl = producto!.getImagenQrUrlCompleta();
    if (imagenQrUrl == null || imagenQrUrl.isEmpty) return null;

    return obtenerUrlImagenConTimestamp(imagenQrUrl);
  }

  void limpiarError() {
    _model = _model.copyWith(error: null);
    notifyListeners();
  }

  void forzarActualizacion() {
    notifyListeners();
  }
}
