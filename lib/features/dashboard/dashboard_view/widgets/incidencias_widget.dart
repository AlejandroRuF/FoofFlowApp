import 'package:flutter/material.dart';
import 'dart:developer' as developer;

class IncidenciasWidget extends StatelessWidget {
  final Map<String, dynamic> incidencias;
  final String titulo;
  final String tipoUsuario;
  final int? usuarioId;
  final bool isDarkMode;

  const IncidenciasWidget({
    super.key,
    required this.incidencias,
    this.titulo = 'Incidencias',
    required this.tipoUsuario,
    this.usuarioId,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    developer.log('Estructura de incidencias: ${incidencias.keys}');

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _buildEstadisticasChip(),
              ],
            ),
            const SizedBox(height: 16),
            _buildIncidenciasList(context),
            const SizedBox(height: 8),
            _buildResumenIncidencias(),
          ],
        ),
      ),
    );
  }

  Widget _buildEstadisticasChip() {
    final pendientes = incidencias['pendientes'] ?? 0;
    final total = incidencias['total'] ?? 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: pendientes > 0 ? Colors.red : Colors.green,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        'Pendientes: $pendientes/$total',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildIncidenciasList(BuildContext context) {
    final listaIncidencias = incidencias['lista'] as List? ?? [];

    developer.log(
      'Lista de incidencias tiene ${listaIncidencias.length} elementos',
    );
    if (listaIncidencias.isNotEmpty) {
      developer.log('Primer elemento: ${listaIncidencias.first}');
    }

    if (listaIncidencias.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No hay incidencias reportadas'),
        ),
      );
    }

    return SizedBox(
      height: 220,
      child: ListView.builder(
        itemCount: listaIncidencias.length,
        itemBuilder: (context, index) {
          final incidencia = listaIncidencias[index];
          return _buildIncidenciaItem(incidencia);
        },
      ),
    );
  }

  Widget _buildIncidenciaItem(Map<String, dynamic> incidencia) {
    final productoNombre =
        incidencia['producto_nombre'] ?? 'Producto desconocido';

    final pedidoId = incidencia['pedido_id'] ?? '--';
    final clienteNombre =
        incidencia['cliente_nombre'] ?? 'Cliente no disponible';
    final proveedorNombre =
        incidencia['proveedor_nombre'] ?? 'Proveedor no disponible';

    final descripcion = incidencia['descripcion'] ?? 'Sin descripción';
    final estado = incidencia['estado'] ?? 'Pendiente';
    final fechaReporte = _formatDate(
      incidencia['fecha_reporte'] ?? incidencia['fecha'],
    );
    final prioridad = incidencia['prioridad'] ?? 'Alta';

    developer.log('Procesando incidencia: $incidencia');

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: _getColorPrioridad(prioridad),
          child: const Icon(Icons.error_outline, color: Colors.white),
        ),
        title: Text(
          productoNombre,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Pedido #$pedidoId'),
            Text(
              'Fecha: $fechaReporte',
              style: TextStyle(
                fontSize: 12,
                color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
              ),
            ),
          ],
        ),
        trailing: Chip(
          label: Text(
            estado,
            style: TextStyle(
              color: _getTextColorForEstado(estado),
              fontSize: 12,
            ),
          ),
          backgroundColor: _getColorEstado(estado).withOpacity(0.2),
        ),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                Text('Descripción: $descripcion'),
                const SizedBox(height: 4),
                Text('Cliente: $clienteNombre'),
                Text('Proveedor: $proveedorNombre'),
                const SizedBox(height: 4),
                Text(
                  'Prioridad: $prioridad',
                  style: TextStyle(
                    color: _getColorPrioridad(prioridad),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (incidencia['reportado_por_nombre'] != null)
                  Text(
                    'Reportado por: ${incidencia['reportado_por_nombre']}',
                    style: const TextStyle(fontStyle: FontStyle.italic),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return '--/--/----';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  Color _getColorEstado(String? estado) {
    switch (estado?.toLowerCase()) {
      case 'pendiente':
        return Colors.orange;
      case 'resuelta':
        return Colors.green;
      case 'rechazada':
      case 'cancelada':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getColorPrioridad(String prioridad) {
    switch (prioridad.toLowerCase()) {
      case 'alta':
        return Colors.red;
      case 'media':
        return Colors.orange;
      case 'baja':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Color _getTextColorForEstado(String? estado) {
    return isDarkMode ? Colors.white : Colors.black87;
  }

  Widget _buildResumenIncidencias() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildEstadisticaItem(
          'Pendientes',
          incidencias['pendientes']?.toString() ?? '0',
          Colors.orange,
        ),
        _buildEstadisticaItem(
          'En proceso',
          incidencias['en_proceso']?.toString() ?? '0',
          Colors.blue,
        ),
        _buildEstadisticaItem(
          'Resueltas',
          incidencias['resueltas']?.toString() ?? '0',
          Colors.green,
        ),
      ],
    );
  }

  Widget _buildEstadisticaItem(String titulo, String valor, Color color) {
    return Column(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: color.withOpacity(0.2),
          child: Text(
            valor,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 4),
        Text(titulo, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
