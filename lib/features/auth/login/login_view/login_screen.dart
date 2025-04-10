import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:validators/validators.dart';

import '../login_viewmodel/login_viewmodel.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final imageFit = screenWidth >700 ? BoxFit.fitWidth : BoxFit.cover;
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/login_bg.png',
              fit: screenWidth >700 ? screenWidth >900 ? BoxFit.fill : BoxFit.fitWidth : BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              alignment: screenWidth > 700 ? Alignment.center : Alignment.topCenter,
          ),

          // Capa semitransparente
          Container(color: Colors.black.withAlpha((0.4 * 255).round())),

          // Card con el contenido
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
              LoginForm(), // 👇 Formulario separado
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

  String? _emailError;
  String? _passwordError;
  bool _isEmailValid = false;
  bool _isPasswordValid = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateEmail);
    _passwordController.addListener(_validatePassword);
  }

  void _validateEmail() {
    final email = _emailController.text.trim();
    setState(() {
      if (email.isEmpty) {
        _emailError = 'El email no puede estar vacío';
        _isEmailValid = false;
      } else if (!isEmail(email)) {
        _emailError = 'Formato de email inválido';
        _isEmailValid = false;
      } else {
        _emailError = null;
        _isEmailValid = true;
      }
    });
  }

  void _validatePassword() {
    final password = _passwordController.text;
    final regex = RegExp(
      r"""^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&#])(?!.*['";])(?!.*--).{8,}$""",
    );

    setState(() {
      if (password.isEmpty) {
        _passwordError = 'La contraseña no puede estar vacía';
        _isPasswordValid = false;
        // } else if (!regex.hasMatch(password)) {
        //   _passwordError =
        //   'Debe tener al menos 8 caracteres,\nuna mayúscula, una minúscula,\nun número y un símbolo especial seguro.';
        //   _isPasswordValid = false;
      } else {
        _passwordError = null;
        _isPasswordValid = true;
      }
    });
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
        const SizedBox(height: 24),
        viewModel.isLoading
            ? const CircularProgressIndicator()
            : ElevatedButton(
              onPressed:
                  (_isEmailValid && _isPasswordValid)
                      ? () async {
                        final success = await viewModel.login(
                          _emailController.text.trim(),
                          _passwordController.text,
                        );

                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Login exitoso')),
                          );
                        } else if (viewModel.errorMessage != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(viewModel.errorMessage!)),
                          );
                        }
                      }
                      : null,
              child: const Text('Iniciar sesión'),
            ),
      ],
    );
  }
}
