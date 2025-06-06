import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:foodflow_app/models/user_model.dart';
import 'package:foodflow_app/features/shared/widgets/responsive_scaffold_widget.dart';
import '../warehouse_viewmodel/inventory_viewmodel.dart';

class KitchenSelectionScreen extends StatefulWidget {
  final List<User> cocinas;
  final String userName;

  const KitchenSelectionScreen({
    super.key,
    required this.cocinas,
    required this.userName,
  });

  @override
  State<KitchenSelectionScreen> createState() => _KitchenSelectionScreenState();
}

class _KitchenSelectionScreenState extends State<KitchenSelectionScreen> {
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

  List<User> get cocinasFiltradas {
    final soloCocinaCentral =
        widget.cocinas.where((cocina) {
          return cocina.tipoUsuario == 'cocina_central';
        }).toList();

    if (_busqueda.isEmpty) {
      return soloCocinaCentral;
    }

    return soloCocinaCentral.where((cocina) {
      return cocina.nombre.toLowerCase().contains(_busqueda.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      title: 'Seleccionar Cocina Central',
      showBackButton: true,
      body:
          _isLoading
              ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Cargando productos de la cocina...'),
                  ],
                ),
              )
              : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Usuario seleccionado: ${widget.userName}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _busquedaController,
                          decoration: const InputDecoration(
                            labelText: 'Buscar cocina central por nombre',
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _busqueda = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child:
                        cocinasFiltradas.isEmpty
                            ? const Center(
                              child: Text(
                                'No se encontraron cocinas centrales para este usuario',
                                style: TextStyle(fontSize: 16),
                                textAlign: TextAlign.center,
                              ),
                            )
                            : ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              itemCount: cocinasFiltradas.length,
                              itemBuilder: (context, index) {
                                final cocina = cocinasFiltradas[index];
                                return _buildKitchenCard(cocina);
                              },
                            ),
                  ),
                ],
              ),
    );
  }

  Widget _buildKitchenCard(User cocina) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.amber,
          child:
              cocina.imagen != null
                  ? ClipOval(
                    child: Image.network(
                      cocina.imagen!,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) =>
                              const Icon(Icons.business),
                    ),
                  )
                  : const Icon(Icons.business),
        ),
        title: Text(
          cocina.nombre,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(cocina.email),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Cocina Central',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          _onKitchenSelected(cocina);
        },
      ),
    );
  }

  Future<void> _onKitchenSelected(User cocina) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final productosCocinaCentral = await _viewModel.cargarProductosDeCocina(
        cocina.id,
      );
      if (!mounted) return;

      if (productosCocinaCentral.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'La cocina "${cocina.nombre}" no tiene productos en su inventario',
            ),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        return;
      }

      context.pushNamed(
        'productSelection',
        extra: {
          'productos': productosCocinaCentral,
          'kitchenName': cocina.nombre,
          'kitchenId': cocina.id,
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar productos de la cocina: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
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
}
