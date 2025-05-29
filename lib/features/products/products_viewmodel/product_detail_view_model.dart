import 'dart:io';
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

  Future<void> refrescarProducto() async {
    if (producto?.id != null) {
      await cargarProducto(producto!.id);
    }
  }

  String obtenerUrlImagenConTimestamp(String? urlImagen) {
    if (urlImagen == null || urlImagen.isEmpty) return '';
    return '$urlImagen?v=${DateTime.now().millisecondsSinceEpoch}';
  }

  // MÉTODO CLAVE: Actualizar producto y refrescar vista
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
        // Forzar recarga inmediata del producto
        await cargarProducto(productoId);
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

  // Método para obtener la URL de imagen con timestamp para evitar cache
  String? obtenerImagenUrlConTimestamp() {
    if (producto == null) return null;

    final imagenUrl = producto!.getImagenUrlCompleta();
    if (imagenUrl == null || imagenUrl.isEmpty) return null;

    return obtenerUrlImagenConTimestamp(imagenUrl);
  }

  // Método para obtener la URL de imagen QR con timestamp
  String? obtenerImagenQrUrlConTimestamp() {
    if (producto == null) return null;

    final imagenQrUrl = producto!.getImagenQrUrlCompleta();
    if (imagenQrUrl == null || imagenQrUrl.isEmpty) return null;

    return obtenerUrlImagenConTimestamp(imagenQrUrl);
  }

  // Método para limpiar errores
  void limpiarError() {
    _model = _model.copyWith(error: null);
    notifyListeners();
  }

  // Método para forzar actualización de la vista (útil después de editar)
  void forzarActualizacion() {
    notifyListeners();
  }
}
