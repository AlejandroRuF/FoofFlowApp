import 'package:flutter/material.dart';
import 'package:foodflow_app/features/products/products_view/widgets/product_card_widget.dart';
import 'package:foodflow_app/features/products/products_view/widgets/product_filters_widget.dart';
import 'package:foodflow_app/features/shared/widgets/responsive_scaffold_widget.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../products_viewmodel/product_list_view_model.dart';

class ProductListScreen extends StatefulWidget {
  final int? cocinaCentralId;

  const ProductListScreen({super.key, this.cocinaCentralId});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  late ProductListViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ProductListViewModel();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        if (widget.cocinaCentralId != null) {
          _viewModel.establecerCocinaCentral(widget.cocinaCentralId!);
        } else {
          _viewModel.cargarProductos();
        }
        if (_viewModel.muestraPantallaRestaurante) {
          _viewModel.cargarCarrito();
        }
      }
    });
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ProductListViewModel>.value(
      value: _viewModel,
      child: Consumer<ProductListViewModel>(
        builder: (context, viewModel, _) {
          return ResponsiveScaffold(
            title:
                widget.cocinaCentralId != null
                    ? 'Productos'
                    : 'Todos los Productos',
            body: _buildBody(context, viewModel),
            floatingActionButton: _buildFloatingActionButton(
              context,
              viewModel,
            ),
            initialIndex: 2,
            showBackButton: widget.cocinaCentralId != null,
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, ProductListViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Cargando productos...'),
          ],
        ),
      );
    }

    if (viewModel.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
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

    return Column(
      children: [
        ProductFiltersWidget(
          busqueda: viewModel.busquedaTexto,
          categoriaIdSeleccionada: viewModel.categoriaSeleccionadaId,
          precioMin: viewModel.precioMin,
          precioMax: viewModel.precioMax,
          mostrarSoloActivos: viewModel.soloActivos,
          categorias: viewModel.categoriasDisponibles,
          onBusquedaChanged: viewModel.establecerBusquedaTexto,
          onCategoriaChanged: viewModel.establecerCategoria,
          onPrecioMinChanged: viewModel.establecerPrecioMin,
          onPrecioMaxChanged: viewModel.establecerPrecioMax,
          onMostrarSoloActivosChanged: viewModel.establecerSoloActivos,
          onLimpiarFiltros: viewModel.limpiarFiltros,
          onAplicarFiltros: viewModel.aplicarFiltros,
        ),
        if (productos.isEmpty)
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No se encontraron productos',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Intenta ajustar los filtros de búsqueda',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
          )
        else
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                int crossAxisCount;
                double aspectRatio;
                if (constraints.maxWidth < 500) {
                  crossAxisCount = 2;
                  aspectRatio = 0.5;
                } else if (constraints.maxWidth < 800) {
                  crossAxisCount = 3;
                  aspectRatio = 0.55;
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

                return RefreshIndicator(
                  onRefresh: () async {
                    await viewModel.cargarProductos();
                    if (viewModel.muestraPantallaRestaurante) {
                      await viewModel.cargarCarrito();
                    }
                  },
                  child: GridView.builder(
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
                      return Consumer<ProductListViewModel>(
                        builder: (context, vm, child) {
                          return ProductCardWidget(
                            product: producto,
                            onTap:
                                viewModel.muestraPantallaRestaurante
                                    ? null
                                    : () {
                                      context.push(
                                        '/products/detail/${producto.id}',
                                      );
                                    },
                            tipoUsuario: viewModel.tipoUsuario,
                            cantidadEnCarrito: viewModel.model
                                .getCantidadEnCarrito(producto.id),
                            onAgregarAlCarrito:
                                viewModel.muestraPantallaRestaurante
                                    ? (productoId, cantidad) => viewModel
                                        .agregarAlCarrito(productoId, cantidad)
                                    : null,
                            actualizandoCarrito: viewModel.actualizandoCarrito,
                            esRestaurante: viewModel.muestraPantallaRestaurante,
                          );
                        },
                      );
                    },
                  ),
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
    if (viewModel.puedeCrearProductos &&
        !viewModel.muestraPantallaRestaurante) {
      return FloatingActionButton(
        onPressed: () {
          context.push('/products/new');
        },
        tooltip: 'Crear producto',
        child: const Icon(Icons.add),
      );
    }
    return null;
  }
}
