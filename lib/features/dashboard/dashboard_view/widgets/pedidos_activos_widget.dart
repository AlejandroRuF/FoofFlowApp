import 'package:flutter/material.dart';

class PedidosActivosWidget extends StatelessWidget {
  final Map<String, dynamic> pedidos;
  final String titulo;
  final String tipoUsuario;
  final int? usuarioId;
  final bool isDarkMode;

  const PedidosActivosWidget({
    Key? key,
    required this.pedidos,
    this.titulo = 'Pedidos Activos',
    required this.tipoUsuario,
    this.usuarioId,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
            _buildPedidosList(context),
            const SizedBox(height: 8),
            _buildResumenPedidos(),
          ],
        ),
      ),
    );
  }

  Widget _buildEstadisticasChip() {
    final total = pedidos['total'] ?? 0;
    final pendientes = pedidos['pendientes'] ?? 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: pendientes > 0 ? Colors.amber : Colors.green,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        'Pendientes: $pendientes/$total',
        style: TextStyle(
          color: pendientes > 0 ? Colors.black87 : Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildPedidosList(BuildContext context) {
    final listaPedidos = pedidos['lista'] as List? ?? [];

    if (listaPedidos.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No hay pedidos activos en este momento'),
        ),
      );
    }

    return SizedBox(
      height: 220,
      child: ListView.builder(
        itemCount: listaPedidos.length,
        itemBuilder: (context, index) {
          final pedido = listaPedidos[index];
          return _buildPedidoItem(pedido);
        },
      ),
    );
  }

  Widget _buildPedidoItem(Map<String, dynamic> pedido) {
    final esAdmin = tipoUsuario == 'administrador';

    String clienteTexto = pedido['cliente'] ?? 'Cliente';
    String proveedorTexto = '';

    if (esAdmin) {
      clienteTexto = 'Cliente: ${pedido['cliente'] ?? 'Cliente'}';
      proveedorTexto = 'Proveedor: ${pedido['proveedor'] ?? 'Proveedor'}';
    } else {
      final int? pedidoClienteId = pedido['cliente_id'];
      final int? pedidoProveedorId = pedido['proveedor_id'];

      if (usuarioId != null) {
        if (usuarioId == pedidoClienteId) {
          clienteTexto = 'Proveedor: ${pedido['proveedor'] ?? 'Proveedor'}';
        } else if (usuarioId == pedidoProveedorId) {
          clienteTexto = 'Cliente: ${pedido['cliente'] ?? 'Cliente'}';
        }
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: _getColorEstado(pedido['estado']),
          child: Text(
            '#${pedido['numero']}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          clienteTexto,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (esAdmin && proveedorTexto.isNotEmpty) Text(proveedorTexto),
            const SizedBox(height: 4),
            Text('Fecha: ${pedido['fecha'] ?? '--/--/----'}'),
            Text('Total: ${pedido['total']?.toStringAsFixed(2) ?? '0.00'} €'),
          ],
        ),
        trailing: Chip(
          label: Text(
            pedido['estado'] ?? 'Desconocido',
            style: TextStyle(
              color: _getTextColorForEstado(pedido['estado']),
              fontSize: 12,
            ),
          ),
          backgroundColor: _getColorEstado(pedido['estado']).withOpacity(0.2),
        ),
        onTap: () {},
      ),
    );
  }

  Color _getColorEstado(String? estado) {
    switch (estado?.toLowerCase()) {
      case 'pendiente':
        return Colors.orange;
      case 'en proceso':
        return Colors.blue;
      case 'completado':
        return Colors.green;
      case 'cancelado':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getTextColorForEstado(String? estado) {
    return isDarkMode ? Colors.white : Colors.black87;
  }

  Widget _buildResumenPedidos() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildEstadisticaItem(
          'Pendientes',
          pedidos['pendientes']?.toString() ?? '0',
          Colors.orange,
        ),
        _buildEstadisticaItem(
          'En Proceso',
          pedidos['en_proceso']?.toString() ?? '0',
          Colors.blue,
        ),
        _buildEstadisticaItem(
          'Completados',
          pedidos['completados']?.toString() ?? '0',
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
