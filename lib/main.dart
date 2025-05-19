import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:foodflow_app/core/services/auth_service.dart';
import 'package:foodflow_app/features/auth/login/login_view/login_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

import 'core/services/api_services.dart';
import 'core/services/user_sesion_service.dart';
import 'features/auth/login/login_viewmodel/login_viewmodel.dart';

void main() async {
  // Aseguramos que la inicialización de Flutter esté completa
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configuramos la orientación de la aplicación
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Inicializar API Services para verificar conectividad
  await ApiServices.init();
  
  // Inicializar la sesión del usuario antes de runApp
  await UserSessionService().init();
  
  // Imprimir información para debug
  ApiServices.debugTokens();
  
  // Intentar auto-login inmediatamente
  final autoLoginSuccess = await AuthService().attemptAutoLogin();
  
  if (kDebugMode) {
    print('Resultado de auto-login en main: $autoLoginSuccess');
  }
  
  runApp(ChangeNotifierProvider(
    create: (_) => LoginViewModel(),
    child: MyApp(inicialmenteLogueado: autoLoginSuccess),
  ));
}

class MyApp extends StatefulWidget {
  final bool inicialmenteLogueado;
  
  const MyApp({super.key, this.inicialmenteLogueado = false});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late bool _isLoggedIn;
  
  @override
  void initState() {
    super.initState();
    _isLoggedIn = widget.inicialmenteLogueado;
    
    if (kDebugMode) {
      print('MyApp inicializado con isLoggedIn: $_isLoggedIn');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FoodFlow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.amber,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: ThemeMode.system,
      home: _isLoggedIn
          ? _buildHomeScreen()
          : const LoginScreen(),
    );
  }
  
  Widget _buildHomeScreen() {
    return Scaffold(
      appBar: AppBar(title: const Text('FoodFlow')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Sesión iniciada correctamente', style: TextStyle(fontSize: 20)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final viewModel = Provider.of<LoginViewModel>(context, listen: false);
                final success = await viewModel.logout();
              
                if (success) {
                  if (kDebugMode) {
                    print('Cierre de sesión exitoso, actualizando estado para mostrar pantalla de login');
                  }
                
                  // En lugar de usar Navigator, simplemente actualizamos el estado
                  setState(() {
                    _isLoggedIn = false;
                  });
                }
              },
              child: const Text('Cerrar sesión'),
            ),
          ],
        ),
      ),
    );
  }
}