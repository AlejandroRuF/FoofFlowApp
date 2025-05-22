import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:foodflow_app/features/shared/widgets/responsive_scaffold_widget.dart';
import 'package:foodflow_app/features/warehouse/warehouse_view/widgets/inventory_product_widget.dart';

import '../warehouse_viewmodel/inventory_viewmodel.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => InventoryViewModel(),
      child: Consumer<InventoryViewModel>(
        builder: (context, viewModel, _) {
          return ResponsiveScaffold(
            title: 'Inventario',
            body: _buildBody(context, viewModel),
            showBackButton: true,
            floatingActionButton:
                viewModel.tienePermisoModificarInventario
                    ? FloatingActionButton(
                      onPressed:
                          () => _mostrarDialogoAgregarProducto(
                            context,
                            viewModel,
                          ),
                      child: const Icon(Icons.add),
                    )
                    : null,
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, InventoryViewModel viewModel) {
    if (viewModel.state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              viewModel.state.error!,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (viewModel.tienePermisoVerInventario)
              ElevatedButton(
                onPressed: () => viewModel.cargarInventario(),
                child: const Text('Reintentar'),
              ),
          ],
        ),
      );
    }

    final inventario = viewModel.inventarioFiltrado;

    if (inventario.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text(
              'No hay productos en el inventario',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            if (viewModel.tienePermisoModificarInventario) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed:
                    () => _mostrarDialogoAgregarProducto(context, viewModel),
                icon: const Icon(Icons.add),
                label: const Text('Añadir Producto'),
              ),
            ],
          ],
        ),
      );
    }

    return Column(
      children: [
        _buildFiltros(context, viewModel),
        Expanded(
          child: RefreshIndicator(
            onRefresh: viewModel.cargarInventario,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: inventario.length,
              itemBuilder: (context, index) {
                final item = inventario[index];
                return InventoryProductWidget(
                  inventarioItem: item,
                  puedeModificar: viewModel.tienePermisoModificarInventario,
                  onStockChanged:
                      (nuevoStock) => viewModel.actualizarStockProducto(
                        item.id,
                        nuevoStock,
                      ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFiltros(BuildContext context, InventoryViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Buscar productos...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: viewModel.buscar,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Checkbox(
                value: viewModel.state.mostrarStockBajo,
                onChanged: (_) => viewModel.toggleMostrarStockBajo(),
              ),
              const Text('Mostrar solo productos con stock bajo'),
            ],
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoAgregarProducto(
    BuildContext context,
    InventoryViewModel viewModel,
  ) {
    viewModel.cargarProductosDisponibles();

    int? productoSeleccionadoId;
    int cantidad = 1;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Añadir Producto al Inventario'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<int>(
                      decoration: const InputDecoration(
                        labelText: 'Producto',
                        border: OutlineInputBorder(),
                      ),
                      hint: const Text('Selecciona un producto'),
                      value: productoSeleccionadoId,
                      items:
                          viewModel.state.productosDisponibles.map((producto) {
                            return DropdownMenuItem<int>(
                              value: producto.id,
                              child: Text(producto.nombre),
                            );
                          }).toList(),
                      onChanged: (value) {
                        setState(() {
                          productoSeleccionadoId = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Cantidad',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      initialValue: cantidad.toString(),
                      onChanged: (value) {
                        setState(() {
                          cantidad = int.tryParse(value) ?? 1;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed:
                      productoSeleccionadoId == null
                          ? null
                          : () {
                            viewModel.agregarProductoAlInventario(
                              productoSeleccionadoId!,
                              cantidad,
                            );
                            Navigator.pop(context);
                          },
                  child: const Text('Añadir'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
