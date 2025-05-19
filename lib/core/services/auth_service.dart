import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:foodflow_app/core/constants/api_endpoints.dart';
import 'package:foodflow_app/core/services/user_sesion_service.dart';
import 'package:foodflow_app/core/services/user_services.dart';
import 'package:foodflow_app/models/auth_model.dart';
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

  /// Verifica si hay conexión a internet
  Future<bool> _checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } on SocketException catch (_) {
      if (kDebugMode) {
        print('No hay conexión a internet');
      }
      return false;
    }
    return false;
  }

  /// Intenta refrescar el token de acceso utilizando el token de refresco
  Future<Auth?> refreshToken(String refreshToken) async {
    try {
      // Verificar si hay conexión a internet
      final hasConnection = await _checkInternetConnection();
      if (!hasConnection) {
        if (kDebugMode) {
          print('No hay conexión a internet para refrescar el token');
        }
        return null;
      }

      if (kDebugMode) {
        print('Intentando refrescar token...');
        print('Token de refresco: $refreshToken');
        // Usar getFullUrl para obtener la URL completa
        print('URL completa: ${ApiEndpoints.getFullUrl(ApiEndpoints.refreshToken)}');
      }

      final response = await _dio.post(
        // Aquí está el cambio clave - usar la URL completa
        ApiEndpoints.getFullUrl(ApiEndpoints.refreshToken),
        data: {
          'refresh': refreshToken,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      if (kDebugMode) {
        print('Respuesta de refresco: ${response.statusCode}');
        print('Datos de respuesta: ${response.data}');
      }

      if (response.statusCode == 200) {
        final data = response.data;
        
        // Crear el objeto Auth con los nuevos tokens
        final newAuth = Auth(
          accessToken: data['access'],
          refreshToken: data['refresh']
        );
        
        // También actualizamos la información del usuario
        final user = User.fromJson(data);
        
        // Guardar la sesión con los nuevos datos
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
          // Imprimir información de la solicitud
          print('URL de la solicitud: ${e.requestOptions.uri}');
          print('Método de la solicitud: ${e.requestOptions.method}');
          print('Datos de la solicitud: ${e.requestOptions.data}');
        }
      }
    }
    return null;
  }

  /// Intenta realizar un auto-login usando tokens guardados
  Future<bool> attemptAutoLogin() async {
    // Verificar si hay conexión a internet
    final hasConnection = await _checkInternetConnection();
    if (!hasConnection) {
      if (kDebugMode) {
        print('No hay conexión a internet para auto-login');
      }
      return false;
    }

    // Inicializar la sesión primero para cargar tokens guardados
    await UserSessionService().init();
    
    final userSession = UserSessionService();
    
    // Aquí está el cambio principal:
    // Leer directamente de SharedPreferences para evitar posibles problemas con el método getRememberCredentials
    final prefs = await SharedPreferences.getInstance();
    final rememberMe = prefs.getBool('remember_credentials') ?? false;
    
    if (kDebugMode) {
      print('Intentando auto-login...');
      print('¿Recordar credenciales? (leído directamente) $rememberMe');
      print('Token de acceso: ${userSession.token}');
      print('Token de refresco: ${userSession.refreshToken}');
      print('Usuario guardado: ${userSession.user?.toJson()}');
    }
    
    // Esta línea es clave - si el usuario tiene tokens pero no marcó recordar, debemos considerar intentar el login de todas formas
    // Ya que tenemos todos los datos necesarios
    if (userSession.token != null && userSession.refreshToken != null && userSession.user != null) {
      if (kDebugMode) {
        print('Hay datos de sesión guardados, intentando auto-login independientemente de remember_credentials');
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
          print('URL completa: ${ApiEndpoints.getFullUrl("${ApiEndpoints.usuario}$userId/")}');
        }
        
        final user = await UserService().obtenerDatosCompletos(userId);
        
        // Si obtenemos el usuario, el token es válido
        if (user != null) {
          if (kDebugMode) {
            print('Auto-login exitoso con token existente');
          }
          
          // Si el login es exitoso, debemos asegurarnos de guardar la preferencia de recordar
          // Si no estaba guardada previamente
          if (!rememberMe) {
            await userSession.setRememberCredentials(true);
            if (kDebugMode) {
              print('Actualizando remember_credentials a true después de auto-login exitoso');
            }
          }
          
          return true;
        }
        
        // Si el token de acceso no funciona, intentamos refrescar
        if (kDebugMode) {
          print('Token de acceso no válido, intentando refrescar...');
        }
        
        final refreshTokenStr = userSession.refreshToken;
        if (refreshTokenStr == null) {
          return false;
        }
        
        final newAuth = await refreshToken(refreshTokenStr);
        
        if (newAuth != null) {
          // Si el refresco es exitoso, también debemos guardar la preferencia de recordar
          if (!rememberMe) {
            await userSession.setRememberCredentials(true);
            if (kDebugMode) {
              print('Actualizando remember_credentials a true después de refresco exitoso');
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
    
    // Si llegamos aquí, no se pudo hacer auto-login
    if (kDebugMode) {
      print('No se pudo completar el auto-login, limpiando sesión');
    }
    await userSession.clearSession();
    return false;
  }
}