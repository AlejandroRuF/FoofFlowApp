import 'package:flutter/foundation.dart';
import 'package:foodflow_app/core/services/api_services.dart';
import 'package:foodflow_app/core/services/user_sesion_service.dart';
import 'package:foodflow_app/features/auth/login/login_model/login_request.dart';
import 'package:foodflow_app/models/auth_model.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/services/user_services.dart';
import '../../../../models/user_model.dart';

class LoginInteractor {
  Future<bool> login(LoginRequest request, {bool rememberMe = false}) async {
  try {
    final response = await ApiServices.dio.post(
      ApiEndpoints.login,
      data: request.toJson(),
    );

    if (response.statusCode == 200) {
      final data = response.data;
      
      // Imprimir respuesta para debug
      if (kDebugMode) {
        print('Respuesta de API: $data');
        print('User ID: ${data['usuario_id']}');
        print('Email: ${data['email']}');
      }
      
      // Crear objeto Auth
      final auth = Auth(
        accessToken: data['access'],
        refreshToken: data['refresh']
      );
      
      // Crear objeto User básico
      final user = User.fromJson(data);
      
      if (kDebugMode) {
        print('Respuesta de login: $data');
        print('Usuario creado: ${user.toJson()}');
        print('Respuesta completa de login: $data');
      }

      // Guardar sesión con datos básicos
      await UserSessionService().saveSession(auth, user, rememberMe: rememberMe);
      
      // Obtener datos completos del usuario
      final userId = user.id;
      await UserService().obtenerDatosCompletos(userId);
      
      return true;
    }
  } catch (e) {
    if (kDebugMode) {
      print('Error durante el login: $e');
    }
  }
  return false;
}
}