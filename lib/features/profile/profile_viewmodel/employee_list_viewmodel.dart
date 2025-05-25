import 'package:flutter/material.dart';
import '../profile_interactor/profile_interactor.dart';
import '../profile_model/Profile_management_model.dart';
import 'package:foodflow_app/models/user_model.dart';

class EmployeeListViewModel extends ChangeNotifier {
  final ProfileInteractor _interactor = ProfileInteractor();

  bool _isLoading = false;
  String? _error;
  List<User> _employees = [];
  Map<int, Map<String, bool>> _employeePermissions = {};
  bool _permissionsChanged = false;
  final Set<int> _empleadosModificados =
      {}; // MODIFICADO: usar para filtrar PATCH

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<User> get employees => _employees;
  Map<int, Map<String, bool>> get employeePermissions => _employeePermissions;
  bool get permissionsChanged => _permissionsChanged;
  List<PermissionCategory> get categoriasPermisos =>
      _interactor.obtenerCategoriasPermisos();

  List<EmployeeItem> get employeesUI =>
      _employees
          .map(
            (user) => EmployeeItem(
              id: user.id,
              nombre: user.nombre,
              email: user.email,
              imagen: user.imagen,
            ),
          )
          .toList();

  EmployeeListViewModel() {
    cargarDatos();
  }

  Future<void> cargarDatos() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final empleados =
          await _interactor.obtenerEmpleados(); // ahora List<User>

      final Map<int, Map<String, bool>> permisosMap = {};
      for (var empleado in empleados) {
        final permisos = _interactor.obtenerPermisosEmpleado(empleado);
        if (permisos != null) {
          permisosMap[empleado.id] = permisos;
        }
      }

      _employees = empleados; // ahora es List<User>
      _employeePermissions = permisosMap;
      _permissionsChanged = false;
      _empleadosModificados.clear(); // limpiar modificados al cargar de nuevo
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
    _empleadosModificados.add(empleadoId); // MODIFICADO: marcar como cambiado
    notifyListeners();
  }

  Future<bool> guardarPermisosEmpleados() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      bool todoCorrecto = true;

      // MODIFICADO: solo guarda empleados modificados
      for (final empleadoId in _empleadosModificados) {
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
      _empleadosModificados.clear(); // limpiar modificados tras guardar

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

extension _IterableMap<K, V> on Iterable<MapEntry<K, V>?> {
  Map<K, V> toMap() {
    final map = <K, V>{};
    for (final e in this) {
      if (e != null) map[e.key] = e.value;
    }
    return map;
  }
}
