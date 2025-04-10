class ApiConfig {
  static const String baseUrl = 'http://192.168.0.7:8000/api/';
}

class ApiEndpoints {
  static const String login = '${ApiConfig.baseUrl}auth/token/';
}
