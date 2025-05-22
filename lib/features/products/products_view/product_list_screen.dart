import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:foodflow_app/features/products/products_view/widgets/product_card_widget.dart';
import 'package:foodflow_app/features/products/products_view/widgets/product_filters_widget.dart';
import 'package:foodflow_app/features/shared/widgets/responsive_scaffold_widget.dart';

import '../products_viewmodel/product_list_view_model.dart';

class ProductListScreen extends StatelessWidget {
  final int? cocinaCentralId;

  const ProductListScreen({Key? key, this.cocinaCentralId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final viewModel = ProductListViewModel();
        if (cocinaCentralId != null) {
          viewModel.establecerCocinaCentral(cocinaCentralId!);
        } else {
          viewModel.cargarProductos();
        }
        return viewModel;
      },
      child: Consumer<ProductListViewModel>(
        builder: (context, viewModel, _) {
          return ResponsiveScaffold(
            title:
                cocinaCentralId != null ? 'Productos' : 'Todos los Productos',
            body: _buildBody(context, viewModel),
            floatingActionButton: _buildFloatingActionButton(
              context,
              viewModel,
            ),
            initialIndex: 2,
            showBackButton: cocinaCentralId != null,
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, ProductListViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Error: ${viewModel.error}',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => viewModel.cargarProductos(),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    final productos = viewModel.productosFiltrados;

    if (productos.isEmpty) {
      return const Center(child: Text('No se encontraron productos'));
    }

    return Column(
      children: [
        ProductFiltersWidget(
          busqueda: viewModel.busqueda,
          mostrarInactivos: viewModel.mostrarProductosInactivos,
          onBusquedaChanged: viewModel.establecerBusqueda,
          onMostrarInactivosChanged:
              viewModel.esCocinaCentral || viewModel.esAdministrador
                  ? viewModel.toggleMostrarInactivos
                  : null,
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount;
              double aspectRatio;
              if (constraints.maxWidth < 400) {
                crossAxisCount = 2;
                aspectRatio = 0.6;
              } else if (constraints.maxWidth < 700) {
                crossAxisCount = 3;
                aspectRatio = 0.50;
              } else if (constraints.maxWidth < 1000) {
                crossAxisCount = 4;
                aspectRatio = 0.65;
              } else if (constraints.maxWidth < 1300) {
                crossAxisCount = 5;
                aspectRatio = 0.7;
              } else {
                crossAxisCount = 6;
                aspectRatio = 0.7;
              }

              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: aspectRatio,
                ),
                itemCount: productos.length,
                itemBuilder: (context, index) {
                  final producto = productos[index];
                  return ProductCardWidget(
                    product: producto,
                    onTap:
                        viewModel.esRestaurante
                            ? () => _showAddToCartDialog(
                              context,
                              viewModel,
                              producto.id,
                            )
                            : () {
                              context.push('/products/detail/${producto.id}');
                            },
                    tipoUsuario: viewModel.tipoUsuario,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget? _buildFloatingActionButton(
    BuildContext context,
    ProductListViewModel viewModel,
  ) {
    if (viewModel.puedeCrearProductos) {
      return FloatingActionButton(
        onPressed: () {
          context.push('/products/new');
        },
        child: const Icon(Icons.add),
      );
    }
    return null;
  }

  void _showAddToCartDialog(
    BuildContext context,
    ProductListViewModel viewModel,
    int productoId,
  ) {
    final cantidadController = TextEditingController(text: '1');

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Agregar al carrito'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Ingrese la cantidad deseada:'),
                const SizedBox(height: 16),
                TextField(
                  controller: cantidadController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Cantidad',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final cantidad = int.tryParse(cantidadController.text) ?? 0;
                  if (cantidad <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Ingrese una cantidad válida'),
                      ),
                    );
                    return;
                  }

                  Navigator.pop(context);
                  final result = await viewModel.agregarAlCarrito(
                    productoId,
                    cantidad,
                  );

                  if (result) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Producto agregado al carrito'),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          viewModel.error ?? 'Error al agregar al carrito',
                        ),
                      ),
                    );
                  }
                },
                child: const Text('Agregar'),
              ),
            ],
          ),
    );
  }
}
