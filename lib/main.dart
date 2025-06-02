import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:foodflow_app/core/services/auth_service.dart';
import 'package:foodflow_app/core/router/app_router.dart';
import 'package:foodflow_app/features/dashboard/dashboard_viewmodel/dashboard_viewmodel.dart';
import 'package:foodflow_app/features/auth/login/login_viewmodel/login_viewmodel.dart';
import 'package:foodflow_app/features/orders/orders_viewmodel/order_list_viewmodel.dart';
import 'package:foodflow_app/features/products/products_viewmodel/product_list_view_model.dart';
import 'package:foodflow_app/features/products/products_viewmodel/kitchen_list_view_model.dart';
import 'package:foodflow_app/features/products/products_viewmodel/product_detail_view_model.dart';
import 'package:foodflow_app/features/products/products_viewmodel/product_form_view_model.dart';
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
        ChangeNotifierProvider(create: (_) => OrderListViewModel()),
        ChangeNotifierProvider(create: (_) => ProductListViewModel()),
        ChangeNotifierProvider(create: (_) => KitchenListViewModel()),
        ChangeNotifierProvider(create: (_) => ProductDetailViewModel()),
        ChangeNotifierProvider(create: (_) => ProductFormViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'FoodFlow App',
      theme: FoodFlowTheme.lightTheme,
      darkTheme: FoodFlowTheme.darkTheme,
      themeMode: ThemeMode.system,
      builder: (context, child) {
        return MediaQuery(data: MediaQuery.of(context), child: child!);
      },
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

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
        context.go('/dashboard');
      } else {
        context.go('/login');
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
            Image.asset('assets/icons/app_icon.png', width: 100, height: 100),
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
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
