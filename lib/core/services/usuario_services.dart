import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:foodflow_app/core/constants/api_endpoints.dart';
import 'package:foodflow_app/core/services/api_services.dart';
import 'package:foodflow_app/models/user_model.dart';

class UserService {
  Future<User?> obtenerDatosCompletos(int userId) async {
    try {
      final response = await ApiServices.dio.get(
        '${ApiEndpoints.usuario}$userId/',
      );

      if (response.statusCode == 200) {
        final userData = response.data;
        return User.fromJson(userData);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error al obtener datos del usuario: $e');
      }
    }
    return null;
  }

  Future<User?> actualizarUsuario(
    int userId,
    Map<String, dynamic> datos,
  ) async {
    try {
      final response = await ApiServices.dio.patch(
        '${ApiEndpoints.usuario}$userId/',
        data: datos,
      );

      if (response.statusCode == 200) {
        final userData = response.data;
        return User.fromJson(userData);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error al actualizar usuario: $e');
      }
    }
    return null;
  }

  Future<String?> subirImagenPerfil(int userId, File imagen) async {
    try {
      String fileName = imagen.path.split('/').last;
      FormData formData = FormData.fromMap({
        'imagen_perfil': await MultipartFile.fromFile(
          imagen.path,
          filename: fileName,
        ),
      });

      final response = await ApiServices.dio.patch(
        '${ApiEndpoints.usuario}$userId/',
        data: formData,
      );

      if (response.statusCode == 200) {
        final userData = response.data;
        return userData['imagen_perfil'];
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error al subir imagen de perfil: $e');
      }
    }
    return null;
  }

  Future<List<User>> obtenerEmpleados() async {
    try {
      final response = await ApiServices.dio.get(
        '${ApiEndpoints.usuario}?tipo_usuario=empleado',
      );

      if (response.statusCode == 200) {
        final List<dynamic> userDataList = response.data;
        return userDataList.map((userData) => User.fromJson(userData)).toList();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error al obtener empleados: $e');
      }
    }
    return [];
  }

  Future<Map<String, bool>?> obtenerPermisosEmpleado(int userId) async {
    try {
      final response = await ApiServices.dio.get(
        ApiEndpoints.permisosEmpleado(userId),
      );

      if (response.statusCode == 200) {
        final permisosData = response.data;

        // Filtrar solo los campos booleanos, excluyendo 'id' y otros campos no booleanos
        final Map<String, bool> permisos = {};
        permisosData.forEach((key, value) {
          if (value is bool) {
            permisos[key] = value;
          }
        });

        return permisos;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error al obtener permisos del empleado: $e');
      }
    }
    return null;
  }

  Future<bool> actualizarPermisosEmpleado(
    int userId,
    Map<String, bool> permisos,
  ) async {
    try {
      final response = await ApiServices.dio.patch(
        ApiEndpoints.permisosEmpleado(userId),
        data: permisos,
      );

      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        print('Error al actualizar permisos del empleado: $e');
      }
      return false;
    }
  }

  Future<bool> restablecerPassword(String email) async {
    try {
      final response = await ApiServices.dio.post(
        ApiEndpoints.resetPassword,
        data: {'email': email},
      );

      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        print('Error al restablecer contraseña: $e');
      }
      return false;
    }
  }
}
