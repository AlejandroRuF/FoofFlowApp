import 'package:flutter/material.dart';
import 'package:foodflow_app/features/auth/login/login_view/login_screen.dart';
import 'package:provider/provider.dart';

import 'features/auth/login/login_viewmodel/login_viewmodel.dart';

void main() {
  runApp(ChangeNotifierProvider(create: (_) =>
      LoginViewModel(),
      child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
      home: LoginScreen(),
    );
  }
}
