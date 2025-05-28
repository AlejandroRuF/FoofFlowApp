import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:foodflow_app/features/auth/login/login_viewmodel/login_viewmodel.dart';
import 'package:foodflow_app/features/shared/widgets/app_bottom_navigation_bar.dart';
import 'package:foodflow_app/features/shared/widgets/main_navigator_bar.dart';
import 'package:foodflow_app/core/services/event_bus_service.dart';

class ResponsiveScaffold extends StatefulWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? bottomSheet;
  final int initialIndex;
  final bool showBackButton;

  const ResponsiveScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.bottomSheet,
    this.initialIndex = 0,
    this.showBackButton = false,
  });

  @override
  State<ResponsiveScaffold> createState() => _ResponsiveScaffoldState();
}

class _ResponsiveScaffoldState extends State<ResponsiveScaffold> {
  late int _currentIndex;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final EventBusService _eventBus = EventBusService();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateCurrentIndex();
  }

  void _updateCurrentIndex() {
    final currentLocation = GoRouterState.of(context).matchedLocation;

    if (currentLocation.startsWith('/dashboard')) {
      _currentIndex = 0;
    } else if (currentLocation.startsWith('/orders')) {
      _currentIndex = 1;
    } else if (currentLocation.startsWith('/products')) {
      _currentIndex = 2;
    } else if (currentLocation.startsWith('/inventory')) {
      _currentIndex = 3;
    } else if (currentLocation.startsWith('/incidents')) {
      _currentIndex = 4;
    } else if (currentLocation.startsWith('/profile')) {
      _currentIndex = 5;
    }
  }

  void _onItemSelected(int index) {
    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        context.go('/dashboard');
        break;
      case 1:
        context.go('/orders');
        break;
      case 2:
        context.go('/products');
        break;
      case 3:
        context.go('/inventory');
        break;
      case 4:
        context.go('/incidents');
        break;
      case 5:
        context.go('/profile');
        break;
    }
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Cerrar sesión'),
            content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Cerrar sesión'),
              ),
            ],
          ),
    );

    if (confirm == true) {
      final loginViewModel = Provider.of<LoginViewModel>(
        context,
        listen: false,
      );
      final success = await loginViewModel.logout();

      if (success) {
        if (mounted) {
          context.go('/login');
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                loginViewModel.errorMessage ?? 'Error al cerrar sesión',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _handleBackNavigation() {
    final currentLocation = GoRouterState.of(context).matchedLocation;
    RefreshEventType? eventType;

    if (currentLocation.contains('/orders/')) {
      eventType = RefreshEventType.orders;
    } else if (currentLocation.contains('/products/')) {
      eventType = RefreshEventType.products;
    } else if (currentLocation.contains('/inventory/')) {
      eventType = RefreshEventType.inventory;
    } else if (currentLocation.contains('/incidents/')) {
      eventType = RefreshEventType.incidents;
    } else if (currentLocation.contains('/dashboard/')) {
      eventType = RefreshEventType.dashboard;
    } else if (currentLocation.contains('/profile/')) {
      eventType = RefreshEventType.profile;
    }

    if (eventType != null) {
      _eventBus.publishRefresh(eventType, data: {'source': currentLocation});
    }

    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    final currentLocation = GoRouterState.of(context).matchedLocation;

    final isMainRoute = [
      '/dashboard',
      '/orders',
      '/products',
      '/inventory',
      '/incidents',
      '/profile',
    ].contains(currentLocation);
    final shouldShowBackButton = (!isMainRoute || widget.showBackButton);
    final List<Widget> appBarActions = [];

    if (isSmallScreen) {
      appBarActions.add(
        IconButton(
          icon: const Icon(Icons.person),
          tooltip: 'Perfil',
          onPressed: () => context.go('/profile'),
        ),
      );
    }

    appBarActions.add(
      IconButton(
        icon: const Icon(Icons.shopping_cart),
        tooltip: 'Carrito',
        onPressed: () => context.push('/cart'),
      ),
    );

    appBarActions.add(
      IconButton(
        icon: const Icon(Icons.logout),
        tooltip: 'Cerrar sesión',
        onPressed: _handleLogout,
      ),
    );

    if (widget.actions != null) {
      appBarActions.addAll(widget.actions!);
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(widget.title),
        actions: appBarActions,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 0,
        leading:
            isSmallScreen
                ? shouldShowBackButton
                    ? IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: _handleBackNavigation,
                    )
                    : null
                : shouldShowBackButton
                ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: _handleBackNavigation,
                )
                : IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                ),
        automaticallyImplyLeading: isSmallScreen && !shouldShowBackButton,
      ),
      drawer:
          !isSmallScreen
              ? MainNavigatorBar(
                currentIndex: _currentIndex,
                onItemSelected: _onItemSelected,
              )
              : null,
      body: widget.body,
      bottomNavigationBar:
          isSmallScreen
              ? AppBottomNavBar(
                currentIndex: _currentIndex,
                onItemSelected: _onItemSelected,
              )
              : null,
      floatingActionButton: widget.floatingActionButton,
      floatingActionButtonLocation: widget.floatingActionButtonLocation,
      bottomSheet: widget.bottomSheet,
    );
  }
}
