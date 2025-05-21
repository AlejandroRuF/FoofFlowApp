import 'package:flutter/material.dart';
import 'package:foodflow_app/models/pedido_model.dart';

class OrderCardWidget extends StatelessWidget {
  final Pedido pedido;
  final VoidCallback onTap;

  const OrderCardWidget({Key? key, required this.pedido, required this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Pedido #${pedido.id}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  _buildEstadoChip(context),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Restaurante: ${pedido.restauranteNombre}',
                          style: Theme.of(context).textTheme.bodyMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Cocina: ${pedido.cocinaCentralNombre}',
                          style: Theme.of(context).textTheme.bodyMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Fecha: ${_formatDate(pedido.fechaPedido)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        'Total: €${pedido.montoTotal.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (pedido.urgente)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.priority_high,
                        color: Theme.of(context).colorScheme.error,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'URGENTE',
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
      ),
    );
  }

  Widget _buildEstadoChip(BuildContext context) {
    Color backgroundColor;
    Color textColor = Colors.white;

    switch (pedido.estado) {
      case 'pendiente':
        backgroundColor = Colors.orange;
        break;
      case 'en_proceso':
        backgroundColor = Colors.blue;
        break;
      case 'enviado':
        backgroundColor = Colors.purple;
        break;
      case 'completado':
        backgroundColor = Colors.green;
        break;
      case 'cancelado':
        backgroundColor = Colors.red;
        break;
      default:
        backgroundColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _getEstadoText(pedido.estado),
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _getEstadoText(String estado) {
    switch (estado) {
      case 'pendiente':
        return 'Pendiente';
      case 'en_proceso':
        return 'En Proceso';
      case 'enviado':
        return 'Enviado';
      case 'completado':
        return 'Completado';
      case 'cancelado':
        return 'Cancelado';
      default:
        return estado.replaceAll('_', ' ');
    }
  }

  String _formatDate(String date) {
    final parsedDate = DateTime.parse(date);
    return '${parsedDate.day}/${parsedDate.month}/${parsedDate.year}';
  }
}
