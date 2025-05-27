import 'package:flutter/material.dart';
import 'package:foodflow_app/features/warehouse/warehouse_view/widgets/q_r_stock_update_widget.dart';
import 'package:provider/provider.dart';
import 'package:foodflow_app/features/shared/widgets/responsive_scaffold_widget.dart';

import '../warehouse_viewmodel/modify_by_qr_viewmodel.dart';

class ModifyByQRScreen extends StatelessWidget {
  const ModifyByQRScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ModifyByQRViewModel(),
      child: Consumer<ModifyByQRViewModel>(
        builder: (context, viewModel, _) {
          return ResponsiveScaffold(
            title: 'Modificar por QR',
            body: _buildBody(context, viewModel),
            showBackButton: true,
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, ModifyByQRViewModel viewModel) {
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

    if (viewModel.error != null && !viewModel.puedeModificarInventario) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              viewModel.error!,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (viewModel.operacionExitosa) {
      return _buildOperacionExitosa(context, viewModel);
    }

    if (viewModel.cameraActive) {
      return QRStockUpdateWidget(
        onQRDetected: (qrValue) {
          viewModel.procesarCodigoQR(qrValue);
        },
        onCancelPressed: () {
          viewModel.desactivarCamara();
        },
      );
    }

    return _buildForm(context, viewModel);
  }

  Widget _buildForm(BuildContext context, ModifyByQRViewModel viewModel) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Modificar Stock mediante QR',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Configura la operación antes de escanear el QR del producto',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 32),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tipo de operación',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildOperacionButton(
                          context,
                          title: 'Sumar',
                          icon: Icons.add_circle,
                          isSelected: viewModel.esSuma,
                          color: Colors.green,
                          onTap: () => viewModel.cambiarTipoOperacion(true),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildOperacionButton(
                          context,
                          title: 'Restar',
                          icon: Icons.remove_circle,
                          isSelected: !viewModel.esSuma,
                          color: Colors.red,
                          onTap: () => viewModel.cambiarTipoOperacion(false),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Cantidad a modificar',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: viewModel.cantidad.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Cantidad',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.production_quantity_limits),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final cantidad = int.tryParse(value);
                      if (cantidad != null && cantidad > 0) {
                        viewModel.establecerCantidad(cantidad);
                      }
                    },
                  ),
                  if (viewModel.error != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      viewModel.error!,
                      style: TextStyle(color: Colors.red.shade700),
                    ),
                  ],
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed:
                          viewModel.puedeModificarInventario
                              ? () => viewModel.activarCamara()
                              : null,
                      icon: const Icon(Icons.qr_code_scanner),
                      label: const Text(
                        'Escanear QR',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  if (!viewModel.puedeModificarInventario) ...[
                    const SizedBox(height: 16),
                    Text(
                      'No tienes permiso para modificar el inventario',
                      style: TextStyle(color: Colors.red.shade700),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOperacionExitosa(
    BuildContext context,
    ModifyByQRViewModel viewModel,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.check_circle_outline,
            color: Colors.green,
            size: 100,
          ),
          const SizedBox(height: 24),
          const Text(
            '¡Operación Exitosa!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            'Has ${viewModel.esSuma ? "sumado" : "restado"} ${viewModel.cantidad} unidades',
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => viewModel.reiniciar(),
            icon: const Icon(Icons.replay),
            label: const Text('Realizar otra operación'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOperacionButton(
    BuildContext context, {
    required String title,
    required IconData icon,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : Colors.transparent,
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 40),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? color : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
