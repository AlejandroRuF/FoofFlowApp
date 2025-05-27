import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:validators/validators.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/services/usuario_services.dart';
import '../../../../core/services/usuario_sesion_service.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../dashboard/dashboard_view/dashboard_screen.dart';
import '../login_viewmodel/login_viewmodel.dart';
import '../../../../core/services/api_services.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/login_bg.png',
            fit:
                screenWidth > 700
                    ? screenWidth > 900
                        ? BoxFit.fill
                        : BoxFit.fitWidth
                    : BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            alignment:
                screenWidth > 700 ? Alignment.center : Alignment.topCenter,
          ),

          Container(color: Colors.black.withAlpha((0.4 * 255).round())),

          const Center(child: LoginCard()),
        ],
      ),
    );
  }
}

class LoginCard extends StatelessWidget {
  const LoginCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                'FoodFlow',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                ),
              ),
              SizedBox(height: 24),
              LoginForm(),
            ],
          ),
        ),
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberCredentials = false;
  bool _isAutoLoggingIn = false;
  bool _isLoading = false;

  String? _emailError;
  String? _passwordError;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
    _checkForStoredDataAndAutoLogin();
  }

  Future<void> _checkForStoredDataAndAutoLogin() async {
    final viewModel = Provider.of<LoginViewModel>(context, listen: false);
    final userSession = UserSessionService();

    if (userSession.token != null &&
        userSession.refreshToken != null &&
        userSession.user != null) {
      setState(() {
        _isAutoLoggingIn = true;
      });

      if (kDebugMode) {
        print(
          'Se encontraron datos de sesión en LoginScreen, intentando auto-login...',
        );
      }

      try {
        final userId = userSession.user!.id;
        final user = await UserService().obtenerDatosCompletos(userId);

        if (user != null) {
          if (kDebugMode) {
            print('Auto-login exitoso desde LoginScreen');
          }

          await userSession.setRememberCredentials(true);

          context.go('/dashboard');
        } else {
          setState(() {
            _isAutoLoggingIn = false;
          });
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error durante auto-login desde LoginScreen: $e');
        }
        setState(() {
          _isAutoLoggingIn = false;
        });
      }
    }
  }

  Future<void> _abrirResetPasswordURL() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, introduce tu correo electrónico'),
        ),
      );
      return;
    }

    if (!isEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, introduce un correo electrónico válido'),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final resetPasswordUrl = ApiEndpoints.getFullUrl(
        ApiEndpoints.resetPassword,
      );

      if (kDebugMode) {
        print(
          'Enviando solicitud de reseteo de contraseña a: $resetPasswordUrl',
        );
        print('Email: $email');
      }

      final response = await ApiServices.dio.post(
        ApiEndpoints.resetPassword,
        data: {'email': email},
      );

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Se ha enviado un correo con las instrucciones para restablecer tu contraseña',
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else if (response.statusCode == 404) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'El correo electrónico no está registrado en el sistema',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Error: ${response.data['error'] ?? "Ocurrió un error al procesar tu solicitud"}',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (kDebugMode) {
        print('Error al enviar solicitud de reseteo: $e');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Error de conexión. Verifica tu conexión a internet e intenta nuevamente.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadSavedCredentials() async {
    final viewModel = Provider.of<LoginViewModel>(context, listen: false);
    final savedEmail = await viewModel.getSavedEmail();

    if (savedEmail != null && savedEmail.isNotEmpty) {
      setState(() {
        _emailController.text = savedEmail;
        _rememberCredentials = true;
      });
    }
  }

  bool _validateFields() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    bool isValid = true;

    if (email.isEmpty) {
      setState(() {
        _emailError = 'El email no puede estar vacío';
      });
      isValid = false;
    } else if (!isEmail(email)) {
      setState(() {
        _emailError = 'Formato de email inválido';
      });
      isValid = false;
    } else {
      setState(() {
        _emailError = null;
      });
    }

    if (password.isEmpty) {
      setState(() {
        _passwordError = 'La contraseña no puede estar vacía';
      });
      isValid = false;
    } else {
      setState(() {
        _passwordError = null;
      });
    }

    return isValid;
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<LoginViewModel>(context);

    return Column(
      children: [
        TextField(
          controller: _emailController,
          decoration: InputDecoration(
            labelText: 'Correo electrónico',
            prefixIcon: const Icon(Icons.email),
            errorText: _emailError,
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Contraseña',
            prefixIcon: const Icon(Icons.lock),
            errorText: _passwordError,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Checkbox(
              value: _rememberCredentials,
              onChanged: (value) {
                setState(() {
                  _rememberCredentials = value ?? false;
                });
              },
            ),
            const Text('Recordar usuario'),
          ],
        ),
        const SizedBox(height: 16),
        viewModel.isLoading
            ? Center(child: CircularProgressIndicator())
            : ElevatedButton(
              onPressed: () async {
                if (_validateFields()) {
                  final email = _emailController.text.trim();
                  final password = _passwordController.text;

                  final success = await viewModel.login(
                    email,
                    password,
                    rememberMe: _rememberCredentials,
                  );

                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Login exitoso')),
                    );
                    _handleLoginSuccess(context);
                  } else if (viewModel.errorMessage != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(viewModel.errorMessage!)),
                    );
                  }
                }
              },
              child: const Text('Iniciar sesión'),
            ),
        const SizedBox(height: 16),
        _isLoading
            ? SizedBox(
              height: 20,
              width: 20,
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            )
            : TextButton(
              onPressed: _abrirResetPasswordURL,
              child: const Text('¿Olvidaste tu contraseña?'),
            ),
      ],
    );
  }

  void _handleLoginSuccess(BuildContext context) {
    context.go('/dashboard');
  }
}
