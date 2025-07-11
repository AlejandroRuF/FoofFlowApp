import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:foodflow_app/core/constants/api_endpoints.dart';
import 'package:foodflow_app/core/services/api_services.dart';
import 'package:foodflow_app/core/services/usuario_sesion_service.dart';
import 'package:foodflow_app/core/services/cocina_central_restaurante_service.dart';
import 'package:foodflow_app/models/permisos_empleado_model.dart';
import 'package:foodflow_app/models/user_model.dart';

class UserService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  final CocinaCentralRestauranteService _cocinaCentralRestauranteService =
      CocinaCentralRestauranteService();

  Future<User?> obtenerDatosUsuario(int userId) async {
    try {
      if (kDebugMode) {
        print('Obteniendo datos del usuario ID: $userId');
        print(
          'URL completa: ${ApiEndpoints.getFullUrl("${ApiEndpoints.usuario}$userId/")}',
        );
      }

      final response = await ApiServices.dio.get(
        "${ApiEndpoints.usuario}$userId/",
      );

      if (response.statusCode == 200) {
        final userData = response.data;
        final user = User.fromJson(userData);

        if (kDebugMode) {
          print('Datos del usuario obtenidos: ${user.toJson()}');
        }

        return user;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error al obtener datos del usuario: $e');
        if (e is DioException) {
          print('DioError tipo: ${e.type}');
          print('DioError mensaje: ${e.message}');
          print('DioError respuesta: ${e.response}');
          print('URL de la solicitud: ${e.requestOptions.uri}');
        }
      }
    }
    return null;
  }

  Future<User?> obtenerDatosCompletos(int userId) async {
    try {
      final user = await obtenerDatosUsuario(userId);

      if (user != null) {
        final usuarioActual = UserSessionService().user;
        if (usuarioActual != null && usuarioActual.id == userId) {
          await UserSessionService().actualizarDatosUsuario(user);
        }
      }

      return user;
    } catch (e) {
      if (kDebugMode) {
        print('Error al obtener datos completos del usuario: $e');
      }
    }
    return null;
  }

  @deprecated
  Future<PermisosEmpleado?> obtenerPermisosUsuario(int userId) async {
    final user = UserSessionService().user;
    if (user?.permisos != null) {
      return user!.permisos;
    }

    final userCompleto = await obtenerDatosCompletos(userId);
    return userCompleto?.permisos;
  }

  Future<User?> actualizarUsuario(
    int userId,
    Map<String, dynamic> datos,
  ) async {
    try {
      if (kDebugMode) {
        print(
          'Realizando solicitud a: ${ApiEndpoints.getFullUrl("${ApiEndpoints.usuario}$userId/")}',
        );
        print('Headers: ${ApiServices.dio.options.headers}');
        print('Datos: $datos');
      }

      final response = await ApiServices.dio.patch(
        "${ApiEndpoints.usuario}$userId/",
        data: datos,
      );

      if (response.statusCode == 200) {
        final userData = response.data;
        final user = User.fromJson(userData);

        final usuarioActual = UserSessionService().user;
        if (usuarioActual != null && usuarioActual.id == userId) {
          await UserSessionService().actualizarDatosUsuario(user);
        }

        return user;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error al actualizar usuario: $e');
      }
    }
    return null;
  }

  Future<bool> cambiarPassword(
    int userId,
    String currentPassword,
    String newPassword,
  ) async {
    try {
      final response = await ApiServices.dio.post(
        "${ApiEndpoints.usuario}$userId/change-password/",
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        print('Error al cambiar contraseña: $e');
      }
      return false;
    }
  }

  Future<List<User>> obtenerEmpleados(int propietarioId) async {
    try {
      final response = await ApiServices.dio.get(
        ApiEndpoints.usuario,
        queryParameters: {'propietario': propietarioId},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((e) => User.fromJson(e)).toList();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error al obtener empleados: $e');
      }
    }
    return [];
  }

  Future<User?> crearEmpleado(Map<String, dynamic> datosEmpleado) async {
    try {
      final response = await ApiServices.dio.post(
        ApiEndpoints.usuario,
        data: datosEmpleado,
      );

      if (response.statusCode == 201) {
        final userData = response.data;
        return User.fromJson(userData);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error al crear empleado: $e');
      }
    }
    return null;
  }

  Future<List<User>> obtenerTodosLosUsuarios() async {
    try {
      final response = await ApiServices.dio.get(ApiEndpoints.usuario);

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((e) => User.fromJson(e)).toList();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error al obtener todos los usuarios: $e');
      }
    }
    return [];
  }

  Future<List<User>> obtenerCocinasDeUsuario(int usuarioId) async {
    try {
      final usuario = await obtenerDatosUsuario(usuarioId);

      if (usuario == null) return [];

      List<User> cocinasRelacionadas = [];

      if (usuario.tipoUsuario == 'cocina_central') {
        cocinasRelacionadas.add(usuario);
      } else if (usuario.tipoUsuario == 'restaurante') {
        if (UserSessionService().user?.tipoUsuario == 'administrador') {
          cocinasRelacionadas = await _cocinaCentralRestauranteService
              .obtenerCocinasDeRestaurante(usuarioId);
        } else {
          cocinasRelacionadas = await obtenerTodosLosUsuarios();
        }
      }

      return cocinasRelacionadas;
    } catch (e) {
      if (kDebugMode) {
        print('Error al obtener cocinas del usuario: $e');
      }
    }
    return [];
  }

  Future<bool> actualizarPermisosEmpleado(
    int empleadoId,
    Map<String, bool> permisos,
  ) async {
    try {
      final permisosResponse = await ApiServices.dio.get(
        ApiEndpoints.permisosEmpleado(empleadoId),
      );

      if (permisosResponse.statusCode == 200 &&
          permisosResponse.data.isNotEmpty) {
        final permisosData = permisosResponse.data;
        final permisosId = permisosData['id'];

        final response = await ApiServices.dio.patch(
          ApiEndpoints.permisosEmpleado(empleadoId),
          data: permisos,
        );

        return response.statusCode == 200;
      } else {
        final response = await ApiServices.dio.post(
          ApiEndpoints.permisosEmpleado(empleadoId),
          data: permisos,
        );

        return response.statusCode == 201;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error al actualizar permisos: $e');
      }
      return false;
    }
  }

  Future<String?> subirImagenPerfil(int userId, File imagen) async {
    try {
      if (kDebugMode) {
        print('Datos: Instance of \'FormData\'');
      }

      final formData = FormData.fromMap({
        'imagen': await MultipartFile.fromFile(
          imagen.path,
          filename:
              'profile_${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
      });

      final response = await ApiServices.dio.patch(
        "${ApiEndpoints.usuario}$userId/",
        data: formData,
      );

      if (response.statusCode == 200) {
        final userData = response.data;
        final user = User.fromJson(userData);
        final usuarioActual = UserSessionService().user;
        if (usuarioActual != null && usuarioActual.id == userId) {
          await UserSessionService().actualizarDatosUsuario(user);
        }

        return user.imagen;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error al subir imagen: $e');
      }
    }
    return null;
  }

  Future<bool> solicitarRestablecerPassword(String email) async {
    try {
      final url = ApiEndpoints.getFullUrl(ApiEndpoints.resetPassword);
      final response = await ApiServices.dio.post(url, data: {'email': email});
      return response.statusCode == 200;
    } catch (e) {
      print('Error al solicitar restablecer contraseña: $e');
      return false;
    }
  }
}
