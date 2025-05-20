import 'package:flutter/material.dart';
import 'package:foodflow_app/features/shared/widgets/app_bottom_navigation_bar.dart';
import 'package:foodflow_app/features/shared/widgets/main_navigator_bar.dart';

class ResponsiveScaffold extends StatefulWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? bottomSheet;

  const ResponsiveScaffold({
    Key? key,
    required this.title,
    required this.body,
    this.actions,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.bottomSheet,
  }) : super(key: key);

  @override
  State<ResponsiveScaffold> createState() => _ResponsiveScaffoldState();
}

class _ResponsiveScaffoldState extends State<ResponsiveScaffold> {
  int _currentIndex = 0;

  void _onItemSelected(int index) {
    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0: // Dashboard
        if (ModalRoute.of(context)?.settings.name != '/dashboard') {
          Navigator.of(context).pushReplacementNamed('/dashboard');
        }
        break;
      case 1:
        break;
      case 2:
        break;
      case 3:
        break;
      case 4:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(title: Text(widget.title), actions: widget.actions),
      drawer: isSmallScreen ? null : const MainNavigatorBar(),
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
