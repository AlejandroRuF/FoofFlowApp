import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:foodflow_app/features/shared/widgets/responsive_scaffold_widget.dart';
import 'package:foodflow_app/models/pedido_model.dart';
import 'package:foodflow_app/models/pedido_producto_model.dart';

import '../incidents_interactor/incidents_interactor.dart';

class IncidentFormScreen extends StatefulWidget {
  const IncidentFormScreen({super.key});

  @override
  State<IncidentFormScreen> createState() => _IncidentFormScreenState();
}

class _IncidentFormScreenState extends State<IncidentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descripcionController = TextEditingController();
  final _nuevaCantidadController = TextEditingController();

  final _interactor = IncidentsInteractor();

  int? _pedidoSeleccionado;
  int? _productoSeleccionado;
  bool _isLoading = false;
  String? _error;

  List<Pedido> _pedidos = [];
  List<PedidoProducto> _productosPedido = [];

  @override
  void initState() {
    super.initState();
    _cargarPedidos();
  }

  @override
  void dispose() {
    _descripcionController.dispose();
    _nuevaCantidadController.dispose();
    super.dispose();
  }

  Future<void> _cargarPedidos() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final pedidos = await _interactor.obtenerPedidosUsuario();
      setState(() {
        _pedidos = pedidos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al cargar pedidos: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _cargarProductosPedido(int pedidoId) async {
    setState(() {
      _isLoading = true;
      _error = null;
      _productoSeleccionado = null;
      _productosPedido = [];
    });

    try {
      final productos = await _interactor.obtenerProductosPedido(pedidoId);
      setState(() {
        _productosPedido = productos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al cargar productos: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _crearIncidencia() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_pedidoSeleccionado == null || _productoSeleccionado == null) {
      setState(() {
        _error = 'Debes seleccionar un pedido y un producto';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final resultado = await _interactor.crearIncidencia(
        pedidoId: _pedidoSeleccionado!,
        productoId: _productoSeleccionado!,
        nuevaCantidad: int.parse(_nuevaCantidadController.text),
        descripcion: _descripcionController.text,
      );

      if (resultado) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Incidencia creada con éxito'),
              backgroundColor: Colors.green,
            ),
          );
          context.pop();
        }
      } else {
        setState(() {
          _error = 'Error al crear la incidencia';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error al crear la incidencia: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      title: 'Crear Incidencia',
      body: _buildBody(),
      showBackButton: true,
      initialIndex: 3,
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
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

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Error: $_error',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _cargarPedidos,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Crea una incidencia para modificar la cantidad de un producto en un pedido',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              _buildPedidoDropdown(),
              const SizedBox(height: 16),
              if (_pedidoSeleccionado != null) ...[
                _buildProductoDropdown(),
                const SizedBox(height: 16),
              ],
              if (_productoSeleccionado != null) ...[
                _buildNuevaCantidadField(),
                const SizedBox(height: 16),
                _buildDescripcionField(),
                const SizedBox(height: 24),
                _buildSubmitButton(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPedidoDropdown() {
    if (_pedidos.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No hay pedidos disponibles para crear incidencias'),
        ),
      );
    }

    return DropdownButtonFormField<int>(
      decoration: const InputDecoration(
        labelText: 'Seleccionar Pedido',
        border: OutlineInputBorder(),
      ),
      value: _pedidoSeleccionado,
      isExpanded: true,
      hint: const Text('Seleccione un pedido'),
      validator: (value) {
        if (value == null) {
          return 'Por favor seleccione un pedido';
        }
        return null;
      },
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _pedidoSeleccionado = value;
            _productoSeleccionado = null;
          });
          _cargarProductosPedido(value);
        }
      },
      items:
          _pedidos.map((pedido) {
            return DropdownMenuItem<int>(
              value: pedido.id,
              child: Text(
                'Pedido #${pedido.id} - ${pedido.restauranteNombre ?? 'Cliente'} (${pedido.estado})',
              ),
            );
          }).toList(),
    );
  }

  Widget _buildProductoDropdown() {
    if (_productosPedido.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No hay productos en este pedido'),
        ),
      );
    }

    return DropdownButtonFormField<int>(
      decoration: const InputDecoration(
        labelText: 'Seleccionar Producto',
        border: OutlineInputBorder(),
      ),
      value: _productoSeleccionado,
      isExpanded: true,
      hint: const Text('Seleccione un producto'),
      validator: (value) {
        if (value == null) {
          return 'Por favor seleccione un producto';
        }
        return null;
      },
      onChanged: (value) {
        setState(() {
          _productoSeleccionado = value;

          if (value != null) {
            final producto = _productosPedido.firstWhere(
              (p) => p.productoId == value,
            );
            _nuevaCantidadController.text = '${producto.cantidad}';
          }
        });
      },
      items:
          _productosPedido.map((producto) {
            return DropdownMenuItem<int>(
              value: producto.productoId,
              child: Text(
                (producto.productoNombre != null &&
                        producto.productoNombre.isNotEmpty)
                    ? '${producto.productoNombre} (Cantidad actual: ${producto.cantidad})'
                    : 'Producto ID: ${producto.productoId} (Cantidad actual: ${producto.cantidad})',
              ),
            );
          }).toList(),
    );
  }

  Widget _buildNuevaCantidadField() {
    return TextFormField(
      controller: _nuevaCantidadController,
      decoration: const InputDecoration(
        labelText: 'Nueva Cantidad',
        border: OutlineInputBorder(),
        helperText: 'Ingrese 0 para eliminar el producto del pedido',
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor ingrese la nueva cantidad';
        }

        final cantidad = int.tryParse(value);
        if (cantidad == null || cantidad < 0) {
          return 'La cantidad debe ser un número entero no negativo';
        }

        return null;
      },
    );
  }

  Widget _buildDescripcionField() {
    return TextFormField(
      controller: _descripcionController,
      decoration: const InputDecoration(
        labelText: 'Descripción',
        border: OutlineInputBorder(),
        helperText: 'Explique el motivo de la modificación',
      ),
      maxLines: 3,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor ingrese una descripción';
        }
        if (value.length < 10) {
          return 'La descripción debe tener al menos 10 caracteres';
        }
        return null;
      },
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _crearIncidencia,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child:
            _isLoading
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/icons/app_icon.png',
                        width: 100,
                        height: 100,
                      ),
                      SizedBox(height: 24),
                      CircularProgressIndicator(),
                    ],
                  ),
                )
                : const Text(
                  'Crear Incidencia',
                  style: TextStyle(fontSize: 16),
                ),
      ),
    );
  }
}
