import 'package:flutter/cupertino.dart';
import 'package:foodflow_app/features/auth/login/login_interactor/login_interactor.dart';
import 'package:foodflow_app/features/auth/login/login_model/login_request.dart';

class LoginViewModel extends ChangeNotifier {
  final LoginInteractor _interactor = LoginInteractor();
  bool _isLoading = false;
  String? _errorMessage;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final request = LoginRequest(email: email, password: password);
    final success = await _interactor.login(request);
    _isLoading = false;

    if (!success) {
      _errorMessage = 'Credenciales incorrectas';
    }

    notifyListeners();

    return success;
  }
}
