import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:foodflow_app/features/warehouse/interactor/warehouse_interactor.dart';
import 'package:foodflow_app/core/services/event_bus_service.dart';

class ModifyByQRViewModel extends ChangeNotifier {
  final WarehouseInteractor _interactor = WarehouseInteractor();
  final EventBusService _eventBus = EventBusService();

  bool _isLoading = false;
  String? _error;
  bool _esSuma = true;
  int _cantidad = 1;
  bool _cameraActive = false;
  String? _productoQRScaneado;
  bool _operacionExitosa = false;
  StreamSubscription<String>? _dataChangedSubscription;
  Timer? _debounceTimer;

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get esSuma => _esSuma;
  int get cantidad => _cantidad;
  bool get cameraActive => _cameraActive;
  String? get productoQRScaneado => _productoQRScaneado;
  bool get operacionExitosa => _operacionExitosa;
  bool get puedeModificarInventario =>
      _interactor.tienePermisoParaModificarInventario();

  ModifyByQRViewModel() {
    _subscribeToEvents();
  }

  @override
  void dispose() {
    _dataChangedSubscription?.cancel();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _subscribeToEvents() {
    _dataChangedSubscription = _eventBus.dataChangedStream.listen((eventKey) {
      if (eventKey == 'inventory_update' ||
          eventKey == 'inventory_add' ||
          eventKey == 'inventory_add_user' ||
          eventKey == 'inventory_bulk_add' ||
          eventKey == 'product_create' ||
          eventKey == 'product_update' ||
          eventKey == 'responsive_scaffold_inventory_refresh' ||
          eventKey == 'responsive_scaffold_warehouse_refresh' ||
          eventKey == 'responsive_scaffold_all_refresh') {
        _debouncedRefrescarDatos();
      }
    });
  }

  void _debouncedRefrescarDatos() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _refrescarDatos();
    });
  }

  void _refrescarDatos() {
    notifyListeners();
  }

  void cambiarTipoOperacion(bool suma) {
    _esSuma = suma;
    notifyListeners();
  }

  void establecerCantidad(int cantidad) {
    if (cantidad > 0) {
      _cantidad = cantidad;
      notifyListeners();
    }
  }

  void activarCamara() {
    if (!puedeModificarInventario) {
      _error = 'No tienes permiso para modificar el inventario';
      notifyListeners();
      return;
    }

    if (_cantidad <= 0) {
      _error = 'Debes especificar una cantidad válida';
      notifyListeners();
      return;
    }

    _cameraActive = true;
    _error = null;
    notifyListeners();
  }

  void desactivarCamara() {
    _cameraActive = false;
    notifyListeners();
  }

  Future<bool> procesarCodigoQR(String codigoQR) async {
    if (!puedeModificarInventario) {
      _error = 'No tienes permiso para modificar el inventario';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    _productoQRScaneado = codigoQR;
    notifyListeners();

    try {
      final productoId = int.tryParse(codigoQR);
      if (kDebugMode) {
        print('Producto ID escaneado: $productoId');
      }

      if (productoId == null) {
        _error = 'Código QR inválido. No se pudo identificar el producto.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final resultado = await _interactor.actualizarStockPorQR(
        productoId,
        _cantidad,
        _esSuma,
      );

      _isLoading = false;

      if (resultado) {
        _operacionExitosa = true;
        _eventBus.publishDataChanged('qr_stock_update');
        notifyListeners();
        return true;
      } else {
        _error = 'No se pudo actualizar el stock del producto';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _error = 'Error: $e';
      notifyListeners();
      return false;
    }
  }

  void reiniciar() {
    _operacionExitosa = false;
    _productoQRScaneado = null;
    _error = null;
    notifyListeners();
  }
}
