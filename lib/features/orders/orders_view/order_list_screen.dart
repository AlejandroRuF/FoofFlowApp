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
      child: ResponsiveScaffold(
        title: 'Gestión de Pedidos',
        body: const _OrderListBody(),
        floatingActionButton: _buildFloatingActionButton(context),
      ),
    );
  }

  Widget? _buildFloatingActionButton(BuildContext context) {
    return null;
  }
}

class _OrderListBody extends StatelessWidget {
  const _OrderListBody();

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<OrderListViewModel>(context);
    final model = viewModel.model;

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
              onPressed: () => viewModel.cargarPedidos(),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (model.pedidos.isEmpty) {
      return const Center(child: Text('No hay pedidos disponibles'));
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          OrderFiltersWidget(
            fechaInicio: viewModel.fechaInicio,
            fechaFin: viewModel.fechaFin,
            usuarioFiltro: viewModel.usuarioFiltro,
            usuariosDisponibles: model.usuariosRelacionados,
            onFechaInicioChanged: viewModel.setFechaInicio,
            onFechaFinChanged: viewModel.setFechaFin,
            onUsuarioChanged: viewModel.setUsuarioFiltro,
            onLimpiarFiltros: viewModel.limpiarFiltros,
          ),
          OrdersStatusWidget(
            totalPedidos: model.pedidos.length,
            pendientes:
                model.pedidos.where((p) => p.estado == 'pendiente').length,
            enProceso:
                model.pedidos.where((p) => p.estado == 'en_proceso').length,
            completados:
                model.pedidos.where((p) => p.estado == 'completado').length,
            cancelados:
                model.pedidos.where((p) => p.estado == 'cancelado').length,
          ),
          const SizedBox(height: 8),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: model.pedidos.length,
            itemBuilder: (context, index) {
              final pedido = model.pedidos[index];
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
