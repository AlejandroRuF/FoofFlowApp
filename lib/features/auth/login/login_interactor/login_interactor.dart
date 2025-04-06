import 'package:flutter/foundation.dart';
import 'package:foodflow_app/core/services/api_services.dart';
import 'package:foodflow_app/core/services/user_sesion_service.dart';
import 'package:foodflow_app/features/auth/login/login_model/login_request.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../models/user_model.dart';

class LoginInteractor {
  Future<bool> login(LoginRequest request) async {
    try {
      final response = await ApiServices.dio.post(
        ApiEndpoints.login,
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final token = data['token'];
        final user = User.fromJson(data);

        await UserSessionService().saveSession(token, user);
        return true;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error durante el login');
      }
    }
    return false;
  }
}
