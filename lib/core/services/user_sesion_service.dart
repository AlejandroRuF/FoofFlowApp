import 'package:shared_preferences/shared_preferences.dart';

import '../../models/user_model.dart';

class UserSessionService {
  static final UserSessionService _instance = UserSessionService._internal();
  factory UserSessionService() => _instance;
  UserSessionService._internal();

  String? _token;
  User? _user;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');

    final userId = prefs.getInt('user_id');
    final email = prefs.getString('email');

    if (userId != null && email != null) {
      _user = User(id: userId, email: email);
    }
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    _token = null;
    _user = null;
  }

  Future<void> saveSession(String token, User user) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString("token", token);
    await prefs.setInt("user_id", user.id);
    await prefs.setString("email", user.email);

    _token = token;
    _user = user;
  }

  String? get token => _token;

  User? get user => _user;

  bool get isLoggedIn => _token != null && _user != null;
}
