import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/login/login_view/login_screen.dart';
import '../../features/cart/cart_view/cart_detail_screen.dart';
import '../../features/cart/cart_view/cart_list_screen.dart';
import '../../features/dashboard/dashboard_view/dashboard_screen.dart';
import '../../features/incidents/incidents_view/IncidentFormScreen.dart';
import '../../features/incidents/incidents_view/Incidents_screen.dart';
import '../../features/incidents/incidents_view/incident_detail_screen.dart';
import '../../features/orders/orders_view/order_list_screen.dart';
import '../../features/orders/orders_view/order_detail_screen.dart';
import '../../features/orders/orders_view/order_form_screen.dart';
import '../../features/products/products_view/kitchen_list_screen.dart';
import '../../features/products/products_view/product_list_screen.dart';
import '../../features/products/products_view/product_form_screen.dart';
import '../../features/products/products_view/product_detail_screen.dart';
import '../../features/warehouse/warehouse_view/warehouse_management_screen.dart';
import '../../features/warehouse/warehouse_view/inventory_screen_widget.dart';
import '../../features/warehouse/warehouse_view/modify_by_q_r_screen.dart';
import '../../features/profile/profile_view/profile_screen.dart';
import '../../features/profile/profile_view/edit_profile_screen.dart';
import '../../main.dart';

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

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
      builder: (context, state) => const KitchenListScreen(),
      routes: [
        GoRoute(
          path: 'kitchen/:kitchenId',
          name: 'productsByKitchen',
          builder: (context, state) {
            final kitchenId = state.pathParameters['kitchenId']!;
            return ProductListScreen(cocinaCentralId: int.parse(kitchenId));
          },
        ),

        GoRoute(
          path: 'all',
          name: 'allProducts',
          builder: (context, state) => const ProductListScreen(),
        ),

        GoRoute(
          path: 'new',
          name: 'newProduct',
          builder: (context, state) => const ProductFormScreen(),
        ),

        GoRoute(
          path: 'detail/:productId',
          name: 'productDetail',
          builder: (context, state) {
            final productId = state.pathParameters['productId']!;
            return ProductDetailScreen(productoId: int.parse(productId));
          },
        ),

        GoRoute(
          path: 'edit/:productId',
          name: 'editProduct',
          builder: (context, state) {
            final productId = state.pathParameters['productId']!;
            return ProductFormScreen(productoId: int.parse(productId));
          },
        ),
      ],
    ),

    GoRoute(
      path: '/inventory',
      name: 'inventory',
      builder: (context, state) => const WarehouseScreen(),
      routes: [
        GoRoute(
          path: 'list',
          name: 'inventoryList',
          builder: (context, state) => const InventoryScreen(),
        ),
        GoRoute(
          path: 'qr',
          name: 'modifyByQR',
          builder: (context, state) => const ModifyByQRScreen(),
        ),
      ],
    ),

    GoRoute(
      path: '/profile',
      name: 'profile',
      builder: (context, state) => const ProfileScreen(),
      routes: [
        GoRoute(
          path: 'edit',
          name: 'editProfile',
          builder: (context, state) {
            final usuario = state.extra as dynamic;
            return EditProfileScreen(usuario: usuario);
          },
        ),
      ],
    ),

    GoRoute(
      path: '/incidents',
      name: 'incidents',
      builder: (context, state) => const IncidentsScreen(),
      routes: [
        GoRoute(
          path: 'detail/:id',
          name: 'incidentDetail',
          builder: (context, state) {
            final incidenciaId = state.pathParameters['id']!;
            return IncidentDetailScreen(incidenciaId: int.parse(incidenciaId));
          },
        ),
        GoRoute(
          path: 'new',
          name: 'newIncident',
          builder: (context, state) => const IncidentFormScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/cart',
      name: 'cart-list',
      builder: (context, state) => const CartListScreen(),
      routes: [
        GoRoute(
          path: 'detail/:carritoId',
          name: 'cart-detail',
          builder: (context, state) {
            final carritoId = int.tryParse(
              state.pathParameters['carritoId'] ?? '',
            );
            if (carritoId == null) {
              return const Scaffold(
                body: Center(child: Text('ID de carrito inválido')),
              );
            }
            return CartDetailScreen(carritoId: carritoId);
          },
        ),
      ],
    ),
  ],
);
