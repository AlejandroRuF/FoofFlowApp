import 'package:flutter/material.dart';
import 'package:foodflow_app/models/inventario_model.dart';

class InventoryProductWidget extends StatefulWidget {
  final Inventario inventarioItem;
  final bool puedeModificar;
  final Future<bool> Function(int)? onStockChanged;

  const InventoryProductWidget({
    super.key,
    required this.inventarioItem,
    this.puedeModificar = false,
    this.onStockChanged,
  });

  @override
  State<InventoryProductWidget> createState() => _InventoryProductWidgetState();
}

class _InventoryProductWidgetState extends State<InventoryProductWidget> {
  bool _isLoading = false;
  int _stockActual = 0;
  int _modificacion = 1;
  final TextEditingController _modificacionController = TextEditingController(
    text: '1',
  );

  @override
  void initState() {
    super.initState();
    _stockActual = widget.inventarioItem.stockActual;
  }

  @override
  void didUpdateWidget(InventoryProductWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.inventarioItem.stockActual !=
        widget.inventarioItem.stockActual) {
      _stockActual = widget.inventarioItem.stockActual;
    }
  }

  @override
  void dispose() {
    _modificacionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool stockBajo = _stockActual < 10;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (isSmallScreen) ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.inventarioItem.productoNombre,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Almacén: ${widget.inventarioItem.usuarioNombre}',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color:
                          stockBajo
                              ? Colors.red.shade100
                              : Colors.green.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          stockBajo
                              ? Icons.warning_amber_rounded
                              : Icons.check_circle_outline,
                          color:
                              stockBajo
                                  ? Colors.red.shade700
                                  : Colors.green.shade700,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$_stockActual unidades',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color:
                                stockBajo
                                    ? Colors.red.shade700
                                    : Colors.green.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ] else ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.inventarioItem.productoNombre,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Almacén: ${widget.inventarioItem.usuarioNombre}',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color:
                            stockBajo
                                ? Colors.red.shade100
                                : Colors.green.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            stockBajo
                                ? Icons.warning_amber_rounded
                                : Icons.check_circle_outline,
                            color:
                                stockBajo
                                    ? Colors.red.shade700
                                    : Colors.green.shade700,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              '$_stockActual unidades',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color:
                                    stockBajo
                                        ? Colors.red.shade700
                                        : Colors.green.shade700,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
            if (widget.puedeModificar) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              if (isSmallScreen) ...[
                Column(
                  children: [
                    TextField(
                      controller: _modificacionController,
                      decoration: const InputDecoration(
                        labelText: 'Cantidad',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          _modificacion = int.tryParse(value) ?? 1;
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStockButton(
                            context,
                            icon: Icons.remove,
                            color: Colors.red,
                            onPressed: () => _actualizarStock(-_modificacion),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildStockButton(
                            context,
                            icon: Icons.add,
                            color: Colors.green,
                            onPressed: () => _actualizarStock(_modificacion),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ] else ...[
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _modificacionController,
                        decoration: const InputDecoration(
                          labelText: 'Cantidad',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          setState(() {
                            _modificacion = int.tryParse(value) ?? 1;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildStockButton(
                      context,
                      icon: Icons.remove,
                      color: Colors.red,
                      onPressed: () => _actualizarStock(-_modificacion),
                    ),
                    const SizedBox(width: 8),
                    _buildStockButton(
                      context,
                      icon: Icons.add,
                      color: Colors.green,
                      onPressed: () => _actualizarStock(_modificacion),
                    ),
                  ],
                ),
              ],
            ],
            if (_isLoading) ...[
              const SizedBox(height: 16),
              const LinearProgressIndicator(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStockButton(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 48,
      height: 48,
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: widget.puedeModificar && !_isLoading ? onPressed : null,
          borderRadius: BorderRadius.circular(8),
          child: Icon(icon, color: Colors.white),
        ),
      ),
    );
  }

  Future<void> _actualizarStock(int modificacion) async {
    if (!widget.puedeModificar || widget.onStockChanged == null) return;

    final nuevoStock = _stockActual + modificacion;
    if (nuevoStock < 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('El stock no puede ser negativo'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final resultado = await widget.onStockChanged!(nuevoStock);

      if (mounted) {
        if (resultado) {
          setState(() {
            _stockActual = nuevoStock;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Stock actualizado correctamente'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al actualizar el stock'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
