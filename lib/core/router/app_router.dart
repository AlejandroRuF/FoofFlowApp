import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/login/login_view/login_screen.dart';
import '../../features/dashboard/dashboard_view/dashboard_screen.dart';
import '../../features/orders/orders_view/order_list_screen.dart';
import '../../features/orders/orders_view/order_detail_screen.dart';
import '../../features/orders/orders_view/order_form_screen.dart';
import '../../main.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Productos')),
      body: const Center(child: Text('Pantalla de Productos en desarrollo')),
    );
  }
}

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Almacén')),
      body: const Center(child: Text('Pantalla de Almacén en desarrollo')),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: const Center(child: Text('Pantalla de Perfil en desarrollo')),
    );
  }
}

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Página no encontrada')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('La ruta solicitada no existe'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.go('/dashboard'),
              child: const Text('Volver al Dashboard'),
            ),
          ],
        ),
      ),
    );
  }
}

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  debugLogDiagnostics: true,
  errorBuilder: (context, state) => const NotFoundScreen(),
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),

    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),

    GoRoute(
      path: '/dashboard',
      name: 'dashboard',
      builder: (context, state) => const DashboardScreen(),
    ),

    GoRoute(
      path: '/orders',
      name: 'orders',
      builder: (context, state) => const OrderListScreen(),
      routes: [
        GoRoute(
          path: 'detail/:orderId',
          name: 'orderDetail',
          builder: (context, state) {
            final orderId = state.pathParameters['orderId']!;
            return OrderDetailScreen(pedidoId: int.parse(orderId));
          },
        ),

        GoRoute(
          path: 'new',
          name: 'newOrder',
          builder: (context, state) => const OrderFormScreen(pedidoId: 0),
        ),

        GoRoute(
          path: 'edit/:orderId',
          name: 'editOrder',
          builder: (context, state) {
            final orderId = state.pathParameters['orderId']!;
            return OrderFormScreen(pedidoId: int.parse(orderId));
          },
        ),
      ],
    ),

    GoRoute(
      path: '/products',
      name: 'products',
      builder: (context, state) => const ProductsScreen(),
    ),

    GoRoute(
      path: '/inventory',
      name: 'inventory',
      builder: (context, state) => const InventoryScreen(),
    ),

    GoRoute(
      path: '/profile',
      name: 'profile',
      builder: (context, state) => const ProfileScreen(),
    ),
  ],
);
