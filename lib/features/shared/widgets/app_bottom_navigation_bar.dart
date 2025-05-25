import 'package:flutter/material.dart';

class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int index) onItemSelected;

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    int displayIndex = currentIndex;
    if (displayIndex > 4) {
      displayIndex = -1;
    }

    return NavigationBar(
      selectedIndex: displayIndex < 0 ? 0 : displayIndex,
      indicatorColor:
          displayIndex < 0 ? Colors.transparent : primaryColor.withOpacity(0.2),
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      backgroundColor: Theme.of(context).colorScheme.surface,
      onDestinationSelected: (index) {
        if (index != currentIndex) {
          onItemSelected(index);
        }
      },
      destinations: [
        _buildDestination(
          context,
          Icons.dashboard,
          'Dashboard',
          0,
          displayIndex,
        ),
        _buildDestination(
          context,
          Icons.outbox_rounded,
          'Pedidos',
          1,
          displayIndex,
        ),
        _buildDestination(
          context,
          Icons.restaurant,
          'Productos',
          2,
          displayIndex,
        ),
        _buildDestination(
          context,
          Icons.inventory_2,
          'Almacén',
          3,
          displayIndex,
        ),
        _buildDestination(
          context,
          Icons.report_problem,
          'Incidencias',
          4,
          displayIndex,
        ),
      ],
    );
  }

  NavigationDestination _buildDestination(
    BuildContext context,
    IconData icon,
    String label,
    int index,
    int currentIndex,
  ) {
    final isSelected = index == currentIndex;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return NavigationDestination(
      icon: Icon(icon, color: isSelected ? primaryColor : null),
      selectedIcon: Icon(icon, color: primaryColor),
      label: label,
    );
  }
}
