import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:foodflow_app/features/orders/orders_view/order_form_screen.dart';
import 'package:foodflow_app/features/orders/orders_viewmodel/order_detail_viewmodel.dart';
import 'package:foodflow_app/features/shared/widgets/responsive_scaffold_widget.dart';
import 'package:foodflow_app/models/pedido_producto_model.dart';

class OrderDetailScreen extends StatelessWidget {
  final int pedidoId;

  const OrderDetailScreen({Key? key, required this.pedidoId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final viewModel = OrderDetailViewModel();
        viewModel.cargarPedidoDetalle(pedidoId);
        return viewModel;
      },
      child: Consumer<OrderDetailViewModel>(
        builder: (context, viewModel, _) {
          return ResponsiveScaffold(
            title: 'Detalle de Pedido #$pedidoId',
            body: _buildBody(context, viewModel),
            floatingActionButton: _buildFloatingActionButton(
              context,
              viewModel,
            ),
            showBackButton: true,
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, OrderDetailViewModel viewModel) {
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
              onPressed: () => viewModel.cargarPedidoDetalle(pedidoId),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    final pedido = viewModel.pedido;
    if (pedido == null) {
      return const Center(child: Text('No se encontró el pedido'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEstadoCard(context, pedido.estado),
          _buildInfoGeneralCard(context, pedido),
          _buildFechasCard(context, pedido),
          _buildProductosCard(context, pedido.productos),
          if (pedido.notas != null && pedido.notas!.isNotEmpty)
            _buildNotasCard(context, pedido.notas!),
          if (pedido.motivoCancelacion != null &&
              pedido.motivoCancelacion!.isNotEmpty)
            _buildMotivoCancelacionCard(context, pedido.motivoCancelacion!),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildEstadoCard(BuildContext context, String estado) {
    Color backgroundColor;
    String estadoText;

    switch (estado) {
      case 'pendiente':
        backgroundColor = Colors.orange;
        estadoText = 'Pendiente';
        break;
      case 'en_proceso':
        backgroundColor = Colors.blue;
        estadoText = 'En Proceso';
        break;
      case 'enviado':
        backgroundColor = Colors.purple;
        estadoText = 'Enviado';
        break;
      case 'completado':
        backgroundColor = Colors.green;
        estadoText = 'Completado';
        break;
      case 'cancelado':
        backgroundColor = Colors.red;
        estadoText = 'Cancelado';
        break;
      default:
        backgroundColor = Colors.grey;
        estadoText = estado.replaceAll('_', ' ');
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Estado del Pedido',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                estadoText,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoGeneralCard(BuildContext context, dynamic pedido) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Información General',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Restaurante', pedido.restauranteNombre),
            _buildInfoRow('Cocina Central', pedido.cocinaCentralNombre),
            _buildInfoRow(
              'Tipo de Pedido',
              _formatTipoPedido(pedido.tipoPedido),
            ),
            _buildInfoRow('Total', '€${pedido.montoTotal.toStringAsFixed(2)}'),
            if (pedido.urgente)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.priority_high,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'PEDIDO URGENTE',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFechasCard(BuildContext context, dynamic pedido) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Fechas', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            _buildInfoRow('Fecha de Pedido', _formatDate(pedido.fechaPedido)),
            if (pedido.fechaEntregaEstimada != null)
              _buildInfoRow(
                'Entrega Estimada',
                _formatDate(pedido.fechaEntregaEstimada!),
              ),
            if (pedido.fechaEntregaReal != null)
              _buildInfoRow(
                'Entrega Real',
                _formatDate(pedido.fechaEntregaReal!),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductosCard(
    BuildContext context,
    List<PedidoProducto> productos,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Productos',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  '${productos.length} artículos',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            ...productos
                .map((producto) => _buildProductoItem(context, producto))
                .toList(),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('Total:', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(width: 8),
                Text(
                  '€${_calcularTotal(productos).toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductoItem(BuildContext context, PedidoProducto producto) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  producto.productoNombre,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Precio unitario: €${producto.precioUnitario.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '${producto.cantidad}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              '€${(producto.cantidad * producto.precioUnitario).toStringAsFixed(2)}',
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotasCard(BuildContext context, String notas) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Notas', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(notas),
          ],
        ),
      ),
    );
  }

  Widget _buildMotivoCancelacionCard(BuildContext context, String motivo) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Motivo de Cancelación',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: Colors.red),
            ),
            const SizedBox(height: 8),
            Text(motivo, style: TextStyle(color: Colors.red.shade700)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget? _buildFloatingActionButton(
    BuildContext context,
    OrderDetailViewModel viewModel,
  ) {
    final pedido = viewModel.pedido;
    if (pedido == null) return null;

    if (pedido.estado == 'completado' || pedido.estado == 'cancelado') {
      return null;
    }

    return FloatingActionButton.extended(
      onPressed: () => _navegarAFormularioEdicion(context, pedido.id),
      label: const Text('Editar Pedido'),
      icon: const Icon(Icons.edit),
    );
  }

  void _navegarAFormularioEdicion(BuildContext context, int pedidoId) {
    context.push('/orders/edit/$pedidoId').then((_) {
      Provider.of<OrderDetailViewModel>(
        context,
        listen: false,
      ).cargarPedidoDetalle(pedidoId);
    });
  }

  void _showCancelacionDialog(
    BuildContext context,
    OrderDetailViewModel viewModel,
  ) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Cancelar Pedido'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Por favor, indique el motivo de la cancelación:'),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Motivo de cancelación',
                  ),
                  maxLines: 3,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () {
                  if (controller.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Debe indicar un motivo')),
                    );
                    return;
                  }
                  Navigator.pop(context);
                  viewModel.cancelarPedido(controller.text.trim());
                },
                child: const Text('Confirmar'),
              ),
            ],
          ),
    );
  }

  String _formatDate(String date) {
    final parsedDate = DateTime.parse(date);
    return '${parsedDate.day}/${parsedDate.month}/${parsedDate.year} ${parsedDate.hour}:${parsedDate.minute < 10 ? '0' : ''}${parsedDate.minute}';
  }

  String _formatTipoPedido(String tipo) {
    switch (tipo) {
      case 'normal':
        return 'Pedido Normal';
      case 'por_prevision':
        return 'Pedido por Previsión';
      default:
        return tipo.replaceAll('_', ' ');
    }
  }

  double _calcularTotal(List<PedidoProducto> productos) {
    return productos.fold(
      0,
      (total, producto) =>
          total + (producto.cantidad * producto.precioUnitario),
    );
  }
}
