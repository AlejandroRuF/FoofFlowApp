import 'dart:io';

import 'package:flutter/material.dart';
import 'package:foodflow_app/core/services/productos_service.dart';
import 'package:foodflow_app/features/products/products_interactor/products_interactor.dart';
import 'package:foodflow_app/features/products/products_model/products_model.dart';
import 'package:foodflow_app/models/producto_model.dart';
import 'package:foodflow_app/models/user_model.dart';
import 'package:image_picker/image_picker.dart';

class ProductFormViewModel extends ChangeNotifier {
  final ProductosService _productosService = ProductosService();

  ProductsModel _model = ProductsModel();

  Producto? get producto => _model.productoSeleccionado;
  bool get isLoading => _model.isLoading;
  String? get error => _model.error;

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  final nombreController = TextEditingController();
  final descripcionController = TextEditingController();
  final precioController = TextEditingController();
  final impuestosController = TextEditingController();
  final unidadMedidaController = TextEditingController();

  int? categoriaSeleccionada;
  bool productoActivo = true;

  File? imagenSeleccionada;
  String? imagenUrl;

  List<User> cocinasCentrales = [];
  User? cocinaCentralSeleccionada;

  ProductFormViewModel() {
    _cargarCocinasCentrales();
  }

  Future<void> cargarProducto(int productoId) async {
    _model = _model.copyWith(isLoading: true, error: null);
    notifyListeners();

    try {
      final producto = await _productosService.obtenerProductoDetalle(
        productoId,
      );

      if (producto != null) {
        _model = _model.copyWith(
          isLoading: false,
          productoSeleccionado: producto,
        );

        nombreController.text = producto.nombre;
        descripcionController.text = producto.descripcion ?? '';
        precioController.text = producto.precio.toString();
        impuestosController.text = producto.impuestos.toString();
        unidadMedidaController.text = producto.unidadMedida;
        categoriaSeleccionada = producto.categoriaId;
        productoActivo = producto.isActive;
        imagenUrl = producto.imagenUrl;

        for (var cocina in cocinasCentrales) {
          if (cocina.id == producto.cocinaCentralId) {
            cocinaCentralSeleccionada = cocina;
            break;
          }
        }
      } else {
        _model = _model.copyWith(
          isLoading: false,
          error: 'No se pudo encontrar el producto',
        );
      }

      notifyListeners();
    } catch (e) {
      _model = _model.copyWith(
        isLoading: false,
        error: 'Error al cargar producto: $e',
      );
      notifyListeners();
    }
  }

  Future<void> _cargarCocinasCentrales() async {
    try {
      cocinasCentrales = await _productosService.obtenerCocinaCentrales();
      if (cocinasCentrales.isNotEmpty) {
        cocinaCentralSeleccionada = cocinasCentrales.first;
      }
      notifyListeners();
    } catch (e) {
      _model = _model.copyWith(error: 'Error al cargar cocinas centrales: $e');
      notifyListeners();
    }
  }

  Future<void> seleccionarImagen(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      maxWidth: 1000,
      maxHeight: 1000,
      imageQuality: 70,
    );

    if (pickedFile != null) {
      imagenSeleccionada = File(pickedFile.path);
      notifyListeners();
    }
  }

  void eliminarImagen() {
    imagenSeleccionada = null;
    notifyListeners();
  }

  Future<bool> guardarProducto() async {
    if (!_validarCampos()) {
      return false;
    }

    _isSaving = true;
    _model = _model.copyWith(error: null);
    notifyListeners();

    try {
      final datos = {
        'nombre': nombreController.text,
        'descripcion': descripcionController.text,
        'precio': double.parse(precioController.text),
        'impuestos': double.parse(impuestosController.text),
        'unidad_medida': unidadMedidaController.text,
        'is_active': productoActivo,
      };

      if (cocinaCentralSeleccionada != null) {
        datos['cocina_central'] = cocinaCentralSeleccionada!.id;
      }

      if (categoriaSeleccionada != null) {
        datos['categoria'] = categoriaSeleccionada as Object;
      }

      bool resultado;
      if (_model.productoSeleccionado == null) {
        resultado = await _productosService.crearProducto(datos);
      } else {
        resultado = await _productosService.actualizarProducto(
          _model.productoSeleccionado!.id,
          datos,
          imagenSeleccionada,
        );
      }

      _isSaving = false;
      notifyListeners();
      return resultado;
    } catch (e) {
      _isSaving = false;
      _model = _model.copyWith(error: 'Error al guardar producto: $e');
      notifyListeners();
      return false;
    }
  }

  bool _validarCampos() {
    if (nombreController.text.isEmpty) {
      _model = _model.copyWith(error: 'El nombre del producto es obligatorio');
      notifyListeners();
      return false;
    }

    if (cocinaCentralSeleccionada == null) {
      _model = _model.copyWith(error: 'Debes seleccionar una cocina central');
      notifyListeners();
      return false;
    }

    try {
      final precio = double.parse(precioController.text);
      if (precio <= 0) {
        _model = _model.copyWith(error: 'El precio debe ser mayor que cero');
        notifyListeners();
        return false;
      }
    } catch (e) {
      _model = _model.copyWith(error: 'El precio debe ser un número válido');
      notifyListeners();
      return false;
    }

    try {
      final impuestos = double.parse(impuestosController.text);
      if (impuestos < 0) {
        _model = _model.copyWith(
          error: 'Los impuestos no pueden ser negativos',
        );
        notifyListeners();
        return false;
      }
    } catch (e) {
      _model = _model.copyWith(
        error: 'Los impuestos deben ser un número válido',
      );
      notifyListeners();
      return false;
    }

    return true;
  }

  @override
  void dispose() {
    nombreController.dispose();
    descripcionController.dispose();
    precioController.dispose();
    impuestosController.dispose();
    unidadMedidaController.dispose();
    super.dispose();
  }
}
