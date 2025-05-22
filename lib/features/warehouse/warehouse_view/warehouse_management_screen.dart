import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:foodflow_app/features/shared/widgets/responsive_scaffold_widget.dart';
import 'package:foodflow_app/features/warehouse/warehouse_view/widgets/warehouse_card_widget.dart';
import '../warehouse_viewmodel/warehouseView_model.dart';

class WarehouseScreen extends StatelessWidget {
  const WarehouseScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => WarehouseViewModel(),
      child: Consumer<WarehouseViewModel>(
        builder: (context, viewModel, _) {
          return ResponsiveScaffold(
            title: 'Almacén',
            body: _buildBody(context, viewModel),
            initialIndex: 3,
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, WarehouseViewModel viewModel) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final errorIconColor =
        isDarkMode ? Colors.red.shade300 : Colors.red.shade400;

    if (viewModel.state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: errorIconColor),
            const SizedBox(height: 16),
            Text(
              viewModel.state.error!,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (viewModel.tienePermisoVerInventario)
              ElevatedButton(
                onPressed: () => viewModel.cargarDatos(),
                child: const Text('Reintentar'),
              ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gestión de Almacén',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Selecciona una opción para gestionar tu inventario',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 32),
          LayoutBuilder(
            builder: (context, constraints) {
              return constraints.maxWidth > 600
                  ? _buildHorizontalOptions(context, viewModel)
                  : _buildVerticalOptions(context, viewModel);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalOptions(
    BuildContext context,
    WarehouseViewModel viewModel,
  ) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    final primaryColor = theme.colorScheme.primary;

    return Row(
      children: [
        Expanded(
          child: WarehouseCardWidget(
            title: 'Ver Inventario',
            description: 'Gestión manual y visual de los productos almacenados',
            icon: Icons.inventory,
            iconColor: primaryColor,
            isEnabled: viewModel.tienePermisoVerInventario,
            onTap: () => context.push('/inventory/list'),
            isDarkMode: isDarkMode,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: WarehouseCardWidget(
            title: 'Modificar por QR',
            description:
                'Modificación rápida y segura del stock escaneando el código QR',
            icon: Icons.qr_code_scanner,
            iconColor: primaryColor,
            isEnabled: viewModel.tienePermisoModificarInventario,
            onTap: () => context.push('/inventory/qr'),
            isDarkMode: isDarkMode,
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalOptions(
    BuildContext context,
    WarehouseViewModel viewModel,
  ) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    final primaryColor = theme.colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        WarehouseCardWidget(
          title: 'Ver Inventario',
          description: 'Gestión manual y visual de los productos almacenados',
          icon: Icons.inventory,
          iconColor: primaryColor,
          isEnabled: viewModel.tienePermisoVerInventario,
          onTap: () => context.push('/inventory/list'),
          isDarkMode: isDarkMode,
        ),
        const SizedBox(height: 16),
        WarehouseCardWidget(
          title: 'Modificar por QR',
          description:
              'Modificación rápida y segura del stock escaneando el código QR',
          icon: Icons.qr_code_scanner,
          iconColor: primaryColor,
          isEnabled: viewModel.tienePermisoModificarInventario,
          onTap: () => context.push('/inventory/qr'),
          isDarkMode: isDarkMode,
        ),
      ],
    );
  }
}
