class ApiConfig {
  static const String baseUrl = 'http://192.168.1.140:8000/api/';
}

class ApiEndpoints {
  static const String login = '${ApiConfig.baseUrl}auth/token/';
}
