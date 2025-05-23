import 'package:flutter/material.dart';
import '../profile_interactor/profile_interactor.dart';
import '../profile_model/Profile_management_model.dart';

class EmployeeListViewModel extends ChangeNotifier {
  final ProfileInteractor _interactor = ProfileInteractor();

  bool _isLoading = false;
  String? _error;
  List<EmployeeItem> _employees = [];
  Map<int, Map<String, bool>> _employeePermissions = {};
  bool _permissionsChanged = false;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<EmployeeItem> get employees => _employees;
  Map<int, Map<String, bool>> get employeePermissions => _employeePermissions;
  bool get permissionsChanged => _permissionsChanged;
  List<PermissionCategory> get categoriasPermisos =>
      _interactor.obtenerCategoriasPermisos();
  final Set<int> _empleadosModificados = {};

  EmployeeListViewModel() {
    cargarDatos();
  }

  Future<void> cargarDatos() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final empleados = await _interactor.obtenerEmpleados();

      final Map<int, Map<String, bool>> permisosMap = {};
      for (var empleado in empleados) {
        final permisos = await _interactor.obtenerPermisosEmpleado(empleado.id);
        if (permisos != null) {
          permisosMap[empleado.id] = permisos;
        }
      }

      _employees = empleados;
      _employeePermissions = permisosMap;
      _permissionsChanged = false;
    } catch (e) {
      _error = 'Error al cargar empleados: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void cambiarPermisoEmpleado(
    int empleadoId,
    String permissionKey,
    bool value,
  ) {
    final permisoActual = _employeePermissions[empleadoId];
    if (permisoActual == null) return;

    final nuevosPermisos = Map<int, Map<String, bool>>.from(
      _employeePermissions,
    );
    nuevosPermisos[empleadoId] = Map<String, bool>.from(permisoActual);
    nuevosPermisos[empleadoId]![permissionKey] = value;

    _employeePermissions = nuevosPermisos;
    _permissionsChanged = true;
    notifyListeners();
  }

  Future<bool> guardarPermisosEmpleados() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      bool todoCorrecto = true;

      for (final empleadoId in _employeePermissions.keys) {
        final permisos = _employeePermissions[empleadoId]!;
        final exito = await _interactor.actualizarPermisosEmpleado(
          empleadoId,
          permisos,
        );

        if (!exito) {
          todoCorrecto = false;
        }
      }

      _permissionsChanged = false;

      if (!todoCorrecto) {
        _error = 'Error al guardar algunos permisos';
      }

      return todoCorrecto;
    } catch (e) {
      _error = 'Error al guardar permisos: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
