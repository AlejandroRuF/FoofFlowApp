import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:foodflow_app/features/shared/widgets/app_bottom_navigation_bar.dart';
import 'package:foodflow_app/features/shared/widgets/main_navigator_bar.dart';

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
    Key? key,
    required this.title,
    required this.body,
    this.actions,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.bottomSheet,
    this.initialIndex = 0,
    this.showBackButton = false,
  }) : super(key: key);

  @override
  State<ResponsiveScaffold> createState() => _ResponsiveScaffoldState();
}

class _ResponsiveScaffoldState extends State<ResponsiveScaffold> {
  late int _currentIndex;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
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
        context.go('/profile');
        break;
    }
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
      '/profile',
    ].contains(currentLocation);
    final shouldShowBackButton = (!isMainRoute || widget.showBackButton);

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(widget.title),
        actions: widget.actions,
        leading:
            isSmallScreen
                ? shouldShowBackButton
                    ? IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => context.pop(),
                    )
                    : null
                : shouldShowBackButton
                ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.pop(),
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
