
class ApiConfig {
  static const String hostUrl = 'http://192.168.1.130:8000/';
  static const String baseUrl = '${hostUrl}api/';
}

class ApiEndpoints {
  // Auth endpoints
  static const String login = 'auth/token/';
  static const String refreshToken = 'auth/token/refresh/';
  static const String logout = 'auth/logout/';

  // Endpoint para restablecer contraseña
  static const String resetPassword = 'auth/reset-password/';
  static const String confirmResetPassword = 'auth/reset-password/{token}/';
  static const String adminResetPasswordDirect = 'auth/reset-password-directo/';
  static const String adminResetPasswordLink =
      'auth/reset-password-admin-link/';

  // Endpoints de usuarios
  static const String usuario = 'usuarios/';
  static String permisosEmpleado(int userId) =>
      'permisos-empleados/usuario/$userId/';

  // Endpoints de métricas
  static const String metricasVentas = 'metricas-ventas/';
  static const String previsionDemanda = 'prevision-demanda/';

  // Endpoints de pedidos e incidencias
  static const String pedidos = 'pedidos/';
  static const String incidencias = 'incidencias/';
  static const String productos = 'productos/';
  static const String carritos = 'carritos/';
  static String carritoPorId(int id) => 'carritos/$id/';

  // Endpoints para productos relacionados
  static const String categorias = 'categorias/';
  static const String almacenes = 'almacenes/';
  static const String pedidoProductos = 'pedido-productos/';

  // Endpoints para historial
  static const String historialPedidos = 'historial-pedidos/';
  static const String historialProductos = 'historial-productos/';

  // Endpoint para actividad de usuarios
  static const String actividadUsuarios = 'actividad-usuarios/';

  static String getFullUrl(String endpoint) {
    return '${ApiConfig.baseUrl}$endpoint';
  }

  static String getResetPasswordUrl(String token) {
    return getFullUrl(confirmResetPassword.replaceAll('{token}', token));
  }
}
