import 'package:flutter/material.dart';

class OrdersStatusWidget extends StatelessWidget {
  final int totalPedidos;
  final int pendientes;
  final int enProceso;
  final int completados;
  final int cancelados;

  const OrdersStatusWidget({
    Key? key,
    required this.totalPedidos,
    required this.pendientes,
    required this.enProceso,
    required this.completados,
    required this.cancelados,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resumen de Pedidos',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatusItem(context, 'Total', totalPedidos, Colors.blue),
                _buildStatusItem(
                  context,
                  'Pendientes',
                  pendientes,
                  Colors.orange,
                ),
                _buildStatusItem(
                  context,
                  'En Proceso',
                  enProceso,
                  Colors.purple,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatusItem(
                  context,
                  'Completados',
                  completados,
                  Colors.green,
                ),
                _buildStatusItem(context, 'Cancelados', cancelados, Colors.red),
                const SizedBox(width: 100),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem(
    BuildContext context,
    String label,
    int count,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Text(
            count.toString(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
