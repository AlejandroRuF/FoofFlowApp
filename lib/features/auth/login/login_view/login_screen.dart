import 'package:flutter/material.dart';
import 'package:validators/validators.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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
      } else if (!regex.hasMatch(password)) {
        _passwordError =
            'Debe tener al menos 8 caracteres,\nuna mayúscula, una minúscula,\nun número y un símbolo especial seguro.';
        _isPasswordValid = false;
      } else {
        _passwordError = null;
        _isPasswordValid = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}
