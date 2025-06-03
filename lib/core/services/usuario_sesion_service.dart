import 'package:shared_preferences/shared_preferences.dart';
import '../../models/permisos_empleado_model.dart';
import '../../models/user_model.dart';
import '../../models/auth_model.dart';
import 'package:flutter/foundation.dart';
import 'usuario_services.dart';

class UserSessionService {
  static final UserSessionService _instance = UserSessionService._internal();
  factory UserSessionService() => _instance;
  UserSessionService._internal();

  Auth? _auth;
  User? _user;
  PermisosEmpleado? _permisos;
  User? _propietario;

  PermisosEmpleado? get permisos => _permisos;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();

    final rememberMe = prefs.getBool(_rememberCredentialsKey) ?? false;

    if (rememberMe) {
      final accessToken = prefs.getString('access_token');
      final refreshToken = prefs.getString('refresh_token');

      if (accessToken != null && refreshToken != null) {
        _auth = Auth(accessToken: accessToken, refreshToken: refreshToken);
      }
    }

    final accessToken = prefs.getString('access_token');
    final refreshToken = prefs.getString('refresh_token');

    if (kDebugMode) {
      print('Inicializando UserSessionService');
      print('Token de acceso encontrado: ${accessToken != null}');
      print('Token de refresco encontrado: ${refreshToken != null}');
    }

    if (accessToken != null && refreshToken != null) {
      _auth = Auth(accessToken: accessToken, refreshToken: refreshToken);
    }

    final userId = prefs.getInt('user_id');
    final email = prefs.getString('email');
    final nombre = prefs.getString('nombre');
    final tipoUsuario = prefs.getString('tipo_usuario');

    if (userId != null &&
        email != null &&
        nombre != null &&
        tipoUsuario != null) {
      _user = User(
        id: userId,
        email: email,
        nombre: nombre,
        tipoUsuario: tipoUsuario,
      );

      if (kDebugMode) {
        print('Usuario recuperado del almacenamiento: ${_user?.toJson()}');
      }
    }

    if (_user?.tipoUsuario == 'empleado' && _user?.permisos != null) {
      _permisos = _user!.permisos;
    }

    if (kDebugMode) {
      print('¿Recordar usuario? $rememberMe');
    }
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email');

    await prefs.clear();

    if (email != null) {
      await prefs.setString('email', email);
    }

    _auth = null;
    _user = null;
    _permisos = null;
    _propietario = null;
  }

  static const String _rememberCredentialsKey = 'remember_credentials';

  Future<bool> getRememberCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_rememberCredentialsKey) ?? false;
  }

  Future<void> setRememberCredentials(bool remember) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_rememberCredentialsKey, remember);
  }

  Future<void> saveSession(
    Auth auth,
    User user, {
    bool rememberMe = false,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString("access_token", auth.accessToken);
    await prefs.setString("refresh_token", auth.refreshToken);

    await prefs.setInt("user_id", user.id);
    await prefs.setString("email", user.email);
    await prefs.setString("nombre", user.nombre);
    await prefs.setString("tipo_usuario", user.tipoUsuario);

    rememberMe = await prefs.getBool(_rememberCredentialsKey) ?? false;
    await prefs.setBool(_rememberCredentialsKey, rememberMe);

    if (kDebugMode) {
      print('Guardando sesión con rememberMe = $rememberMe');
      final savedValue = prefs.getBool(_rememberCredentialsKey);
      print('Valor de rememberMe guardado: $savedValue');
    }

    _auth = auth;
    _user = user;

    if (user.tipoUsuario == 'empleado' && user.permisos != null) {
      _permisos = user.permisos;
      await guardarPermisos(user.permisos!);
    }
  }

  String? get token => _auth?.accessToken;
  String? get refreshToken => _auth?.refreshToken;
  User? get user => _user;

  bool get isLoggedIn => _auth != null && _user != null;

  Future<void> actualizarDatosUsuario(User user) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt("user_id", user.id);
    await prefs.setString("email", user.email);
    await prefs.setString("nombre", user.nombre);
    await prefs.setString("tipo_usuario", user.tipoUsuario);

    if (user.direccion != null) {
      await prefs.setString("direccion", user.direccion!);
    }
    if (user.telefono != null) {
      await prefs.setString("telefono", user.telefono!);
    }
    if (user.fechaCreacion != null) {
      await prefs.setString("fecha_creacion", user.fechaCreacion!);
    }
    await prefs.setBool("is_active", user.isActive);
    await prefs.setBool("is_staff", user.isStaff);
    await prefs.setBool("is_superuser", user.isSuperuser);
    if (user.empresaAsociada != null) {
      await prefs.setString("empresa_asociada", user.empresaAsociada!);
    }
    if (user.imagen != null) await prefs.setString("imagen", user.imagen!);
    if (user.propietarioId != null) {
      await prefs.setInt("propietario_id", user.propietarioId!);
    }

    _user = user;

    if (user.tipoUsuario == 'empleado' && user.permisos != null) {
      _permisos = user.permisos;
      await guardarPermisos(user.permisos!);
    }
  }

  Future<void> guardarPermisos(PermisosEmpleado permisos) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt("permisos_id", permisos.id);

    await prefs.setBool("puede_ver_productos", permisos.puedeVerProductos);
    await prefs.setBool("puede_crear_productos", permisos.puedeCrearProductos);
    await prefs.setBool(
      "puede_editar_productos",
      permisos.puedeEditarProductos,
    );
    await prefs.setBool(
      "puede_desactivar_productos",
      permisos.puedeDesactivarProductos,
    );
    await prefs.setBool(
      "puede_ver_historial_producto",
      permisos.puedeVerHistorialProducto,
    );
    await prefs.setBool("puede_ver_usuarios", permisos.puedeVerUsuarios);
    await prefs.setBool("puede_crear_usuarios", permisos.puedeCrearUsuarios);
    await prefs.setBool("puede_editar_usuarios", permisos.puedeEditarUsuarios);
    await prefs.setBool(
      "puede_eliminar_usuarios",
      permisos.puedeEliminarUsuarios,
    );
    await prefs.setBool("puede_ver_almacenes", permisos.puedeVerAlmacenes);
    await prefs.setBool("puede_crear_almacenes", permisos.puedeCrearAlmacenes);
    await prefs.setBool(
      "puede_modificar_almacenes",
      permisos.puedeModificarAlmacenes,
    );
    await prefs.setBool("puede_ver_pedidos", permisos.puedeVerPedidos);
    await prefs.setBool("puede_crear_pedidos", permisos.puedeCrearPedidos);
    await prefs.setBool("puede_editar_pedidos", permisos.puedeEditarPedidos);
    await prefs.setBool("puede_ver_incidencias", permisos.puedeVerIncidencias);
    await prefs.setBool(
      "puede_crear_incidencias",
      permisos.puedeCrearIncidencias,
    );
    await prefs.setBool(
      "puede_ver_pedidoProducto",
      permisos.puedeVerPedidoProducto,
    );
    await prefs.setBool(
      "puede_crear_pedidoProducto",
      permisos.puedeCrearPedidoProducto,
    );
    await prefs.setBool(
      "puede_editar_pedidoProducto",
      permisos.puedeEditarPedidoProducto,
    );
    await prefs.setBool(
      "puede_eliminar_pedidoProducto",
      permisos.puedeEliminarPedidoProducto,
    );
    await prefs.setBool("puede_ver_metricas", permisos.puedeVerMetricas);
    await prefs.setBool(
      "puede_ver_prevision_demanda",
      permisos.puedeVerPrevisionDemanda,
    );

    _permisos = permisos;
  }

  Future<void> updateTokens(Auth auth) async {
    final prefs = await SharedPreferences.getInstance();

    if (kDebugMode) {
      print('Actualizando tokens: ${auth.toJson()}');
    }

    await prefs.setString("access_token", auth.accessToken);
    await prefs.setString("refresh_token", auth.refreshToken);

    _auth = auth;

    if (kDebugMode) {
      print('Tokens actualizados correctamente');
    }
  }

  Future<User?> obtenerPropietario() async {
    try {
      if (_user == null || _user!.propietarioId == null) {
        return null;
      }

      if (_propietario != null && _propietario!.id == _user!.propietarioId) {
        return _propietario;
      }

      final prefs = await SharedPreferences.getInstance();
      final propietarioId = _user!.propietarioId!;

      final userService = UserService();
      final usuarios = await userService.obtenerTodosLosUsuarios();
      final propietarioData =
          usuarios.where((user) => user.id == propietarioId).isNotEmpty
              ? usuarios.firstWhere((user) => user.id == propietarioId)
              : null;

      if (propietarioData != null) {
        _propietario = propietarioData;
        await prefs.setString('propietario_nombre', propietarioData.nombre);
        await prefs.setString('propietario_email', propietarioData.email);
        await prefs.setString(
          'propietario_tipo_usuario',
          propietarioData.tipoUsuario,
        );
        return _propietario;
      }

      final nombre = prefs.getString('propietario_nombre');
      final email = prefs.getString('propietario_email');
      final tipoUsuario = prefs.getString('propietario_tipo_usuario');

      if (nombre != null && email != null && tipoUsuario != null) {
        _propietario = User(
          id: propietarioId,
          nombre: nombre,
          email: email,
          tipoUsuario: tipoUsuario,
        );
        return _propietario;
      }

      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error al obtener datos del propietario: $e');
      }

      final prefs = await SharedPreferences.getInstance();
      final propietarioId = _user?.propietarioId;

      if (propietarioId != null) {
        final nombre = prefs.getString('propietario_nombre');
        final email = prefs.getString('propietario_email');
        final tipoUsuario = prefs.getString('propietario_tipo_usuario');

        if (nombre != null && email != null && tipoUsuario != null) {
          _propietario = User(
            id: propietarioId,
            nombre: nombre,
            email: email,
            tipoUsuario: tipoUsuario,
          );
          return _propietario;
        }
      }

      return null;
    }
  }

  Future<void> guardarDatosPropietario(User propietario) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('propietario_nombre', propietario.nombre);
    await prefs.setString('propietario_email', propietario.email);
    await prefs.setString('propietario_tipo_usuario', propietario.tipoUsuario);
    _propietario = propietario;
  }
}
