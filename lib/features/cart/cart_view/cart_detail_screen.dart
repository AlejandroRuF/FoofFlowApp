import 'package:flutter/material.dart';
import 'package:foodflow_app/features/cart/cart_view/widgets/card_product_widget.dart';
import 'package:provider/provider.dart';
import 'package:foodflow_app/features/cart/cart_viewmodel/cart_detail_viewmodel.dart';
import 'package:foodflow_app/models/pedido_producto_model.dart';
import 'package:foodflow_app/features/shared/widgets/responsive_scaffold_widget.dart';

class CartDetailScreen extends StatelessWidget {
  final int carritoId;

  const CartDetailScreen({super.key, required this.carritoId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CartDetailViewModel()..cargarCarritoDetalle(carritoId),
      child: _CartDetailBody(carritoId: carritoId),
    );
  }
}

class _CartDetailBody extends StatelessWidget {
  final int carritoId;

  const _CartDetailBody({required this.carritoId});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<CartDetailViewModel>(context);
    final carrito = viewModel.carrito;

    if (viewModel.isLoading) {
      return const ResponsiveScaffold(
        title: 'Cargando...',
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image(
                image: AssetImage('assets/icons/app_icon.png'),
                width: 100,
                height: 100,
              ),
              SizedBox(height: 24),
              CircularProgressIndicator(),
            ],
          ),
        ),
      );
    }

    if (viewModel.error != null) {
      return ResponsiveScaffold(
        title: 'Error',
        body: Center(
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
                onPressed: () => viewModel.cargarCarritoDetalle(carritoId),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    if (carrito == null) {
      return const ResponsiveScaffold(
        title: 'Carrito no encontrado',
        body: Center(child: Text('Carrito no encontrado')),
      );
    }

    final editable = viewModel.puedeEditarCarrito();

    return ResponsiveScaffold(
      title: 'Carrito #${carrito.id}',
      actions: [
        if (viewModel.puedeEliminarCarrito())
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Eliminar carrito',
            onPressed: () async {
              final confirmado =
                  await showDialog<bool>(
                    context: context,
                    builder:
                        (_) => AlertDialog(
                          title: const Text('Eliminar carrito'),
                          content: const Text(
                            '¿Estás seguro de eliminar este carrito?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('Cancelar'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text('Eliminar'),
                            ),
                          ],
                        ),
                  ) ??
                  false;

              if (confirmado) {
                final ok = await viewModel.eliminarCarrito();
                if (ok && context.mounted) {
                  Navigator.of(context).pop();
                }
              }
            },
          ),
      ],
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child:
                  carrito.productos.isEmpty
                      ? const Center(
                        child: Text('No hay productos en el carrito'),
                      )
                      : ListView.builder(
                        itemCount: carrito.productos.length,
                        itemBuilder: (context, index) {
                          final pedidoProducto = carrito.productos[index];
                          final producto =
                              viewModel.productosById[pedidoProducto
                                  .productoId];
                          final actualizando = viewModel
                              .estaActualizandoProducto(
                                pedidoProducto.productoId,
                              );

                          if (actualizando) {
                            return const Card(
                              margin: EdgeInsets.symmetric(
                                vertical: 6,
                                horizontal: 12,
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(12),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                            );
                          }

                          return CartProductWidget(
                            pedidoProducto: pedidoProducto,
                            producto: producto,
                            editable: editable,
                            onAdd:
                                editable
                                    ? () => _modificarCantidad(
                                      context,
                                      pedidoProducto,
                                      1,
                                    )
                                    : null,
                            onRemove:
                                editable && pedidoProducto.cantidad > 1
                                    ? () => _modificarCantidad(
                                      context,
                                      pedidoProducto,
                                      -1,
                                    )
                                    : null,
                            onDelete:
                                editable
                                    ? () => _eliminarProducto(
                                      context,
                                      pedidoProducto,
                                    )
                                    : null,
                          );
                        },
                      ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total:',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '€${carrito.montoTotal.toStringAsFixed(2)}',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (editable)
              ElevatedButton.icon(
                onPressed:
                    carrito.productos.isEmpty || viewModel.isLoading
                        ? null
                        : () async {
                          final resultado = await viewModel.confirmarCarrito();
                          if (resultado && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Carrito confirmado con éxito'),
                              ),
                            );
                            Navigator.of(context).pop();
                          } else if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Error al confirmar el carrito'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                icon: const Icon(Icons.check),
                label: const Text('Confirmar carrito'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  minimumSize: const Size.fromHeight(44),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _modificarCantidad(
    BuildContext context,
    PedidoProducto producto,
    int delta,
  ) async {
    final viewModel = Provider.of<CartDetailViewModel>(context, listen: false);

    final nuevaCantidad = producto.cantidad + delta;

    await viewModel.actualizarCantidadProducto(
      producto.productoId,
      nuevaCantidad,
    );
  }

  void _eliminarProducto(BuildContext context, PedidoProducto producto) async {
    final viewModel = Provider.of<CartDetailViewModel>(context, listen: false);

    final confirmar =
        await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Eliminar producto'),
                content: Text(
                  '¿Seguro que deseas eliminar ${producto.productoNombre} del carrito?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancelar'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Eliminar'),
                  ),
                ],
              ),
        ) ??
        false;

    if (confirmar) {
      await viewModel.eliminarProducto(producto.productoId);
    }
  }
}
