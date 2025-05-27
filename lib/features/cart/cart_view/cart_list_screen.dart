import 'package:flutter/material.dart';
import 'package:foodflow_app/features/cart/cart_view/widgets/cart_card_widget.dart';
import 'package:foodflow_app/features/cart/cart_viewmodel/cart_list_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:foodflow_app/features/shared/widgets/responsive_scaffold_widget.dart';
import 'package:go_router/go_router.dart';

class CartListScreen extends StatelessWidget {
  const CartListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CartListViewModel(),
      child: const _CartListBody(),
    );
  }
}

class _CartListBody extends StatelessWidget {
  const _CartListBody();

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<CartListViewModel>(context);
    final model = viewModel.model;

    return ResponsiveScaffold(
      title: 'Carritos Activos',
      body: _buildBody(context, model, viewModel),
    );
  }

  Widget _buildBody(BuildContext context, model, CartListViewModel viewModel) {
    if (model.isLoading) {
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

    if (model.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Error: ${model.error}',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => viewModel.cargarCarritos(),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (model.carritos.isEmpty) {
      return const Center(child: Text('No hay carritos activos'));
    }

    return ListView.builder(
      itemCount: model.carritos.length,
      itemBuilder: (context, index) {
        final carrito = model.carritos[index];
        return CartCardWidget(
          carrito: carrito,
          onTap: () => _navegarADetalleCarrito(context, carrito.id),
        );
      },
    );
  }

  void _navegarADetalleCarrito(BuildContext context, int carritoId) {
    context.push('/cart/detail/$carritoId').then((_) {
      Provider.of<CartListViewModel>(context, listen: false).cargarCarritos();
    });
  }
}
