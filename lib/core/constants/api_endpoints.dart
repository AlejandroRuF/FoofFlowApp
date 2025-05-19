import 'package:flutter/foundation.dart';

class ApiConfig {
  // Tu URL actual está bien
  static const String baseUrl = 'http://192.168.1.130:8000/api/';
}

class ApiEndpoints {
  static const String login = 'auth/token/';
  static const String refreshToken = 'auth/token/refresh/';
  static const String usuario = 'usuarios/';
  static String permisosEmpleado(int userId) => 'permisos-empleados/usuario/$userId/';
  
  // Este método debe usarse para todas las llamadas que no usen el dio con baseUrl
  static String getFullUrl(String endpoint) {
    if (kDebugMode) {
      print('Construyendo URL completa: ${ApiConfig.baseUrl}$endpoint');
    }
    return '${ApiConfig.baseUrl}$endpoint';
  }
}