import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:foodflow_app/models/user_model.dart';
import 'package:foodflow_app/features/shared/widgets/responsive_scaffold_widget.dart';
import '../warehouse_viewmodel/inventory_viewmodel.dart';

class UserSelectionScreen extends StatefulWidget {
  final List<User> usuarios;

  const UserSelectionScreen({super.key, required this.usuarios});

  @override
  State<UserSelectionScreen> createState() => _UserSelectionScreenState();
}

class _UserSelectionScreenState extends State<UserSelectionScreen> {
  String _busqueda = '';
  final TextEditingController _busquedaController = TextEditingController();
  bool _isLoading = false;
  late InventoryViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = InventoryViewModel();
  }

  @override
  void dispose() {
    _busquedaController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  List<User> get usuariosFiltrados {
    if (_busqueda.isEmpty) {
      return widget.usuarios;
    }

    return widget.usuarios.where((usuario) {
      return usuario.nombre.toLowerCase().contains(_busqueda.toLowerCase()) ||
          usuario.email.toLowerCase().contains(_busqueda.toLowerCase()) ||
          usuario.tipoUsuario.toLowerCase().contains(_busqueda.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      title: 'Seleccionar Usuario',
      showBackButton: true,
      body:
          _isLoading
              ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Cargando cocinas...'),
                  ],
                ),
              )
              : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      controller: _busquedaController,
                      decoration: const InputDecoration(
                        labelText: 'Buscar por nombre de usuario',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _busqueda = value;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child:
                        usuariosFiltrados.isEmpty
                            ? const Center(
                              child: Text(
                                'No se encontraron usuarios',
                                style: TextStyle(fontSize: 16),
                              ),
                            )
                            : ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              itemCount: usuariosFiltrados.length,
                              itemBuilder: (context, index) {
                                final usuario = usuariosFiltrados[index];
                                return _buildUserCard(usuario);
                              },
                            ),
                  ),
                ],
              ),
    );
  }

  Widget _buildUserCard(User usuario) {
    IconData tipoIcon;
    Color tipoColor;

    switch (usuario.tipoUsuario) {
      case 'restaurante':
        tipoIcon = Icons.restaurant;
        tipoColor = Colors.orange;
        break;
      case 'cocina_central':
        tipoIcon = Icons.kitchen;
        tipoColor = Colors.blue;
        break;
      case 'empleado':
        tipoIcon = Icons.person;
        tipoColor = Colors.green;
        break;
      default:
        tipoIcon = Icons.account_circle;
        tipoColor = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: tipoColor,
          child: Icon(tipoIcon, color: Colors.white),
        ),
        title: Text(
          usuario.nombre,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(usuario.nombre),
            Text(usuario.email),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: tipoColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _getTipoUsuarioDisplay(usuario.tipoUsuario),
                style: TextStyle(
                  color: tipoColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          _onUserSelected(usuario);
        },
      ),
    );
  }

  Future<void> _onUserSelected(User usuario) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final cocinas = await _viewModel.obtenerCocinasDeUsuario(usuario.id);

      if (!mounted) return;

      if (cocinas.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se encontraron cocinas para este usuario'),
            backgroundColor: Colors.orange,
          ),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      if (mounted) {
        context.pushNamed(
          'kitchenSelection',
          extra: {'cocinas': cocinas, 'userName': usuario.nombre},
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar cocinas: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _getTipoUsuarioDisplay(String tipo) {
    switch (tipo) {
      case 'restaurante':
        return 'Restaurante';
      case 'cocina_central':
        return 'Cocina Central';
      case 'empleado':
        return 'Empleado';
      default:
        return tipo;
    }
  }
}
