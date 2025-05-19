import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:foodflow_app/core/constants/api_endpoints.dart';
import 'package:foodflow_app/core/services/auth_service.dart';
import 'package:foodflow_app/core/services/user_sesion_service.dart';

class ApiServices {
  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 30), // Mayor tiempo de espera
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      validateStatus: (status) {
        // Esto permite ver todos los códigos de estado para depuración
        return status != null && status < 500;
      },
    ),
  )
  ..interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = UserSessionService().token;
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        
        if (kDebugMode) {
          print('Realizando solicitud a: ${options.uri}');
          print('Headers: ${options.headers}');
          print('Datos: ${options.data}');
        }
        
        return handler.next(options);
      },
      
      onError: (e, handler) async {
        // Si el error es 401 (Unauthorized), puede ser por token expirado
        if (e.response?.statusCode == 401) {
          if (kDebugMode) {
            print('Token expirado, intentando refrescar...');
          }
          
          // Obtener el token de refresco
          final refreshToken = UserSessionService().refreshToken;
          
          if (refreshToken != null) {
            // Intentar refrescar el token
            final newAuth = await AuthService().refreshToken(refreshToken);
            
            if (newAuth != null) {
              // El token ya se actualizó en el método refreshToken
              
              // Reintentar la solicitud original con el nuevo token
              final opts = Options(
                method: e.requestOptions.method,
                headers: {
                  'Authorization': 'Bearer ${newAuth.accessToken}',
                },
              );
              
              final response = await dio.request(
                e.requestOptions.path,
                options: opts,
                data: e.requestOptions.data,
                queryParameters: e.requestOptions.queryParameters,
              );
              
              return handler.resolve(response);
            }
          }
        }
        
        if (kDebugMode) {
          print('Error global: ${e.message}');
          print('URL que falló: ${e.requestOptions.uri}');
        }
        return handler.next(e);
      },
    ),
  )
  ..interceptors.add(
    LogInterceptor(
      requestBody: kDebugMode,
      responseBody: kDebugMode,
      logPrint: (obj) {
        if (kDebugMode) {
          print(obj);
        }
      },
    ),
  );
  
  // Método de inicialización
  static Future<void> init() async {
    if (kDebugMode) {
      print('Inicializando ApiServices...');
      print('URL base configurada: ${ApiConfig.baseUrl}');
    }
    
    // Verificar conectividad antes de hacer cualquier operación
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        if (kDebugMode) {
          print('Conexión a internet disponible');
        }
      }
    } on SocketException catch (_) {
      if (kDebugMode) {
        print('No hay conexión a internet');
      }
    }
  }
  
  // Método de depuración
  static void debugTokens() async {
    final sessionService = UserSessionService();
    final rememberMe = await sessionService.getRememberCredentials();
    
    if (kDebugMode) {
      print('=== DEBUG TOKENS ===');
      print('Access Token: ${sessionService.token}');
      print('Refresh Token: ${sessionService.refreshToken}');
      print('User: ${sessionService.user?.toJson()}');
      print('Remember Credentials: $rememberMe');
      print('====================');
    }
  }
  
  // Método para probar el refresco de token
  static Future<bool> testRefreshToken() async {
    final userSession = UserSessionService();
    final refreshToken = userSession.refreshToken;
    
    if (refreshToken == null) {
      if (kDebugMode) {
        print('No hay token de refresco para probar');
      }
      return false;
    }
    
    try {
      if (kDebugMode) {
        print('Probando refresco de token con: $refreshToken');
      }
      
      final response = await dio.post(
        ApiEndpoints.getFullUrl(ApiEndpoints.refreshToken),
        data: {
          'refresh': refreshToken,
        },
      );
      
      if (kDebugMode) {
        print('Respuesta de prueba de refresco: ${response.statusCode}');
        print('Datos: ${response.data}');
      }
      
      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        print('Error al probar refresco: $e');
      }
      return false;
    }
  }
}