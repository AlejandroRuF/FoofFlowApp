import 'dart:io';
import 'package:flutter/material.dart';
import 'package:foodflow_app/models/user_model.dart';
import 'package:image_picker/image_picker.dart';
import '../profile_interactor/profile_interactor.dart';
import '../profile_model/Profile_management_model.dart';

class ProfileViewModel extends ChangeNotifier {
  final ProfileInteractor _interactor = ProfileInteractor();
  ProfileModel _state = ProfileModel();
  final Set<int> _empleadosModificados = {}; // MODIFICADO

  ProfileViewModel() {
    _inicializar();
  }

  ProfileModel get state => _state;
  User? get usuario => _interactor.obtenerUsuarioActual();

  List<PermissionCategory> get categoriasPermisos =>
      _interactor.obtenerCategoriasPermisos();

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
      final empleados = await _interactor.obtenerEmpleados(); // List<User>

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
      _empleadosModificados
          .clear(); // MODIFICADO: limpiar modificados al cargar
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
    );
    notifyListeners();
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

  Future<bool> guardarDatosUsuario(Map<String, dynamic> datos) async {
    if (usuario == null) return false;

    _actualizarEstado(isSaving: true, error: null);

    try {
      final exito = await _interactor.actualizarUsuario(usuario!.id, datos);

      _actualizarEstado(
        isSaving: false,
        isEditMode: false,
        error: exito ? null : 'Error al guardar datos del usuario',
      );

      return exito;
    } catch (e) {
      _actualizarEstado(isSaving: false, error: 'Error al guardar datos: $e');
      return false;
    }
  }

  Future<bool> cambiarPassword(
    String currentPassword,
    String newPassword,
  ) async {
    if (usuario == null) return false;

    _actualizarEstado(isSaving: true, error: null);

    try {
      final exito = await _interactor.cambiarPassword(
        usuario!.id,
        currentPassword,
        newPassword,
      );

      _actualizarEstado(
        isSaving: false,
        isPasswordChangeMode: false,
        error: exito ? null : 'Error al cambiar la contraseña',
      );

      return exito;
    } catch (e) {
      _actualizarEstado(
        isSaving: false,
        error: 'Error al cambiar contraseña: $e',
      );
      return false;
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

    _empleadosModificados.add(
      empleadoId,
    ); // MODIFICADO: marcar empleado modificado
    _actualizarEstado(
      employeePermissions: nuevosPermisos,
      permissionsChanged: true,
    );
  }

  Future<bool> guardarPermisosEmpleados() async {
    _actualizarEstado(isSaving: true, error: null);

    try {
      bool todoCorrecto = true;

      // MODIFICADO: solo guarda empleados modificados
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

      _empleadosModificados.clear(); // limpiar modificados tras guardar

      _actualizarEstado(
        isSaving: false,
        permissionsChanged: false,
        error: todoCorrecto ? null : 'Error al guardar algunos permisos',
      );

      return todoCorrecto;
    } catch (e) {
      _actualizarEstado(
        isSaving: false,
        error: 'Error al guardar permisos: $e',
      );
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
