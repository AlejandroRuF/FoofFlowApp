import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:foodflow_app/core/constants/api_endpoints.dart';
import 'package:foodflow_app/core/services/auth_service.dart';
import 'package:foodflow_app/core/services/usuario_sesion_service.dart';

class ApiServices {
  static final Dio dio =
      Dio(
          BaseOptions(
            baseUrl: ApiConfig.baseUrl,
            connectTimeout: const Duration(seconds: 30),
            receiveTimeout: const Duration(seconds: 30),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            validateStatus: (status) {
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
              if (e.response?.statusCode == 401) {
                if (kDebugMode) {
                  print('Token expirado, intentando refrescar...');
                }

                final refreshToken = UserSessionService().refreshToken;

                if (refreshToken != null) {
                  final newAuth = await AuthService().refreshToken(
                    refreshToken,
                  );

                  if (newAuth != null) {
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
}
