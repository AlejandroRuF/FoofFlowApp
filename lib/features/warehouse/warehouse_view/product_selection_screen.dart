import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:foodflow_app/models/producto_model.dart';
import 'package:foodflow_app/features/shared/widgets/responsive_scaffold_widget.dart';
import '../warehouse_viewmodel/inventory_viewmodel.dart';

class ProductSelectionScreen extends StatefulWidget {
  final List<Producto> productos;
  final String kitchenName;
  final int kitchenId;

  const ProductSelectionScreen({
    super.key,
    required this.productos,
    required this.kitchenName,
    required this.kitchenId,
  });

  @override
  State<ProductSelectionScreen> createState() => _ProductSelectionScreenState();
}

class _ProductSelectionScreenState extends State<ProductSelectionScreen> {
  String _busqueda = '';
  final TextEditingController _busquedaController = TextEditingController();
  final Map<int, int> _productosSeleccionados = {};
  bool _isProcessing = false;
  late InventoryViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    final productosDeEstaCocina =
        widget.productos
            .where((producto) => producto.cocinaCentralId == widget.kitchenId)
            .toList();
    _viewModel = InventoryViewModel();
  }

  @override
  void dispose() {
    _busquedaController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  List<Producto> get productosFiltrados {
    final productosDeEstaCocina =
        widget.productos
            .where((producto) => producto.cocinaCentralId == widget.kitchenId)
            .toList();

    if (_busqueda.isEmpty) {
      return productosDeEstaCocina;
    }

    final busquedaLower = _busqueda.toLowerCase();
    return productosDeEstaCocina.where((producto) {
      return producto.nombre.toLowerCase().contains(busquedaLower) ||
          (producto.descripcion?.toLowerCase().contains(busquedaLower) ??
              false) ||
          (producto.categoria?.nombre?.toLowerCase().contains(busquedaLower) ??
              false);
    }).toList();
  }

  int get totalProductosSeleccionados {
    return _productosSeleccionados.values.fold(
      0,
      (sum, cantidad) => sum + cantidad,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      title: 'Seleccionar Productos',
      showBackButton: true,
      body:
          _isProcessing
              ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Agregando productos al inventario...'),
                  ],
                ),
              )
              : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Inventario destino: ${widget.kitchenName}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${productosFiltrados.length} productos disponibles de esta cocina',
                            style: const TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (totalProductosSeleccionados > 0) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '$totalProductosSeleccionados productos seleccionados',
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        TextField(
                          controller: _busquedaController,
                          decoration: const InputDecoration(
                            labelText: 'Buscar producto por nombre o categoría',
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _busqueda = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child:
                        productosFiltrados.isEmpty
                            ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.inventory_2_outlined,
                                    size: 64,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _busqueda.isEmpty
                                        ? 'Esta cocina no tiene productos disponibles'
                                        : 'No se encontraron productos con ese término',
                                    style: const TextStyle(fontSize: 16),
                                    textAlign: TextAlign.center,
                                  ),
                                  if (_busqueda.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    TextButton(
                                      onPressed: () {
                                        _busquedaController.clear();
                                        setState(() {
                                          _busqueda = '';
                                        });
                                      },
                                      child: const Text('Limpiar búsqueda'),
                                    ),
                                  ],
                                ],
                              ),
                            )
                            : ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              itemCount: productosFiltrados.length,
                              itemBuilder: (context, index) {
                                final producto = productosFiltrados[index];
                                return _buildProductCard(producto);
                              },
                            ),
                  ),
                  if (totalProductosSeleccionados > 0)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: SafeArea(
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _confirmarSeleccion,
                            icon: const Icon(Icons.check),
                            label: Text(
                              'Agregar $totalProductosSeleccionados productos',
                            ),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
    );
  }

  Widget _buildProductCard(Producto producto) {
    final cantidadSeleccionada = _productosSeleccionados[producto.id] ?? 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image:
                    producto.imagen != null
                        ? DecorationImage(
                          image: NetworkImage(producto.imagen!),
                          fit: BoxFit.cover,
                        )
                        : null,
                color: producto.imagen == null ? Colors.grey[200] : null,
              ),
              child:
                  producto.imagen == null
                      ? const Icon(Icons.fastfood, color: Colors.grey)
                      : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    producto.nombre,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    producto.descripcion ?? 'Sin descripción',
                    style: const TextStyle(color: Colors.grey),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          producto.categoria?.nombre ?? 'Sin categoría',
                          style: const TextStyle(
                            color: Colors.blue,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '\$${producto.precio.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            if (cantidadSeleccionada > 0) ...[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () => _decrementarCantidad(producto),
                    icon: const Icon(Icons.remove_circle_outline),
                    color: Colors.red,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      cantidadSeleccionada.toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _incrementarCantidad(producto),
                    icon: const Icon(Icons.add_circle_outline),
                    color: Colors.green,
                  ),
                ],
              ),
            ] else ...[
              ElevatedButton(
                onPressed: () => _agregarProducto(producto),
                child: const Text('Agregar'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _agregarProducto(Producto producto) {
    _showQuantityDialog(producto);
  }

  void _incrementarCantidad(Producto producto) {
    setState(() {
      _productosSeleccionados[producto.id] =
          (_productosSeleccionados[producto.id] ?? 0) + 1;
    });
  }

  void _decrementarCantidad(Producto producto) {
    setState(() {
      final cantidadActual = _productosSeleccionados[producto.id] ?? 0;
      if (cantidadActual > 1) {
        _productosSeleccionados[producto.id] = cantidadActual - 1;
      } else {
        _productosSeleccionados.remove(producto.id);
      }
    });
  }

  void _showQuantityDialog(Producto producto) {
    int cantidad = 1;
    final controller = TextEditingController(text: '1');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Agregar ${producto.nombre}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('¿Cuántas unidades quieres agregar?'),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Cantidad',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  cantidad = int.tryParse(value) ?? 1;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _productosSeleccionados[producto.id] = cantidad;
                });
              },
              child: const Text('Agregar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmarSeleccion() async {
    if (_productosSeleccionados.isEmpty) return;
    setState(() {
      _isProcessing = true;
    });

    try {
      bool exito;
      if (_viewModel.esEmpleado) {
        exito = await _viewModel.agregarProductosComoEmpleado(
          _productosSeleccionados,
        );
      } else {
        exito = await _viewModel.agregarMultiplesProductosAlInventario(
          _productosSeleccionados,
          widget.kitchenId,
        );
      }

      if (!mounted) return;

      if (exito) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _viewModel.esEmpleado
                  ? 'Productos agregados exitosamente al inventario de tu empleador'
                  : 'Productos agregados exitosamente al inventario',
            ),
            backgroundColor: Colors.green,
          ),
        );

        context.goNamed('inventory');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al agregar algunos productos'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }
}
