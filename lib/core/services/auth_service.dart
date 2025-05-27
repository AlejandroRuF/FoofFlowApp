import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:foodflow_app/core/constants/api_endpoints.dart';
import 'package:foodflow_app/core/services/usuario_sesion_service.dart';
import 'package:foodflow_app/core/services/usuario_services.dart';
import 'package:foodflow_app/models/auth_model.dart';
import 'package:go_router/go_router.dart';
import '../../models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  Future<bool> login(
    String email,
    String password,
    bool rememberMe,
    BuildContext context,
  ) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.getFullUrl(ApiEndpoints.login),
        data: {'email': email, 'password': password},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200) {
        final data = response.data;

        final auth = Auth(
          accessToken: data['access'],
          refreshToken: data['refresh'],
        );

        final user = User.fromJson(data);

        await UserSessionService().saveSession(
          auth,
          user,
          rememberMe: rememberMe,
        );

        context.go('/dashboard');

        return true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Error en login: $e');
      }
      return false;
    }
  }

  Future<Auth?> refreshToken(String refreshToken) async {
    try {
      if (kDebugMode) {
        print('Intentando refrescar token...');
        print('Token de refresco: $refreshToken');
        print(
          'URL completa: ${ApiEndpoints.getFullUrl(ApiEndpoints.refreshToken)}',
        );
      }

      final response = await _dio.post(
        ApiEndpoints.getFullUrl(ApiEndpoints.refreshToken),
        data: {'refresh': refreshToken},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (kDebugMode) {
        print('Respuesta de refresco: ${response.statusCode}');
        print('Datos de respuesta: ${response.data}');
      }

      if (response.statusCode == 200) {
        final data = response.data;

        final newAuth = Auth(
          accessToken: data['access'],
          refreshToken: data['refresh'],
        );

        final user = User.fromJson(data);

        await UserSessionService().saveSession(newAuth, user, rememberMe: true);

        return newAuth;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error al refrescar token: $e');
        if (e is DioException) {
          print('DioError tipo: ${e.type}');
          print('DioError mensaje: ${e.message}');
          print('DioError respuesta: ${e.response}');
          print('URL de la solicitud: ${e.requestOptions.uri}');
          print('Método de la solicitud: ${e.requestOptions.method}');
          print('Datos de la solicitud: ${e.requestOptions.data}');
        }
      }
    }
    return null;
  }

  Future<bool> attemptAutoLogin() async {
    await UserSessionService().init();

    final userSession = UserSessionService();

    final prefs = await SharedPreferences.getInstance();
    final rememberMe = prefs.getBool('remember_credentials') ?? false;

    if (kDebugMode) {
      print('Intentando auto-login...');
      print('¿Recordar credenciales? (leído directamente) $rememberMe');
      print('Token de acceso: ${userSession.token}');
      print('Token de refresco: ${userSession.refreshToken}');
      print('Usuario guardado: ${userSession.user?.toJson()}');
    }

    if (userSession.token != null &&
        userSession.refreshToken != null &&
        userSession.user != null) {
      if (kDebugMode) {
        print(
          'Hay datos de sesión guardados, intentando auto-login independientemente de remember_credentials',
        );
      }

      try {
        final userId = userSession.user?.id;
        if (userId == null) {
          if (kDebugMode) {
            print('No se puede realizar auto-login: falta el ID de usuario');
          }
          return false;
        }

        if (kDebugMode) {
          print('Intentando obtener datos del usuario con token existente...');
          print(
            'URL completa: ${ApiEndpoints.getFullUrl("${ApiEndpoints.usuario}$userId/")}',
          );
        }

        final user = await UserService().obtenerDatosCompletos(userId);

        if (user != null) {
          if (kDebugMode) {
            print('Auto-login exitoso con token existente');
          }

          if (!rememberMe) {
            await userSession.setRememberCredentials(true);
            if (kDebugMode) {
              print(
                'Actualizando remember_credentials a true después de auto-login exitoso',
              );
            }
          }

          return true;
        }

        if (kDebugMode) {
          print('Token de acceso no válido, intentando refrescar...');
        }

        final refreshTokenStr = userSession.refreshToken;
        if (refreshTokenStr == null) {
          return false;
        }

        final newAuth = await refreshToken(refreshTokenStr);

        if (newAuth != null) {
          if (!rememberMe) {
            await userSession.setRememberCredentials(true);
            if (kDebugMode) {
              print(
                'Actualizando remember_credentials a true después de refresco exitoso',
              );
            }
          }

          return true;
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error durante auto-login: $e');
        }
      }
    } else {
      if (kDebugMode) {
        print('No hay suficientes datos para intentar auto-login');
      }
    }

    if (kDebugMode) {
      print('No se pudo completar el auto-login, limpiando sesión');
    }
    await userSession.clearSession();
    return false;
  }
}
