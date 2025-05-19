import 'package:shared_preferences/shared_preferences.dart';
import '../../models/permisos_empleado_model.dart';
import '../../models/user_model.dart';
import '../../models/auth_model.dart';
import 'package:flutter/foundation.dart';

class UserSessionService {
  static final UserSessionService _instance = UserSessionService._internal();
  factory UserSessionService() => _instance;
  UserSessionService._internal();

  Auth? _auth;
  User? _user;
  PermisosEmpleado? _permisos;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();

    final rememberMe = prefs.getBool(_rememberCredentialsKey) ?? false;


    if (rememberMe) {
      final accessToken = prefs.getString('access_token');
      final refreshToken = prefs.getString('refresh_token');

      if (accessToken != null && refreshToken != null) {
        _auth = Auth(accessToken: accessToken, refreshToken: refreshToken);
      }

    } else {
      await prefs.clear();
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
    
    if (userId != null && email != null && nombre != null && tipoUsuario != null) {
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

    if (kDebugMode) {
      print('¿Recordar usuario? $rememberMe');
    }
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    _auth = null;
    _user = null;
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

Future<void> saveSession(Auth auth, User user, {bool rememberMe = false}) async {
  final prefs = await SharedPreferences.getInstance();

  await prefs.setString("access_token", auth.accessToken);
  await prefs.setString("refresh_token", auth.refreshToken);
  
  await prefs.setInt("user_id", user.id);
  await prefs.setString("email", user.email);
  await prefs.setString("nombre", user.nombre);
  await prefs.setString("tipo_usuario", user.tipoUsuario);
  
  await prefs.setBool(_rememberCredentialsKey, rememberMe);
  
  if (kDebugMode) {
    print('Guardando sesión con rememberMe = $rememberMe');
    final savedValue = prefs.getBool(_rememberCredentialsKey);
    print('Valor de rememberMe guardado: $savedValue');
  }

  _auth = auth;
  _user = user;
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
    
    if (user.direccion != null) await prefs.setString("direccion", user.direccion!);
    if (user.telefono != null) await prefs.setString("telefono", user.telefono!);
    if (user.fechaCreacion != null) await prefs.setString("fecha_creacion", user.fechaCreacion!);
    await prefs.setBool("is_active", user.isActive);
    await prefs.setBool("is_staff", user.isStaff);
    await prefs.setBool("is_superuser", user.isSuperuser);
    if (user.empresaAsociada != null) await prefs.setString("empresa_asociada", user.empresaAsociada!);
    if (user.imagen != null) await prefs.setString("imagen", user.imagen!);
    if (user.propietarioId != null) await prefs.setInt("propietario_id", user.propietarioId!);
    
    _user = user;
  }

  Future<void> guardarPermisos(PermisosEmpleado permisos) async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setInt("permisos_id", permisos.id);
    
    await prefs.setBool("puede_ver_productos", permisos.puedeVerProductos);
    await prefs.setBool("puede_crear_productos", permisos.puedeCrearProductos);
    await prefs.setBool("puede_editar_productos", permisos.puedeEditarProductos);
    await prefs.setBool("puede_desactivar_productos", permisos.puedeDesactivarProductos);
    await prefs.setBool("puede_ver_historial_producto", permisos.puedeVerHistorialProducto);
    await prefs.setBool("puede_ver_usuarios", permisos.puedeVerUsuarios);
    await prefs.setBool("puede_crear_usuarios", permisos.puedeCrearUsuarios);
    await prefs.setBool("puede_editar_usuarios", permisos.puedeEditarUsuarios);
    await prefs.setBool("puede_eliminar_usuarios", permisos.puedeEliminarUsuarios);
    await prefs.setBool("puede_ver_almacenes", permisos.puedeVerAlmacenes);
    await prefs.setBool("puede_crear_almacenes", permisos.puedeCrearAlmacenes);
    await prefs.setBool("puede_modificar_almacenes", permisos.puedeModificarAlmacenes);
    await prefs.setBool("puede_ver_pedidos", permisos.puedeVerPedidos);
    await prefs.setBool("puede_crear_pedidos", permisos.puedeCrearPedidos);
    await prefs.setBool("puede_editar_pedidos", permisos.puedeEditarPedidos);
    await prefs.setBool("puede_ver_incidencias", permisos.puedeVerIncidencias);
    await prefs.setBool("puede_crear_incidencias", permisos.puedeCrearIncidencias);
    await prefs.setBool("puede_ver_pedidoProducto", permisos.puedeVerPedidoProducto);
    await prefs.setBool("puede_crear_pedidoProducto", permisos.puedeCrearPedidoProducto);
    await prefs.setBool("puede_editar_pedidoProducto", permisos.puedeEditarPedidoProducto);
    await prefs.setBool("puede_eliminar_pedidoProducto", permisos.puedeEliminarPedidoProducto);
    await prefs.setBool("puede_ver_metricas", permisos.puedeVerMetricas);
    await prefs.setBool("puede_ver_prevision_demanda", permisos.puedeVerPrevisionDemanda);
    
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
}