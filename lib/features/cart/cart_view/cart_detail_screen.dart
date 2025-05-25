import 'package:flutter/material.dart';
import 'package:foodflow_app/features/cart/cart_view/widgets/card_product_widget.dart';
import 'package:provider/provider.dart';
import 'package:foodflow_app/features/cart/cart_viewmodel/cart_detail_viewmodel.dart';
import 'package:foodflow_app/models/pedido_producto_model.dart';
import 'package:foodflow_app/features/shared/widgets/responsive_scaffold_widget.dart';

class CartDetailScreen extends StatelessWidget {
  final int carritoId;

  const CartDetailScreen({Key? key, required this.carritoId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CartDetailViewModel()..cargarCarritoDetalle(carritoId),
      child: const _CartDetailBody(),
    );
  }
}

class _CartDetailBody extends StatelessWidget {
  const _CartDetailBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<CartDetailViewModel>(context);
    final carrito = viewModel.carrito;

    if (viewModel.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/icons/app_icon.png', width: 100, height: 100),
            SizedBox(height: 24),
            CircularProgressIndicator(),
          ],
        ),
      );
    }

    if (viewModel.error != null) {
      return Center(
        child: Text(
          'Error: ${viewModel.error}',
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    if (carrito == null) {
      return const Center(child: Text('Carrito no encontrado'));
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
                    carrito.productos.isEmpty
                        ? null
                        : () async {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Funcionalidad no implementada en el backend',
                              ),
                            ),
                          );
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
  ) {
    final viewModel = Provider.of<CartDetailViewModel>(context, listen: false);
    final carrito = viewModel.carrito;
    if (carrito == null) return;
    final productosActualizados = List<PedidoProducto>.from(carrito.productos);
    final idx = productosActualizados.indexWhere((p) => p.id == producto.id);
    if (idx != -1) {
      final p = productosActualizados[idx];
      productosActualizados[idx] = p.copyWith(cantidad: p.cantidad + delta);
      viewModel.actualizarCarrito(
        carrito.copyWith(productos: productosActualizados),
      );
    }
  }

  void _eliminarProducto(BuildContext context, PedidoProducto producto) {
    final viewModel = Provider.of<CartDetailViewModel>(context, listen: false);
    final carrito = viewModel.carrito;
    if (carrito == null) return;
    final productosActualizados =
        carrito.productos.where((p) => p.id != producto.id).toList();
    viewModel.actualizarCarrito(
      carrito.copyWith(productos: productosActualizados),
    );
  }
}
