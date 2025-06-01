import 'package:flutter/material.dart';
import 'package:foodflow_app/features/incidents/incidents_model/incidents_model.dart';
import 'package:foodflow_app/models/incidencia_model.dart';

import '../incidents_interactor/incidents_interactor.dart';

class IncidentDetailViewModel extends ChangeNotifier {
  final IncidentsInteractor _interactor = IncidentsInteractor();

  IncidentsModel _model = IncidentsModel();

  Incidencia? get incidencia => _model.incidenciaSeleccionada;
  bool get isLoading => _model.isLoading;
  String? get error => _model.error;

  bool get puedeGestionarIncidencia {
    final tipoUsuario = _interactor.obtenerTipoUsuario();
    return tipoUsuario == 'administrador' || tipoUsuario == 'cocina_central';
  }

  Future<void> cargarIncidenciaDetalle(int incidenciaId) async {
    _model = _model.copyWith(isLoading: true, error: null);
    notifyListeners();

    try {
      final resultado = await _interactor.obtenerIncidenciaDetalle(
        incidenciaId,
      );
      _model = resultado.copyWith(isLoading: false);
      notifyListeners();
    } catch (e) {
      _model = _model.copyWith(
        isLoading: false,
        error: 'Error al cargar detalle de la incidencia: $e',
      );
      notifyListeners();
    }
  }

  Future<bool> resolverIncidencia() async {
    if (_model.incidenciaSeleccionada == null) return false;

    _model = _model.copyWith(isLoading: true, error: null);
    notifyListeners();

    try {
      final resultado = await _interactor.resolverIncidencia(
        _model.incidenciaSeleccionada!.id,
      );
      if (resultado) {
        await cargarIncidenciaDetalle(_model.incidenciaSeleccionada!.id);
      } else {
        _model = _model.copyWith(
          isLoading: false,
          error: 'Error al resolver la incidencia',
        );
        notifyListeners();
      }
      return resultado;
    } catch (e) {
      _model = _model.copyWith(
        isLoading: false,
        error: 'Error al resolver la incidencia: $e',
      );
      notifyListeners();
      return false;
    }
  }

  Future<bool> cancelarIncidencia() async {
    if (_model.incidenciaSeleccionada == null) return false;

    _model = _model.copyWith(isLoading: true, error: null);
    notifyListeners();

    try {
      final resultado = await _interactor.cancelarIncidencia(
        _model.incidenciaSeleccionada!.id,
      );
      if (resultado) {
        await cargarIncidenciaDetalle(_model.incidenciaSeleccionada!.id);
      } else {
        _model = _model.copyWith(
          isLoading: false,
          error: 'Error al cancelar la incidencia',
        );
        notifyListeners();
      }
      return resultado;
    } catch (e) {
      _model = _model.copyWith(
        isLoading: false,
        error: 'Error al cancelar la incidencia: $e',
      );
      notifyListeners();
      return false;
    }
  }
}
