import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:foodflow_app/core/services/auth_service.dart';
import 'package:foodflow_app/features/auth/login/login_view/login_screen.dart';
import 'package:foodflow_app/features/dashboard/dashboard_view/dashboard_screen.dart';
import 'package:foodflow_app/features/dashboard/dashboard_viewmodel/dashboard_viewmodel.dart';
import 'package:foodflow_app/features/auth/login/login_viewmodel/login_viewmodel.dart';
import 'package:foodflow_app/core/theme/theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
    overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
        ChangeNotifierProvider(create: (_) => DashboardViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FoodFlow App',
      theme: FoodFlowTheme.lightTheme,
      darkTheme: FoodFlowTheme.darkTheme,
      themeMode: ThemeMode.system,
      builder: (context, child) {
        return MediaQuery(data: MediaQuery.of(context), child: child!);
      },
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const DashboardScreen(),
      },
      initialRoute: '/',
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    bool isLoggedIn = await AuthService().attemptAutoLogin();

    if (mounted) {
      if (isLoggedIn) {
        Navigator.of(context).pushReplacementNamed('/dashboard');
      } else {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<FoodFlowColors>()!;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.food_bank, size: 100, color: colors.primary),
            SizedBox(height: 24),
            Text(
              'FoodFlow',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: colors.primary,
              ),
            ),
            SizedBox(height: 32),
            CircularProgressIndicator(color: colors.primary),
          ],
        ),
      ),
    );
  }
}
