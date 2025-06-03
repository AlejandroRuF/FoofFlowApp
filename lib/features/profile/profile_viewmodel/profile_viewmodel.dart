import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:foodflow_app/models/user_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:foodflow_app/core/services/event_bus_service.dart';
import '../../auth/login/login_viewmodel/login_viewmodel.dart';
import '../profile_interactor/profile_interactor.dart';
import '../profile_model/Profile_management_model.dart';

class ProfileViewModel extends ChangeNotifier {
  final ProfileInteractor _interactor = ProfileInteractor();
  final LoginViewModel _loginViewModel = LoginViewModel();
  final EventBusService _eventBus = EventBusService();
  ProfileModel _state = ProfileModel();
  final Set<int> _empleadosModificados = {};
  StreamSubscription<String>? _dataChangedSubscription;
  StreamSubscription<RefreshEvent>? _eventSubscription;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController telefonoController = TextEditingController();
  final TextEditingController direccionController = TextEditingController();

  ProfileViewModel() {
    _subscribeToEvents();
    _listenToEvents();
    _inicializar();
  }

  ProfileModel get state => _state;
  User? get usuario => _interactor.obtenerUsuarioActual();

  List<PermissionCategory> get categoriasPermisos =>
      _interactor.obtenerCategoriasPermisos();

  Map<String, bool> get newEmployeePermissions => _state.newEmployeePermissions;

  @override
  void dispose() {
    _dataChangedSubscription?.cancel();
    _eventSubscription?.cancel();
    nombreController.dispose();
    emailController.dispose();
    passwordController.dispose();
    telefonoController.dispose();
    direccionController.dispose();
    super.dispose();
  }

  void _listenToEvents() {
    _eventSubscription = _eventBus.stream.listen((event) {
      if (event.type == RefreshEventType.profile ||
          event.type == RefreshEventType.all) {
        _cargarDatos();
      }
    });
  }

  void _subscribeToEvents() {
    _dataChangedSubscription = _eventBus.dataChangedStream.listen((eventKey) {
      if (eventKey == 'employee_updated' ||
          eventKey == 'employee_created' ||
          eventKey == 'employee_permissions_updated' ||
          eventKey == 'profile_updated') {
        _cargarDatos();
      }
    });
  }

  Future<void> _inicializar() async {
    _actualizarEstado(isLoading: true);
    await _cargarDatos();
    _actualizarEstado(isLoading: false);
  }

  Future<void> _cargarDatos() async {
    try {
      final esResponsable = _interactor.esResponsable();
      if (esResponsable) {
        await _cargarEmpleados();
      }
      _actualizarEstado(hasPermissionEmployees: esResponsable);
    } catch (e) {
      _actualizarEstado(error: 'Error al cargar datos: $e');
    }
  }

  Future<void> _cargarEmpleados() async {
    try {
      final empleados = await _interactor.obtenerEmpleados();

      final Map<int, Map<String, bool>> permisosMap = {};
      for (var empleado in empleados) {
        final permisos = _interactor.obtenerPermisosEmpleado(empleado);
        if (permisos != null) {
          permisosMap[empleado.id] = permisos;
        }
      }

      final empleadosUI =
          empleados
              .map(
                (user) => EmployeeItem(
                  id: user.id,
                  nombre: user.nombre,
                  email: user.email,
                  imagen: user.imagen,
                ),
              )
              .toList();

      _actualizarEstado(
        employees: empleadosUI,
        employeePermissions: permisosMap,
        permissionsChanged: false,
      );
      _empleadosModificados.clear();
    } catch (e) {
      _actualizarEstado(error: 'Error al cargar empleados: $e');
    }
  }

  void _actualizarEstado({
    bool? isLoading,
    String? error,
    bool? isEditMode,
    bool? isPasswordChangeMode,
    bool? isImagePickerActive,
    String? imagePath,
    bool? isSaving,
    bool? hasPermissionEmployees,
    List<EmployeeItem>? employees,
    Map<int, Map<String, bool>>? employeePermissions,
    bool? permissionsChanged,
    bool? isCreatingEmployee,
    Map<String, bool>? newEmployeePermissions,
  }) {
    _state = _state.copyWith(
      isLoading: isLoading,
      error: error,
      isEditMode: isEditMode,
      isPasswordChangeMode: isPasswordChangeMode,
      isImagePickerActive: isImagePickerActive,
      imagePath: imagePath,
      isSaving: isSaving,
      hasPermissionEmployees: hasPermissionEmployees,
      employees: employees,
      employeePermissions: employeePermissions,
      permissionsChanged: permissionsChanged,
      isCreatingEmployee: isCreatingEmployee,
      newEmployeePermissions: newEmployeePermissions,
    );
    notifyListeners();
  }

  void iniciarCreacionEmpleado() {
    _limpiarFormulario();
    _actualizarEstado(isCreatingEmployee: true, newEmployeePermissions: {});
  }

  void cancelarCreacionEmpleado() {
    _limpiarFormulario();
    _actualizarEstado(isCreatingEmployee: false, newEmployeePermissions: {});
  }

  void _limpiarFormulario() {
    nombreController.clear();
    emailController.clear();
    passwordController.clear();
    telefonoController.clear();
    direccionController.clear();
  }

  void cambiarPermisoNuevoEmpleado(String permissionKey, bool value) {
    final nuevosPermisos = Map<String, bool>.from(
      _state.newEmployeePermissions,
    );
    nuevosPermisos[permissionKey] = value;
    _actualizarEstado(newEmployeePermissions: nuevosPermisos);
  }

  Future<bool> crearEmpleado() async {
    _actualizarEstado(isSaving: true, error: null);

    try {
      final datosEmpleado = {
        'nombre': nombreController.text.trim(),
        'email': emailController.text.trim(),
        'password': passwordController.text.trim(),
        'telefono': telefonoController.text.trim(),
        'direccion': direccionController.text.trim(),
        'tipo_usuario': 'empleado',
      };

      final empleadoCreado = await _interactor.crearEmpleado(datosEmpleado);

      if (empleadoCreado != null) {
        if (_state.newEmployeePermissions.isNotEmpty) {
          await _interactor.actualizarPermisosEmpleado(
            empleadoCreado.id,
            _state.newEmployeePermissions,
          );
        }

        await _cargarEmpleados();
        cancelarCreacionEmpleado();
        _eventBus.publishDataChanged('employee_created');

        _actualizarEstado(isSaving: false);
        return true;
      } else {
        _actualizarEstado(isSaving: false, error: 'Error al crear el empleado');
        return false;
      }
    } catch (e) {
      _actualizarEstado(isSaving: false, error: 'Error al crear empleado: $e');
      return false;
    }
  }

  void activarModoEdicion() {
    _actualizarEstado(isEditMode: true);
  }

  void desactivarModoEdicion() {
    _actualizarEstado(isEditMode: false);
  }

  void activarModoPassword() {
    _actualizarEstado(isPasswordChangeMode: true);
  }

  void desactivarModoPassword() {
    _actualizarEstado(isPasswordChangeMode: false);
  }

  void mostrarSelectorImagen() {
    _actualizarEstado(isImagePickerActive: true);
  }

  void ocultarSelectorImagen() {
    _actualizarEstado(isImagePickerActive: false);
  }

  Future<void> seleccionarImagen(ImageSource source) async {
    ocultarSelectorImagen();
    final imagen = await _interactor.obtenerImagen(source);
    if (imagen != null) {
      _actualizarEstado(imagePath: imagen.path);
    }
  }

  Future<bool> actualizarPerfilCompleto(
    Map<String, dynamic> datos,
    String? imagePath,
  ) async {
    if (usuario == null) return false;

    _actualizarEstado(isSaving: true, error: null);

    try {
      bool exito = true;

      if (imagePath != null) {
        final imagenUrl = await _interactor.subirImagenPerfil(
          usuario!.id,
          File(imagePath),
        );

        if (imagenUrl == null) {
          _actualizarEstado(isSaving: false, error: 'Error al subir la imagen');
          return false;
        }
      }

      if (datos.isNotEmpty) {
        exito = await _interactor.actualizarUsuario(usuario!.id, datos);
      }

      _actualizarEstado(
        isSaving: false,
        isEditMode: false,
        imagePath: null,
        error: exito ? null : 'Error al guardar datos del usuario',
      );

      if (exito) {
        _eventBus.publishDataChanged('profile_updated');
      }

      return exito;
    } catch (e) {
      _actualizarEstado(isSaving: false, error: 'Error al guardar datos: $e');
      return false;
    }
  }

  Future<bool> guardarDatosUsuario(Map<String, dynamic> datos) async {
    return await actualizarPerfilCompleto(datos, state.imagePath);
  }

  Future<Map<String, dynamic>> cambiarPassword(
    String currentPassword,
    String newPassword,
  ) async {
    if (usuario == null) {
      return {'success': false, 'shouldNavigateToLogin': false};
    }

    _actualizarEstado(isSaving: true, error: null);

    try {
      final exito = await _interactor.cambiarPassword(
        usuario!.id,
        currentPassword,
        newPassword,
      );

      if (exito) {
        final success = await _loginViewModel.logout();
        if (!success) {
          _actualizarEstado(
            isSaving: false,
            error: 'Error al cerrar sesión después del cambio de contraseña',
          );
          return {'success': false, 'shouldNavigateToLogin': false};
        }

        _actualizarEstado(
          isSaving: false,
          isPasswordChangeMode: false,
          error: null,
        );

        return {'success': true, 'shouldNavigateToLogin': true};
      }

      _actualizarEstado(
        isSaving: false,
        isPasswordChangeMode: false,
        error: 'Error al cambiar la contraseña',
      );

      return {'success': false, 'shouldNavigateToLogin': false};
    } catch (e) {
      _actualizarEstado(
        isSaving: false,
        error: 'Error al cambiar contraseña: $e',
      );
      return {'success': false, 'shouldNavigateToLogin': false};
    }
  }

  Future<bool> subirImagenPerfil() async {
    if (usuario == null || state.imagePath == null) return false;

    _actualizarEstado(isSaving: true, error: null);

    try {
      final imagen = File(state.imagePath!);
      final nuevaUrl = await _interactor.subirImagenPerfil(usuario!.id, imagen);

      final exito = nuevaUrl != null;

      _actualizarEstado(
        isSaving: false,
        imagePath: null,
        error: exito ? null : 'Error al subir imagen',
      );

      if (exito) {
        _eventBus.publishDataChanged('profile_updated');
      }

      return exito;
    } catch (e) {
      _actualizarEstado(isSaving: false, error: 'Error al subir imagen: $e');
      return false;
    }
  }

  void cambiarPermisoEmpleado(
    int empleadoId,
    String permissionKey,
    bool value,
  ) {
    final permisoActual = state.employeePermissions[empleadoId];
    if (permisoActual == null) return;

    final nuevosPermisos = Map<int, Map<String, bool>>.from(
      state.employeePermissions,
    );
    nuevosPermisos[empleadoId] = Map<String, bool>.from(permisoActual);
    nuevosPermisos[empleadoId]![permissionKey] = value;

    _empleadosModificados.add(empleadoId);
    _actualizarEstado(
      employeePermissions: nuevosPermisos,
      permissionsChanged: true,
    );
  }

  Future<bool> guardarPermisosEmpleados() async {
    _actualizarEstado(isSaving: true, error: null);

    try {
      bool todoCorrecto = true;

      for (final empleadoId in _empleadosModificados) {
        final permisos = state.employeePermissions[empleadoId]!;
        final exito = await _interactor.actualizarPermisosEmpleado(
          empleadoId,
          permisos,
        );

        if (!exito) {
          todoCorrecto = false;
        }
      }

      _empleadosModificados.clear();

      _actualizarEstado(
        isSaving: false,
        permissionsChanged: false,
        error: todoCorrecto ? null : 'Error al guardar algunos permisos',
      );

      if (todoCorrecto) {
        _eventBus.publishDataChanged('employee_permissions_updated');
      }

      return todoCorrecto;
    } catch (e) {
      _actualizarEstado(
        isSaving: false,
        error: 'Error al guardar permisos: $e',
      );
      return false;
    }
  }

  Future<bool> cerrarSesionDirecto() async {
    _actualizarEstado(isSaving: true, error: null);

    try {
      final success = await _loginViewModel.logout();

      _actualizarEstado(
        isSaving: false,
        error: success ? null : 'Error al cerrar sesión',
      );

      return success;
    } catch (e) {
      _actualizarEstado(isSaving: false, error: 'Error al cerrar sesión: $e');
      return false;
    }
  }

  void refrescarDatos() {
    _inicializar();
  }

  void resetImagePath() {
    _actualizarEstado(imagePath: null);
  }

  Future<bool> solicitarCambioPassword(String email) async {
    _actualizarEstado(isSaving: true, error: null);

    try {
      final exito = await _interactor.solicitarRestablecerPassword(email);
      final logout = await _loginViewModel.logout();

      _actualizarEstado(
        isSaving: false,
        isPasswordChangeMode: false,
        error: exito ? null : 'Error al solicitar cambio de contraseña',
      );

      return exito;
    } catch (e) {
      _actualizarEstado(
        isSaving: false,
        error: 'Error al solicitar cambio de contraseña: $e',
      );
      return false;
    }
  }
}
