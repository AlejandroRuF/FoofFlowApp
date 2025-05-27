import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:foodflow_app/features/products/products_view/widgets/kitchen_card_widget.dart';
import 'package:foodflow_app/features/shared/widgets/responsive_scaffold_widget.dart';

import '../products_viewmodel/kitchen_list_view_model.dart';

class KitchenListScreen extends StatelessWidget {
  const KitchenListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => KitchenListViewModel(),
      child: Consumer<KitchenListViewModel>(
        builder: (context, viewModel, _) {
          return ResponsiveScaffold(
            title: 'Cocinas Centrales',
            body: _buildBody(context, viewModel),
            initialIndex: 2,
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, KitchenListViewModel viewModel) {
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
              onPressed: () => viewModel.cargarCocinaCentrales(),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    final cocinas = viewModel.cocinasFiltradas;

    if (cocinas.isEmpty) {
      return const Center(child: Text('No se encontraron cocinas centrales'));
    }

    return Column(
      children: [
        _buildSearchBar(context, viewModel),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: cocinas.length,
            itemBuilder: (context, index) {
              final cocina = cocinas[index];
              return KitchenCardWidget(
                kitchen: cocina,
                onTap: () {
                  context.push('/products/kitchen/${cocina.id}');
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context, KitchenListViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Buscar cocina central...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onChanged: viewModel.establecerBusqueda,
      ),
    );
  }
}
