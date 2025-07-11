import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:foodflow_app/core/services/event_bus_service.dart';
import 'package:foodflow_app/features/products/products_interactor/products_interactor.dart';
import 'package:foodflow_app/features/products/products_model/products_model.dart';
import 'package:foodflow_app/models/categoria_model.dart';
import 'package:foodflow_app/models/producto_model.dart';
import 'package:foodflow_app/models/user_model.dart';
import 'package:image_picker/image_picker.dart';

class ProductFormViewModel extends ChangeNotifier {
  final ProductsInteractor _interactor = ProductsInteractor();
  final EventBusService _eventBus = EventBusService();

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

  Categoria? categoriaSeleccionada;
  bool productoActivo = true;

  File? imagenSeleccionada;
  String? imagenUrl;
  bool _imagenEliminada = false;

  List<User> cocinasCentrales = [];
  User? cocinaCentralSeleccionada;

  List<Categoria> categorias = [];
  bool _categoriasLoading = false;
  bool get categoriasLoading => _categoriasLoading;

  bool get isEditMode => _model.productoSeleccionado != null;

  bool get puedeEditarDatosBasicos {
    if (!isEditMode) return true;
    final tipoUsuario = _interactor.obtenerTipoUsuario();
    return tipoUsuario == 'administrador';
  }

  bool get puedeEditarImagen {
    final tipoUsuario = _interactor.obtenerTipoUsuario();
    return tipoUsuario == 'administrador' ||
        tipoUsuario == 'cocina_central' ||
        (tipoUsuario == 'empleado' && _interactor.puedeCrearEditarProductos());
  }

  bool get puedeEditarEstado {
    final tipoUsuario = _interactor.obtenerTipoUsuario();
    return tipoUsuario == 'administrador' ||
        tipoUsuario == 'cocina_central' ||
        (tipoUsuario == 'empleado' && _interactor.puedeCrearEditarProductos());
  }

  bool get puedeSeleccionarCocinaCentral {
    final tipoUsuario = _interactor.obtenerTipoUsuario();
    return tipoUsuario == 'administrador';
  }

  ProductFormViewModel() {
    _cargarCocinasCentrales();
    _cargarCategorias();
  }

  Future<void> cargarProducto(int productoId) async {
    _model = _model.copyWith(isLoading: true, error: null);
    notifyListeners();

    try {
      final productoModel = await _interactor.obtenerProductoDetalle(
        productoId,
      );
      final producto = productoModel.productoSeleccionado;

      if (producto != null) {
        await _cargarCategorias();

        _model = _model.copyWith(
          isLoading: false,
          productoSeleccionado: producto,
        );

        nombreController.text = producto.nombre;
        descripcionController.text = producto.descripcion ?? '';
        precioController.text = producto.precio.toString();
        impuestosController.text = producto.impuestos.toString();
        unidadMedidaController.text = producto.unidadMedida;
        productoActivo = producto.isActive;
        imagenUrl = producto.imagenUrl;
        _imagenEliminada = false;

        if (producto.categoria != null) {
          categoriaSeleccionada = categorias.firstWhere(
            (cat) => cat.id == producto.categoria!.id,
            orElse: () => producto.categoria!,
          );
        }

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
      final cocinasModel = await _interactor.obtenerCocinaCentrales();
      cocinasCentrales = cocinasModel.cocinas ?? [];
      if (cocinasCentrales.isNotEmpty) {
        cocinaCentralSeleccionada = cocinasCentrales.first;
      }
      notifyListeners();
    } catch (e) {
      _model = _model.copyWith(error: 'Error al cargar cocinas centrales: $e');
      notifyListeners();
    }
  }

  Future<void> _cargarCategorias() async {
    _categoriasLoading = true;
    notifyListeners();

    try {
      categorias = await _interactor.obtenerCategorias();
      _categoriasLoading = false;
      notifyListeners();
    } catch (e) {
      _categoriasLoading = false;
      _model = _model.copyWith(error: 'Error al cargar categorías: $e');
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
      _imagenEliminada = false;
      notifyListeners();
    }
  }

  void eliminarImagen() {
    imagenSeleccionada = null;
    _imagenEliminada = true;
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
        'nombre': nombreController.text.trim(),
        'descripcion': descripcionController.text.trim(),
        'precio': precioController.text,
        'impuestos': impuestosController.text,
        'unidad_medida': unidadMedidaController.text.trim(),
        'is_active': productoActivo,
        'categoria': categoriaSeleccionada?.id,
        'cocina_central': cocinaCentralSeleccionada?.id,
      };

      if (double.tryParse(precioController.text) != null) {
        datos['precio'] = double.parse(precioController.text).toString();
      }

      if (double.tryParse(impuestosController.text) != null) {
        datos['impuestos'] = double.parse(impuestosController.text).toString();
      }

      // Aseguramos que los campos null se envíen explícitamente
      if (datos['categoria'] == null) {
        datos['categoria'] = null;
      }

      if (datos['cocina_central'] == null) {
        datos['cocina_central'] = null;
      }

      if (_imagenEliminada && imagenSeleccionada == null) {
        datos['eliminar_imagen'] = true;
      }

      if (kDebugMode) {
        print('Datos a enviar: $datos');
      }

      bool resultado;
      if (_model.productoSeleccionado == null) {
        resultado = await _interactor.crearProducto(datos, imagenSeleccionada);
        if (resultado) {
          _eventBus.publishDataChanged('product_create');
        }
      } else {
        resultado = await _interactor.actualizarProducto(
          _model.productoSeleccionado!.id,
          Map<String, dynamic>.from(datos),
          imagenSeleccionada,
        );
        if (resultado) {
          _eventBus.publishDataChanged('product_update');
        }
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

  String? obtenerImagenUrlConTimestamp() {
    if (imagenSeleccionada != null) {
      return null;
    }

    if (_imagenEliminada) {
      return null;
    }

    if (imagenUrl != null && imagenUrl!.isNotEmpty) {
      return '$imagenUrl?v=${DateTime.now().millisecondsSinceEpoch}';
    }

    return null;
  }

  Future<void> refrescarProducto() async {
    if (_model.productoSeleccionado?.id != null) {
      await cargarProducto(_model.productoSeleccionado!.id);
    }
  }

  void limpiarError() {
    _model = _model.copyWith(error: null);
    notifyListeners();
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
