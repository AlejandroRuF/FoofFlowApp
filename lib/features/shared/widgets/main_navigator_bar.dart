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
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: (index) {
        if (index != currentIndex) {
          onItemSelected(index);
        }
      },
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
        NavigationDestination(icon: Icon(Icons.shop), label: 'Compra'),
        NavigationDestination(icon: Icon(Icons.receipt_long), label: 'Pedidos'),
        NavigationDestination(
          icon: Icon(Icons.inventory_2),
          label: 'Inventario',
        ),
        NavigationDestination(icon: Icon(Icons.person), label: 'Perfil'),
      ],
    );
  }
}
