import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/services/user_sesion_service.dart';
import '../login_interactor/login_interactor.dart';
import '../login_model/login_request.dart';

class LoginViewModel extends ChangeNotifier {
  final _interactor = LoginInteractor();
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Claves para SharedPreferences
  static const String _savedEmailKey = 'saved_email';
  static const String _rememberMeKey = 'remember_me';

  // Método para obtener el email guardado
  Future<String?> getSavedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final rememberMe = prefs.getBool(_rememberMeKey) ?? false;
    
    if (rememberMe) {
      return prefs.getString(_savedEmailKey);
    }
    return null;
  }

  // Método para guardar o eliminar las credenciales
  Future<void> _saveOrClearCredentials(String email, bool rememberMe) async {
    final prefs = await SharedPreferences.getInstance();
    
    if (rememberMe) {
      await prefs.setString(_savedEmailKey, email);
      await prefs.setBool(_rememberMeKey, true);
    } else {
      await prefs.remove(_savedEmailKey);
      await prefs.setBool(_rememberMeKey, false);
    }
  }

Future<bool> login(String email, String password, {bool rememberMe = false}) async {
  _isLoading = true;
  _errorMessage = null;
  notifyListeners();

  try {
    final request = LoginRequest(email: email, password: password);
    final success = await _interactor.login(request, rememberMe: rememberMe);
    
    if (success) {
      // Si el login fue exitoso, guardamos o limpiamos las credenciales según rememberMe
      await _saveOrClearCredentials(email, rememberMe);
      
      // También actualizamos la configuración de recordar en UserSessionService
      await UserSessionService().setRememberCredentials(rememberMe);
      
      if (kDebugMode) {
        print('Login exitoso, rememberMe: $rememberMe');
        final prefs = await SharedPreferences.getInstance();
        final savedRemember = prefs.getBool('remember_credentials') ?? false;
        print('Valor guardado de remember_credentials: $savedRemember');
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _errorMessage = 'Credenciales inválidas';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  } catch (e) {
    _errorMessage = 'Error de conexión';
    _isLoading = false;
    notifyListeners();
    return false;
  }
}
Future<bool> logout() async {
  _isLoading = true;
  _errorMessage = null;
  notifyListeners();
  
  try {
    await UserSessionService().clearSession();
    _isLoading = false;
    notifyListeners();
    
    if (kDebugMode) {
      print('Sesión cerrada correctamente');
    }
    
    return true;
  } catch (e) {
    _errorMessage = 'Error al cerrar sesión';
    _isLoading = false;
    notifyListeners();
    
    if (kDebugMode) {
      print('Error al cerrar sesión: $e');
    }
    
    return false;
  }
}
}