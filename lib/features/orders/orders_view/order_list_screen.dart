import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:foodflow_app/features/orders/orders_view/widgets/order_card_widget.dart';
import 'package:foodflow_app/features/orders/orders_view/widgets/order_filters_widget.dart';
import 'package:foodflow_app/features/orders/orders_view/widgets/orders_status_widget.dart';
import 'package:foodflow_app/features/orders/orders_viewmodel/order_list_viewmodel.dart';
import 'package:foodflow_app/features/shared/widgets/responsive_scaffold_widget.dart';

class OrderListScreen extends StatelessWidget {
  const OrderListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OrderListViewModel(),
      child: const _OrderListBody(),
    );
  }
}

class _OrderListBody extends StatelessWidget {
  const _OrderListBody();

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      title: 'Gestión de Pedidos',
      body: _buildOrderListContent(context),
    );
  }

  Widget _buildOrderListContent(BuildContext context) {
    final viewModel = Provider.of<OrderListViewModel>(context);
    final model = viewModel.model;

    if (model.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/icons/app_icon.png', width: 100, height: 100),
            const SizedBox(height: 24),
            const CircularProgressIndicator(),
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
              onPressed: () => viewModel.cargarPedidos(),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    // Filtrado avanzado: si hay pedidos tras aplicar filtros locales
    final pedidosFiltrados = viewModel.pedidosFiltrados;

    return SingleChildScrollView(
      child: Column(
        children: [
          OrderFiltersWidget(
            busquedaTexto: viewModel.busquedaTexto,
            estadoSeleccionado: viewModel.estadoSeleccionado,
            tipoPedidoSeleccionado: viewModel.tipoPedidoSeleccionado,
            urgenteSeleccionado: viewModel.urgenteSeleccionado,
            importeMin: viewModel.importeMin,
            importeMax: viewModel.importeMax,
            fechaInicio: viewModel.fechaInicio,
            fechaFin: viewModel.fechaFin,
            onBusquedaTextoChanged: viewModel.setBusquedaTexto,
            onEstadoChanged: viewModel.setEstadoFiltro,
            onTipoPedidoChanged: viewModel.setTipoPedidoFiltro,
            onUrgenteChanged: viewModel.setUrgenteFiltro,
            onImporteMinChanged: viewModel.setImporteMin,
            onImporteMaxChanged: viewModel.setImporteMax,
            onFechaInicioChanged: viewModel.setFechaInicio,
            onFechaFinChanged: viewModel.setFechaFin,
            onLimpiarFiltros: viewModel.limpiarFiltros,
            onAplicarFiltros: viewModel.cargarPedidos,
          ),
          OrdersStatusWidget(
            totalPedidos: pedidosFiltrados.length,
            pendientes:
                pedidosFiltrados.where((p) => p.estado == 'pendiente').length,
            enProceso:
                pedidosFiltrados.where((p) => p.estado == 'en_proceso').length,
            completados:
                pedidosFiltrados.where((p) => p.estado == 'completado').length,
            cancelados:
                pedidosFiltrados.where((p) => p.estado == 'cancelado').length,
          ),
          const SizedBox(height: 8),
          if (pedidosFiltrados.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 16.0,
                horizontal: 16.0,
              ),
              child: Text(
                'No se encontraron pedidos con los filtros aplicados',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.start,
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: pedidosFiltrados.length,
              itemBuilder: (context, index) {
                final pedido = pedidosFiltrados[index];
                return OrderCardWidget(
                  pedido: pedido,
                  onTap: () => _navegarADetallePedido(context, pedido.id),
                );
              },
            ),
        ],
      ),
    );
  }

  void _navegarADetallePedido(BuildContext context, int pedidoId) {
    context.push('/orders/detail/$pedidoId').then((_) {
      Provider.of<OrderListViewModel>(context, listen: false).cargarPedidos();
    });
  }
}
