import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:foodflow_app/features/shared/widgets/responsive_scaffold_widget.dart';
import '../products_viewmodel/product_detail_view_model.dart';

class ProductDetailScreen extends StatelessWidget {
  final int productoId;

  const ProductDetailScreen({Key? key, required this.productoId})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final viewModel = ProductDetailViewModel();
        viewModel.cargarProducto(productoId);
        return viewModel;
      },
      child: Consumer<ProductDetailViewModel>(
        builder: (context, viewModel, _) {
          return ResponsiveScaffold(
            title: 'Detalle del Producto',
            body: _buildBody(context, viewModel),
            showBackButton: true,
            actions: _buildActions(context, viewModel),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, ProductDetailViewModel viewModel) {
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
              onPressed: () => viewModel.cargarProducto(productoId),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    final producto = viewModel.producto;
    if (producto == null) {
      return const Center(child: Text('No se encontró el producto'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  child:
                      producto.getImagenUrlCompleta() != null
                          ? Image.network(
                            producto.getImagenUrlCompleta()!,
                            height: 250,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (context, error, stackTrace) => Container(
                                  height: 250,
                                  color: Colors.grey[300],
                                  child: const Icon(
                                    Icons.image_not_supported,
                                    size: 50,
                                  ),
                                ),
                          )
                          : Container(
                            height: 250,
                            color: Colors.grey[300],
                            child: const Icon(Icons.image, size: 50),
                          ),
                ),
              ),
              if (producto.imagenQrUrl != null)
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            const Text(
                              'Código QR',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Image.network(
                              producto.getImagenQrUrlCompleta() ?? '',
                              height: 150,
                              fit: BoxFit.contain,
                              errorBuilder:
                                  (context, error, stackTrace) => Container(
                                    height: 150,
                                    color: Colors.grey[300],
                                    child: const Icon(
                                      Icons.qr_code_2,
                                      size: 50,
                                    ),
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    producto.nombre,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (producto.categoriaNombre != null)
                    Chip(
                      label: Text(
                        producto.categoriaNombre!,
                        style: const TextStyle(color: Colors.black),
                      ),
                      backgroundColor: Colors.amber.shade100,
                    ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoItem(
                          context,
                          'Precio Final',
                          '€${producto.precioFinal.toStringAsFixed(2)}',
                          Colors.green.shade100,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildInfoItem(
                          context,
                          'Estado',
                          producto.isActive ? 'Activo' : 'Inactivo',
                          producto.isActive
                              ? Colors.green.shade100
                              : Colors.red.shade100,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoItem(
                          context,
                          'Precio Base',
                          '€${producto.precio.toStringAsFixed(2)}',
                          Colors.blue.shade50,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildInfoItem(
                          context,
                          'Impuestos',
                          '${producto.impuestos.toStringAsFixed(2)}%',
                          Colors.blue.shade50,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildInfoItem(
                    context,
                    'Unidad de Medida',
                    producto.unidadMedida,
                    Colors.amber.shade50,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Descripción',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    producto.descripcion ?? 'Sin descripción',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          if (viewModel.puedeEditarProducto)
            Padding(
              padding: const EdgeInsets.only(top: 24.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.push('/products/edit/${producto.id}');
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text(
                    'Editar Producto',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context,
    String label,
    String value,
    Color backgroundColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: Colors.black),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildActions(
    BuildContext context,
    ProductDetailViewModel viewModel,
  ) {
    if (!viewModel.puedeEditarProducto || viewModel.producto == null) {
      return [];
    }

    return [
      IconButton(
        icon: const Icon(Icons.edit),
        onPressed: () {
          context.push('/products/edit/${viewModel.producto!.id}');
        },
      ),
    ];
  }
}
