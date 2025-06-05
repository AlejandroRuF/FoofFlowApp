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
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

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
                    padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_viewModel.esAdmin)
                          Text(
                            'Inventario destino: ${widget.kitchenName}',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 14 : 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        const SizedBox(height: 8),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isSmallScreen ? 8 : 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${productosFiltrados.length} productos disponibles de esta cocina',
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                              fontSize: isSmallScreen ? 11 : 13,
                            ),
                          ),
                        ),
                        if (totalProductosSeleccionados > 0) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isSmallScreen ? 8 : 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '$totalProductosSeleccionados productos seleccionados',
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                                fontSize: isSmallScreen ? 11 : 13,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        TextField(
                          controller: _busquedaController,
                          decoration: InputDecoration(
                            labelText:
                                isSmallScreen
                                    ? 'Buscar producto'
                                    : 'Buscar producto por nombre o categoría',
                            prefixIcon: const Icon(Icons.search),
                            border: const OutlineInputBorder(),
                            labelStyle: TextStyle(
                              fontSize: isSmallScreen ? 12 : 14,
                            ),
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
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isSmallScreen ? 16 : 32,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.inventory_2_outlined,
                                      size: isSmallScreen ? 48 : 64,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      _busqueda.isEmpty
                                          ? 'Esta cocina no tiene productos disponibles'
                                          : 'No se encontraron productos con ese término',
                                      style: TextStyle(
                                        fontSize: isSmallScreen ? 14 : 16,
                                      ),
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
                              ),
                            )
                            : ListView.builder(
                              padding: EdgeInsets.symmetric(
                                horizontal: isSmallScreen ? 12 : 16,
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
                      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
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
                              style: TextStyle(
                                fontSize: isSmallScreen ? 14 : 16,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                vertical: isSmallScreen ? 12 : 16,
                              ),
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
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Card(
      margin: EdgeInsets.only(bottom: isSmallScreen ? 8 : 12),
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
        child:
            isSmallScreen
                ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image:
                                producto.imagen != null
                                    ? DecorationImage(
                                      image: NetworkImage(producto.imagen!),
                                      fit: BoxFit.cover,
                                    )
                                    : null,
                            color:
                                producto.imagen == null
                                    ? Colors.grey[200]
                                    : null,
                          ),
                          child:
                              producto.imagen == null
                                  ? const Icon(
                                    Icons.fastfood,
                                    color: Colors.grey,
                                    size: 20,
                                  )
                                  : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                producto.nombre,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                producto.descripcion ?? 'Sin descripción',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
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
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '\$${producto.precio.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (cantidadSeleccionada > 0) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: () => _decrementarCantidad(producto),
                            icon: const Icon(
                              Icons.remove_circle_outline,
                              size: 20,
                            ),
                            color: Colors.red,
                            padding: const EdgeInsets.all(4),
                            constraints: const BoxConstraints(
                              minHeight: 32,
                              minWidth: 32,
                            ),
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
                                fontSize: 14,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => _incrementarCantidad(producto),
                            icon: const Icon(
                              Icons.add_circle_outline,
                              size: 20,
                            ),
                            color: Colors.green,
                            padding: const EdgeInsets.all(4),
                            constraints: const BoxConstraints(
                              minHeight: 32,
                              minWidth: 32,
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      Center(
                        child: ElevatedButton(
                          onPressed: () => _agregarProducto(producto),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 8,
                            ),
                          ),
                          child: const Text(
                            'Agregar',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                  ],
                )
                : Row(
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
                        color:
                            producto.imagen == null ? Colors.grey[200] : null,
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
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );

        context.goNamed('inventory');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Error al agregar algunos productos'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
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
