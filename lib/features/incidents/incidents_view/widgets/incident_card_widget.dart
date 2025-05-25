import 'package:flutter/material.dart';
import 'package:foodflow_app/models/incidencia_model.dart';
import 'package:intl/intl.dart';

class IncidentCardWidget extends StatelessWidget {
  final Incidencia incidencia;
  final VoidCallback? onTap;

  const IncidentCardWidget({Key? key, required this.incidencia, this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('dd/MM/yyyy HH:mm');
    final fechaReporte = DateTime.parse(incidencia.fechaReporte);
    final fechaFormateada = dateFormatter.format(fechaReporte);

    // Usar el nombre del producto del objeto anidado, o el antiguo campo por compatibilidad
    final nombreProducto =
        incidencia.producto?.nombre ?? incidencia.productoNombre;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildEstadoIndicator(),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Incidencia #${incidencia.id} - $nombreProducto',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(),
              _buildInfoRow('Pedido', '#${incidencia.pedidoId}'),
              _buildInfoRow('Nueva cantidad', '${incidencia.nuevaCantidad}'),
              _buildInfoRow(
                'Reportado por',
                incidencia.reportadoPorNombre ?? 'N/A',
              ),
              _buildInfoRow('Fecha', fechaFormateada),
              const SizedBox(height: 8),
              Text(
                'Descripción:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              Text(
                incidencia.descripcion,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEstadoIndicator() {
    Color colorEstado;
    IconData iconoEstado;

    switch (incidencia.estado) {
      case 'pendiente':
        colorEstado = Colors.orange;
        iconoEstado = Icons.pending_actions;
        break;
      case 'resuelta':
        colorEstado = Colors.green;
        iconoEstado = Icons.check_circle;
        break;
      case 'cancelada':
        colorEstado = Colors.red;
        iconoEstado = Icons.cancel;
        break;
      default:
        colorEstado = Colors.grey;
        iconoEstado = Icons.help;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorEstado.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: colorEstado),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconoEstado, size: 16, color: colorEstado),
          const SizedBox(width: 4),
          Text(
            incidencia.estadoDisplay,
            style: TextStyle(
              color: colorEstado,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
