import 'dart:async';
import 'package:flutter/material.dart';
import 'package:foodflow_app/core/services/event_bus_service.dart';
import '../profile_interactor/profile_interactor.dart';
import '../profile_model/Profile_management_model.dart';
import 'package:foodflow_app/models/user_model.dart';

class EmployeeListViewModel extends ChangeNotifier {
  final ProfileInteractor _interactor = ProfileInteractor();
  final EventBusService _eventBus = EventBusService();

  bool _isLoading = false;
  String? _error;
  List<User> _employees = [];
  Map<int, Map<String, bool>> _employeePermissions = {};
  bool _permissionsChanged = false;
  final Set<int> _empleadosModificados = {};
  StreamSubscription<String>? _dataChangedSubscription;
  StreamSubscription<RefreshEvent>? _eventSubscription;

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
    _subscribeToEvents();
    _listenToEvents();
    cargarDatos();
  }

  @override
  void dispose() {
    _dataChangedSubscription?.cancel();
    _eventSubscription?.cancel();
    super.dispose();
  }

  void _listenToEvents() {
    _eventSubscription = _eventBus.stream.listen((event) {
      if (event.type == RefreshEventType.profile ||
          event.type == RefreshEventType.all) {
        cargarDatos();
      }
    });
  }

  void _subscribeToEvents() {
    _dataChangedSubscription = _eventBus.dataChangedStream.listen((eventKey) {
      if (eventKey == 'employee_updated' ||
          eventKey == 'employee_created' ||
          eventKey == 'employee_permissions_updated' ||
          eventKey == 'profile_updated') {
        cargarDatos();
      }
    });
  }

  Future<void> cargarDatos() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final empleados = await _interactor.obtenerEmpleados();

      final Map<int, Map<String, bool>> permisosMap = {};
      for (var empleado in empleados) {
        final permisos = _interactor.obtenerPermisosEmpleado(empleado);
        if (permisos != null) {
          permisosMap[empleado.id] = permisos;
        }
      }

      _employees = empleados;
      _employeePermissions = permisosMap;
      _permissionsChanged = false;
      _empleadosModificados.clear();
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
    _empleadosModificados.add(empleadoId);
    notifyListeners();
  }

  Future<bool> guardarPermisosEmpleados() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      bool todoCorrecto = true;

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
      _empleadosModificados.clear();

      if (!todoCorrecto) {
        _error = 'Error al guardar algunos permisos';
      } else {
        _eventBus.publishDataChanged('employee_permissions_updated');
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
