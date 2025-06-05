import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:foodflow_app/features/orders/orders_viewmodel/order_detail_viewmodel.dart';
import 'package:foodflow_app/features/shared/widgets/responsive_scaffold_widget.dart';
import 'package:foodflow_app/models/pedido_producto_model.dart';
import 'package:foodflow_app/core/services/event_bus_service.dart';

class OrderDetailScreen extends StatelessWidget {
  final int pedidoId;

  const OrderDetailScreen({super.key, required this.pedidoId});

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
            Container(
              width: 100,
              height: 100,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Image.asset('assets/icons/app_icon.png'),
            ),
            const SizedBox(height: 24),
            CircularProgressIndicator(
              strokeWidth: 3,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Cargando detalles del pedido...',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    if (viewModel.error != null) {
      return Center(
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.errorContainer,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).colorScheme.error.withOpacity(0.5),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Error al cargar el pedido',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                viewModel.error!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => viewModel.cargarPedidoDetalle(pedidoId),
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Theme.of(context).colorScheme.onError,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final pedido = viewModel.pedido;
    if (pedido == null) {
      return Center(
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.search_off,
                size: 48,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 16),
              Text(
                'No se encontró el pedido',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen = constraints.maxWidth > 768;

        return SingleChildScrollView(
          padding: EdgeInsets.all(isWideScreen ? 24 : 16),
          child:
              isWideScreen
                  ? _buildWideLayout(context, pedido)
                  : _buildNarrowLayout(context, pedido),
        );
      },
    );
  }

  Widget _buildWideLayout(BuildContext context, pedido) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeaderSection(context, pedido),
        const SizedBox(height: 24),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  _buildInfoGeneralCard(context, pedido),
                  const SizedBox(height: 16),
                  _buildFechasCard(context, pedido),
                ],
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  _buildProductosCard(context, pedido.productos),
                  const SizedBox(height: 16),
                  if (pedido.notas != null && pedido.notas!.isNotEmpty)
                    _buildNotasCard(context, pedido.notas!),
                  if (pedido.motivoCancelacion != null &&
                      pedido.motivoCancelacion!.isNotEmpty)
                    _buildMotivoCancelacionCard(
                      context,
                      pedido.motivoCancelacion!,
                    ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildNarrowLayout(BuildContext context, pedido) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeaderSection(context, pedido),
        const SizedBox(height: 16),
        _buildInfoGeneralCard(context, pedido),
        const SizedBox(height: 16),
        _buildFechasCard(context, pedido),
        const SizedBox(height: 16),
        _buildProductosCard(context, pedido.productos),
        const SizedBox(height: 16),
        if (pedido.notas != null && pedido.notas!.isNotEmpty)
          _buildNotasCard(context, pedido.notas!),
        if (pedido.motivoCancelacion != null &&
            pedido.motivoCancelacion!.isNotEmpty)
          _buildMotivoCancelacionCard(context, pedido.motivoCancelacion!),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildHeaderSection(BuildContext context, pedido) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.receipt_long, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pedido #${pedido.id}',
                      style: Theme.of(
                        context,
                      ).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      pedido.restauranteNombre,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              _buildEstadoBadge(context, pedido.estado),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _buildInfoChip(
                context,
                'Total',
                '€${pedido.montoTotal.toStringAsFixed(2)}',
              ),
              _buildInfoChip(
                context,
                'Tipo',
                _formatTipoPedido(pedido.tipoPedido),
              ),
              _buildInfoChip(
                context,
                'Artículos',
                '${pedido.productos.length}',
              ),
              if (pedido.urgente)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.priority_high,
                        size: 16,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'URGENTE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEstadoBadge(BuildContext context, String estado) {
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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        estadoText,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildModernCard({
    required BuildContext context,
    required String title,
    required Widget child,
    IconData? icon,
    Color? cardColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor ?? Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.surfaceVariant.withOpacity(0.3),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          Padding(padding: const EdgeInsets.all(16), child: child),
        ],
      ),
    );
  }

  Widget _buildInfoGeneralCard(BuildContext context, dynamic pedido) {
    return _buildModernCard(
      context: context,
      title: 'Información General',
      icon: Icons.info_outline,
      child: Column(
        children: [
          _buildInfoField(context, 'Restaurante', pedido.restauranteNombre),
          const SizedBox(height: 12),
          _buildInfoField(
            context,
            'Cocina Central',
            pedido.cocinaCentralNombre,
          ),
          const SizedBox(height: 12),
          _buildInfoField(
            context,
            'Tipo de Pedido',
            _formatTipoPedido(pedido.tipoPedido),
          ),
          const SizedBox(height: 12),
          _buildInfoField(
            context,
            'Monto Total',
            '€${pedido.montoTotal.toStringAsFixed(2)}',
          ),
          const SizedBox(height: 12),
          _buildInfoField(
            context,
            'Fecha del Pedido',
            _formatDate(pedido.fechaPedido),
          ),
          if (pedido.urgente)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.priority_high, color: Colors.red),
                    const SizedBox(width: 8),
                    Text(
                      'PEDIDO URGENTE',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFechasCard(BuildContext context, dynamic pedido) {
    return _buildModernCard(
      context: context,
      title: 'Fechas',
      icon: Icons.event_outlined,
      child: Column(
        children: [
          _buildInfoField(
            context,
            'Fecha de Pedido',
            _formatDate(pedido.fechaPedido),
          ),
          if (pedido.fechaEntregaEstimada != null) ...[
            const SizedBox(height: 12),
            _buildInfoField(
              context,
              'Entrega Estimada',
              _formatDate(pedido.fechaEntregaEstimada!),
            ),
          ],
          if (pedido.fechaEntregaReal != null) ...[
            const SizedBox(height: 12),
            _buildInfoField(
              context,
              'Entrega Real',
              _formatDate(pedido.fechaEntregaReal!),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProductosCard(
    BuildContext context,
    List<PedidoProducto> productos,
  ) {
    return _buildModernCard(
      context: context,
      title: 'Productos (${productos.length} artículos)',
      icon: Icons.shopping_cart_outlined,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Text(
                    'Producto',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Cantidad',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'Subtotal',
                    textAlign: TextAlign.end,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          ...productos.asMap().entries.map((entry) {
            final index = entry.key;
            final producto = entry.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color:
                    index.isEven
                        ? Theme.of(
                          context,
                        ).colorScheme.surfaceVariant.withOpacity(0.3)
                        : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: _buildProductoItem(context, producto),
            );
          }),

          const SizedBox(height: 8),
          Divider(),
          const SizedBox(height: 8),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'TOTAL:',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                Text(
                  '€${_calcularTotal(productos).toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductoItem(BuildContext context, PedidoProducto producto) {
    return Row(
      children: [
        Expanded(
          flex: 5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                producto.productoNombre,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              Text(
                'Precio unitario: €${producto.precioUnitario.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${producto.cantidad}',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            '€${(producto.cantidad * producto.precioUnitario).toStringAsFixed(2)}',
            textAlign: TextAlign.end,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildNotasCard(BuildContext context, String notas) {
    return _buildModernCard(
      context: context,
      title: 'Notas',
      icon: Icons.notes_outlined,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(notas, style: Theme.of(context).textTheme.bodyMedium),
      ),
    );
  }

  Widget _buildMotivoCancelacionCard(BuildContext context, String motivo) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return _buildModernCard(
      context: context,
      title: 'Motivo de Cancelación',
      icon: Icons.cancel_outlined,
      cardColor: isDark ? Colors.red.withOpacity(0.1) : Colors.red.shade50,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red.withOpacity(0.3)),
        ),
        child: Text(
          motivo,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.red.shade700),
        ),
      ),
    );
  }

  Widget _buildInfoField(BuildContext context, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            '$label:',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    );
  }

  Widget _buildFloatingActionButton(
    BuildContext context,
    OrderDetailViewModel viewModel,
  ) {
    if (!viewModel.puedeCambiarEstado() || viewModel.pedido == null) {
      return Container();
    }

    final EventBusService _eventBus = EventBusService();

    return FloatingActionButton.extended(
      onPressed: () {
        context.push('/orders/edit/${viewModel.pedido!.id}').then((result) {
          if (result == true) {
            _eventBus.publishRefresh(
              RefreshEventType.orders,
              data: {'action': 'edited', 'pedidoId': viewModel.pedido!.id},
            );
          }
          viewModel.cargarPedidoDetalle(viewModel.pedido!.id);
        });
      },
      icon: const Icon(Icons.edit),
      label: const Text('Editar'),
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Theme.of(context).colorScheme.onPrimary,
    );
  }

  void _navegarAFormularioEdicion(BuildContext context, int pedidoId) {
    final EventBusService _eventBus = EventBusService();

    context.push('/orders/edit/$pedidoId').then((result) {
      if (result == true) {
        _eventBus.publishRefresh(
          RefreshEventType.orders,
          data: {'action': 'edited', 'pedidoId': pedidoId},
        );
      }

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
    final EventBusService _eventBus = EventBusService();

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
                onPressed: () async {
                  if (controller.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Debe indicar un motivo'),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                    return;
                  }
                  Navigator.pop(context);
                  final success = await viewModel.cancelarPedido(
                    controller.text.trim(),
                  );

                  if (success) {
                    _eventBus.publishRefresh(
                      RefreshEventType.orders,
                      data: {
                        'action': 'canceled',
                        'pedidoId': viewModel.pedido!.id,
                      },
                    );
                  }
                },
                child: const Text('Confirmar'),
              ),
            ],
          ),
    );
  }

  String _formatDate(String date) {
    try {
      final parsedDate = DateTime.parse(date);
      return '${parsedDate.day.toString().padLeft(2, '0')}/${parsedDate.month.toString().padLeft(2, '0')}/${parsedDate.year} ${parsedDate.hour.toString().padLeft(2, '0')}:${parsedDate.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return date;
    }
  }

  String _formatTipoPedido(String tipo) {
    switch (tipo) {
      case 'normal':
        return 'Normal';
      case 'urgente':
        return 'Urgente';
      case 'especial':
        return 'Especial';
      case 'por_prevision':
        return 'Por Previsión';
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
