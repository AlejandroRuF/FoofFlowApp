import 'package:flutter/material.dart';

class InventarioWidget extends StatelessWidget {
  final Map<String, dynamic> inventario;
  final String titulo;
  final String tipoUsuario;

  const InventarioWidget({
    Key? key,
    required this.inventario,
    this.titulo = 'Inventario',
    required this.tipoUsuario,
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
                _buildAlertaStockBajo(),
              ],
            ),
            const SizedBox(height: 16),
            _buildInventarioList(context),
            const SizedBox(height: 16),
            _buildResumenInventario(),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertaStockBajo() {
    final stockBajo = inventario['stock_bajo_count'] ?? 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: stockBajo > 0 ? Colors.red : Colors.green,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (stockBajo > 0)
            const Icon(Icons.warning, color: Colors.white, size: 16),
          if (stockBajo > 0) const SizedBox(width: 4),
          Text(
            stockBajo > 0 ? '$stockBajo productos' : 'Stock OK',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInventarioList(BuildContext context) {
    final items = inventario['items'] as List? ?? [];

    if (items.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No hay datos de inventario disponibles'),
        ),
      );
    }

    return SizedBox(
      height: 220,
      child: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return _buildInventarioItem(item);
        },
      ),
    );
  }

  Widget _buildInventarioItem(Map<String, dynamic> item) {
    final nombre = item['nombre'] ?? 'Producto sin nombre';
    final cantidad = item['cantidad'] ?? 0;
    final stockMinimo = item['stock_minimo'] ?? 0;
    final unidad = item['unidad'] ?? 'ud';
    final esStockBajo = cantidad < stockMinimo;

    final usuarioAlmacen = item['usuario_almacen'] ?? 'No asignado';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: esStockBajo ? Colors.red : Colors.green,
          child: Icon(
            esStockBajo ? Icons.warning : Icons.check_circle,
            color: Colors.white,
          ),
        ),
        title: Text(
          nombre,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: esStockBajo ? Colors.red : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Stock actual: $cantidad $unidad'),
            Text('Stock mínimo: $stockMinimo $unidad'),
            if (tipoUsuario == 'administrador')
              Text('Almacén: $usuarioAlmacen'),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$cantidad',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: esStockBajo ? Colors.red : Colors.green,
              ),
            ),
            Text(unidad, style: const TextStyle(fontSize: 12)),
          ],
        ),
        onTap: () {},
      ),
    );
  }

  Widget _buildResumenInventario() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildEstadisticaItem(
          'Total Productos',
          inventario['total_productos']?.toString() ?? '0',
          Colors.blue,
        ),
        _buildEstadisticaItem(
          'Stock Bajo',
          inventario['stock_bajo_count']?.toString() ?? '0',
          Colors.red,
        ),
        _buildEstadisticaItem(
          'Valor Total',
          '${inventario['valor_total'] ?? 0}€',
          Colors.green,
        ),
      ],
    );
  }

  Widget _buildEstadisticaItem(String titulo, String valor, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
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
