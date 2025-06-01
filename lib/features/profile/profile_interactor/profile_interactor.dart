import 'dart:io';
import 'package:foodflow_app/core/services/usuario_services.dart';
import 'package:foodflow_app/core/services/usuario_sesion_service.dart';
import 'package:foodflow_app/core/services/api_services.dart';
import 'package:foodflow_app/models/user_model.dart';
import 'package:foodflow_app/models/permisos_empleado_model.dart';
import 'package:image_picker/image_picker.dart';
import '../profile_model/Profile_management_model.dart';

class ProfileInteractor {
  final UserService _userService = UserService();
  final UserSessionService _userSessionService = UserSessionService();
  final ApiServices _apiService = ApiServices();

  User? obtenerUsuarioActual() {
    return _userSessionService.user;
  }

  bool esResponsable() {
    final user = _userSessionService.user;
    return user != null &&
        (user.tipoUsuario == 'restaurante' ||
            user.tipoUsuario == 'cocina_central');
  }

  PermisosEmpleado? obtenerPermisosUsuario() {
    return _userSessionService.permisos;
  }

  Future<bool> actualizarUsuario(int userId, Map<String, dynamic> datos) async {
    try {
      final user = await _userService.actualizarUsuario(userId, datos);
      return user != null;
    } catch (e) {
      return false;
    }
  }

  Future<bool> cambiarPassword(
    int userId,
    String currentPassword,
    String newPassword,
  ) async {
    try {
      return await _userService.cambiarPassword(
        userId,
        currentPassword,
        newPassword,
      );
    } catch (e) {
      return false;
    }
  }

  Future<List<User>> obtenerEmpleados() async {
    try {
      final user = _userSessionService.user;
      if (user == null || !esResponsable()) return [];

      final empleados = await _userService.obtenerEmpleados(user.id);
      return empleados.where((user) => user.tipoUsuario == 'empleado').toList();
    } catch (e) {
      return [];
    }
  }

  Future<User?> crearEmpleado(Map<String, dynamic> datosEmpleado) async {
    try {
      return await _userService.crearEmpleado(datosEmpleado);
    } catch (e) {
      print('Error al crear empleado: $e');
      return null;
    }
  }

  Map<String, bool>? obtenerPermisosEmpleado(User empleado) {
    try {
      final permisos = empleado.permisos;
      if (permisos == null) return null;

      return {
        'puede_ver_productos': permisos.puedeVerProductos,
        'puede_crear_productos': permisos.puedeCrearProductos,
        'puede_editar_productos': permisos.puedeEditarProductos,
        'puede_desactivar_productos': permisos.puedeDesactivarProductos,
        'puede_ver_historial_producto': permisos.puedeVerHistorialProducto,
        'puede_ver_usuarios': permisos.puedeVerUsuarios,
        'puede_crear_usuarios': permisos.puedeCrearUsuarios,
        'puede_editar_usuarios': permisos.puedeEditarUsuarios,
        'puede_eliminar_usuarios': permisos.puedeEliminarUsuarios,
        'puede_ver_almacenes': permisos.puedeVerAlmacenes,
        'puede_crear_almacenes': permisos.puedeCrearAlmacenes,
        'puede_modificar_almacenes': permisos.puedeModificarAlmacenes,
        'puede_ver_pedidos': permisos.puedeVerPedidos,
        'puede_crear_pedidos': permisos.puedeCrearPedidos,
        'puede_editar_pedidos': permisos.puedeEditarPedidos,
        'puede_ver_incidencias': permisos.puedeVerIncidencias,
        'puede_crear_incidencias': permisos.puedeCrearIncidencias,
        'puede_modificar_incidencias': permisos.puedeModificarIncidencias,
        'puede_ver_pedidoProducto': permisos.puedeVerPedidoProducto,
        'puede_crear_pedidoProducto': permisos.puedeCrearPedidoProducto,
        'puede_editar_pedidoProducto': permisos.puedeEditarPedidoProducto,
        'puede_eliminar_pedidoProducto': permisos.puedeEliminarPedidoProducto,
        'puede_ver_metricas': permisos.puedeVerMetricas,
        'puede_ver_prevision_demanda': permisos.puedeVerPrevisionDemanda,
      };
    } catch (e) {
      print('Error al obtener permisos del empleado: $e');
      return null;
    }
  }

  Future<bool> actualizarPermisosEmpleado(
    int empleadoId,
    Map<String, bool> permisos,
  ) async {
    try {
      return await _userService.actualizarPermisosEmpleado(
        empleadoId,
        permisos,
      );
    } catch (e) {
      print('Error al actualizar permisos del empleado: $e');
      return false;
    }
  }

  Future<String?> subirImagenPerfil(int userId, File imagen) async {
    try {
      return await _userService.subirImagenPerfil(userId, imagen);
    } catch (e) {
      return null;
    }
  }

  Future<File?> obtenerImagen(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  List<PermissionCategory> obtenerCategoriasPermisos() {
    return [
      PermissionCategory(
        name: 'Productos',
        description: 'Permisos relacionados con la gestión de productos',
        permissions: [
          PermissionItem(
            key: 'puede_ver_productos',
            name: 'Ver productos',
            description: 'Permite ver la lista de productos',
          ),
          PermissionItem(
            key: 'puede_crear_productos',
            name: 'Crear productos',
            description: 'Permite crear nuevos productos',
          ),
          PermissionItem(
            key: 'puede_editar_productos',
            name: 'Editar productos',
            description: 'Permite modificar productos existentes',
          ),
          PermissionItem(
            key: 'puede_desactivar_productos',
            name: 'Desactivar productos',
            description: 'Permite desactivar productos',
          ),
          PermissionItem(
            key: 'puede_ver_historial_producto',
            name: 'Ver historial',
            description: 'Permite ver el historial de productos',
          ),
        ],
      ),
      PermissionCategory(
        name: 'Usuarios',
        description: 'Permisos relacionados con la gestión de usuarios',
        permissions: [
          PermissionItem(
            key: 'puede_ver_usuarios',
            name: 'Ver usuarios',
            description: 'Permite ver la lista de usuarios',
          ),
          PermissionItem(
            key: 'puede_crear_usuarios',
            name: 'Crear usuarios',
            description: 'Permite crear nuevos usuarios',
          ),
          PermissionItem(
            key: 'puede_editar_usuarios',
            name: 'Editar usuarios',
            description: 'Permite modificar usuarios existentes',
          ),
          PermissionItem(
            key: 'puede_eliminar_usuarios',
            name: 'Eliminar usuarios',
            description: 'Permite eliminar usuarios',
          ),
        ],
      ),
      PermissionCategory(
        name: 'Almacenes',
        description: 'Permisos relacionados con la gestión de almacenes',
        permissions: [
          PermissionItem(
            key: 'puede_ver_almacenes',
            name: 'Ver almacenes',
            description: 'Permite ver almacenes',
          ),
          PermissionItem(
            key: 'puede_crear_almacenes',
            name: 'Crear almacenes',
            description: 'Permite crear nuevos almacenes',
          ),
          PermissionItem(
            key: 'puede_modificar_almacenes',
            name: 'Modificar almacenes',
            description: 'Permite modificar almacenes existentes',
          ),
        ],
      ),
      PermissionCategory(
        name: 'Pedidos',
        description: 'Permisos relacionados con la gestión de pedidos',
        permissions: [
          PermissionItem(
            key: 'puede_ver_pedidos',
            name: 'Ver pedidos',
            description: 'Permite ver la lista de pedidos',
          ),
          PermissionItem(
            key: 'puede_crear_pedidos',
            name: 'Crear pedidos',
            description: 'Permite crear nuevos pedidos',
          ),
          PermissionItem(
            key: 'puede_editar_pedidos',
            name: 'Editar pedidos',
            description: 'Permite modificar pedidos existentes',
          ),
          PermissionItem(
            key: 'puede_ver_pedidoProducto',
            name: 'Ver detalles de pedido',
            description: 'Permite ver los productos de un pedido',
          ),
          PermissionItem(
            key: 'puede_crear_pedidoProducto',
            name: 'Añadir productos a pedido',
            description: 'Permite añadir productos a un pedido',
          ),
          PermissionItem(
            key: 'puede_editar_pedidoProducto',
            name: 'Modificar productos de pedido',
            description: 'Permite modificar productos en un pedido',
          ),
          PermissionItem(
            key: 'puede_eliminar_pedidoProducto',
            name: 'Eliminar productos de pedido',
            description: 'Permite eliminar productos de un pedido',
          ),
        ],
      ),
      PermissionCategory(
        name: 'Incidencias',
        description: 'Permisos relacionados con la gestión de incidencias',
        permissions: [
          PermissionItem(
            key: 'puede_ver_incidencias',
            name: 'Ver incidencias',
            description: 'Permite ver la lista de incidencias',
          ),
          PermissionItem(
            key: 'puede_crear_incidencias',
            name: 'Crear incidencias',
            description: 'Permite crear nuevas incidencias',
          ),
          PermissionItem(
            key: 'puede_modificar_incidencias',
            name: 'Modificar incidencias',
            description: 'Permite modificar incidencias existentes',
          ),
        ],
      ),
      PermissionCategory(
        name: 'Métricas y Previsiones',
        description: 'Permisos relacionados con métricas y previsiones',
        permissions: [
          PermissionItem(
            key: 'puede_ver_metricas',
            name: 'Ver métricas',
            description: 'Permite ver las métricas',
          ),
          PermissionItem(
            key: 'puede_ver_prevision_demanda',
            name: 'Ver previsión de demanda',
            description: 'Permite ver previsiones de demanda',
          ),
        ],
      ),
    ];
  }

  Future<bool> solicitarRestablecerPassword(String email) async {
    try {
      final userService = UserService();
      return await userService.solicitarRestablecerPassword(email);
    } catch (e) {
      print('Error al solicitar restablecer contraseña: $e');
      return false;
    }
  }
}
