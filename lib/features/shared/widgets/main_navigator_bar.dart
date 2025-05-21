import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../features/auth/login/login_viewmodel/login_viewmodel.dart';

class MainNavigatorBar extends StatelessWidget {
  const MainNavigatorBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildMenuItem(
                  context,
                  title: 'Dashboard',
                  icon: Icons.dashboard,
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                ),
                _buildMenuItem(
                  context,
                  title: 'Pedidos',
                  icon: Icons.outbox_rounded,
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                ),
                _buildMenuItem(
                  context,
                  title: 'Productos',
                  icon: Icons.receipt_long,
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                ),
                _buildMenuItem(
                  context,
                  title: 'Almacen',
                  icon: Icons.inventory_2,
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                ),
                _buildMenuItem(
                  context,
                  title: 'Dashboard',
                  icon: Icons.dashboard,
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                ),
                _buildMenuItem(
                  context,
                  title: 'Perfil',
                  icon: Icons.person,
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
          _buildFooter(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return DrawerHeader(
      decoration: const BoxDecoration(color: Colors.amber),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'FoodFlow',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Sistema de Gestión',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          const Spacer(),
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Colors.amber),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Usuario',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Administrador',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(leading: Icon(icon), title: Text(title), onTap: onTap);
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Cerrar sesión'),
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: const Text('Cerrar sesión'),
                      content: const Text(
                        '¿Estás seguro de que quieres cerrar sesión?',
                      ),
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
                Navigator.of(context).pop();

                final loginViewModel = Provider.of<LoginViewModel>(
                  context,
                  listen: false,
                );
                final success = await loginViewModel.logout();

                if (success) {
                  Navigator.of(context).pushReplacementNamed('/login');
                } else {
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
            },
          ),
        ],
      ),
    );
  }
}
