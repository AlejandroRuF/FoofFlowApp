import 'package:flutter/material.dart';
import 'package:foodflow_app/models/pedido_model.dart';
import 'package:foodflow_app/models/producto_model.dart';

import '../../incidents_viewmodel/incidents_viewmodel.dart';

class IncidentFiltersWidget extends StatefulWidget {
  final IncidentsViewModel viewModel;

  const IncidentFiltersWidget({super.key, required this.viewModel});

  @override
  State<IncidentFiltersWidget> createState() => _IncidentFiltersWidgetState();
}

class _IncidentFiltersWidgetState extends State<IncidentFiltersWidget> {
  bool _filtersExpanded = false;
  final TextEditingController _searchController = TextEditingController();

  final List<Producto> _productos = [];
  bool _productosCargados = false;

  @override
  void initState() {
    super.initState();
    _searchController.text = '';
    _cargarProductos();
  }

  Future<void> _cargarProductos() async {
    if (mounted) {
      _productosCargados = true;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSearchBar(),
            if (_filtersExpanded) ...[
              const SizedBox(height: 16),
              _buildExpandedFilters(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'Buscar por descripción o producto',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              widget.viewModel.establecerBusquedaTexto(value);
            },
          ),
        ),
        IconButton(
          icon: Icon(_filtersExpanded ? Icons.expand_less : Icons.expand_more),
          onPressed: () {
            setState(() {
              _filtersExpanded = !_filtersExpanded;
            });
          },
        ),
      ],
    );
  }

  Widget _buildExpandedFilters() {
    return Column(
      children: [
        _buildEstadoFilter(),
        const SizedBox(height: 8),
        _buildPedidoFilter(),
        const SizedBox(height: 8),
        _buildProductoFilter(),
        const SizedBox(height: 8),
        _buildFechaFilters(),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            OutlinedButton(
              onPressed: () {
                _searchController.clear();
                widget.viewModel.limpiarFiltros();
              },
              child: const Text('Limpiar filtros'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                widget.viewModel.cargarIncidencias();
              },
              child: const Text('Aplicar filtros'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEstadoFilter() {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: 'Estado',
        border: OutlineInputBorder(),
      ),
      value: widget.viewModel.filtrosActivos['estado'] as String? ?? '',
      onChanged: (String? value) {
        widget.viewModel.establecerEstadoFiltro(value ?? '');
      },
      items: [
        const DropdownMenuItem(value: '', child: Text('Todos los estados')),
        const DropdownMenuItem(value: 'pendiente', child: Text('Pendiente')),
        const DropdownMenuItem(value: 'resuelta', child: Text('Resuelta')),
        const DropdownMenuItem(value: 'cancelada', child: Text('Cancelada')),
      ],
    );
  }

  Widget _buildPedidoFilter() {
    return FutureBuilder<List<Pedido>>(
      future: widget.viewModel.obtenerPedidosUsuario(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LinearProgressIndicator();
        }

        final pedidos = snapshot.data ?? [];

        return DropdownButtonFormField<int?>(
          decoration: const InputDecoration(
            labelText: 'Pedido',
            border: OutlineInputBorder(),
          ),
          value: widget.viewModel.filtrosActivos['pedido_id'] as int?,
          onChanged: (int? value) {
            widget.viewModel.establecerPedidoFiltro(value);
          },
          items: [
            const DropdownMenuItem<int?>(
              value: null,
              child: Text('Todos los pedidos'),
            ),
            ...pedidos.map((pedido) {
              return DropdownMenuItem<int>(
                value: pedido.id,
                child: Text('Pedido #${pedido.id}'),
              );
            }),
          ],
        );
      },
    );
  }

  Widget _buildProductoFilter() {
    return DropdownButtonFormField<int?>(
      decoration: const InputDecoration(
        labelText: 'Producto',
        border: OutlineInputBorder(),
      ),
      value: widget.viewModel.filtrosActivos['producto_id'] as int?,
      onChanged: (int? value) {
        widget.viewModel.establecerProductoFiltro(value);
      },
      items: [
        const DropdownMenuItem<int?>(
          value: null,
          child: Text('Todos los productos'),
        ),
        ..._productos.map((producto) {
          final nombreProducto = producto.nombre;
          return DropdownMenuItem<int>(
            value: producto.id,
            child: Text(nombreProducto),
          );
        }),
      ],
    );
  }

  Widget _buildFechaFilters() {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () async {
              final fecha = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (fecha != null) {
                widget.viewModel.establecerFechaDesde(fecha);
              }
            },
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Desde',
                border: OutlineInputBorder(),
              ),
              child: Text(
                widget.viewModel.filtrosActivos['fecha_desde'] != null
                    ? widget.viewModel.filtrosActivos['fecha_desde']
                        .toString()
                        .split(' ')[0]
                    : 'Seleccionar',
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: InkWell(
            onTap: () async {
              final fecha = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (fecha != null) {
                widget.viewModel.establecerFechaHasta(fecha);
              }
            },
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Hasta',
                border: OutlineInputBorder(),
              ),
              child: Text(
                widget.viewModel.filtrosActivos['fecha_hasta'] != null
                    ? widget.viewModel.filtrosActivos['fecha_hasta']
                        .toString()
                        .split(' ')[0]
                    : 'Seleccionar',
              ),
            ),
          ),
        ),
      ],
    );
  }
}
