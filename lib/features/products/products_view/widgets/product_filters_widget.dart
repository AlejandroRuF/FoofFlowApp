import 'package:flutter/material.dart';
import 'package:foodflow_app/models/categoria_model.dart';

class ProductFiltersWidget extends StatefulWidget {
  final String busqueda;
  final int? categoriaIdSeleccionada;
  final double? precioMin;
  final double? precioMax;
  final bool mostrarSoloActivos;
  final List<Categoria> categorias;
  final ValueChanged<String> onBusquedaChanged;
  final ValueChanged<int?> onCategoriaChanged;
  final ValueChanged<String?> onPrecioMinChanged;
  final ValueChanged<String?> onPrecioMaxChanged;
  final ValueChanged<bool> onMostrarSoloActivosChanged;
  final VoidCallback onLimpiarFiltros;
  final VoidCallback onAplicarFiltros;

  const ProductFiltersWidget({
    super.key,
    required this.busqueda,
    required this.categoriaIdSeleccionada,
    required this.precioMin,
    required this.precioMax,
    required this.mostrarSoloActivos,
    required this.categorias,
    required this.onBusquedaChanged,
    required this.onCategoriaChanged,
    required this.onPrecioMinChanged,
    required this.onPrecioMaxChanged,
    required this.onMostrarSoloActivosChanged,
    required this.onLimpiarFiltros,
    required this.onAplicarFiltros,
  });

  @override
  State<ProductFiltersWidget> createState() => _ProductFiltersWidgetState();
}

class _ProductFiltersWidgetState extends State<ProductFiltersWidget> {
  bool _filtersExpanded = false;
  late final TextEditingController _searchController;
  late final TextEditingController _precioMinController;
  late final TextEditingController _precioMaxController;
  bool _ignoreBusquedaChange = false;
  bool _ignorePrecioMinChange = false;
  bool _ignorePrecioMaxChange = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.busqueda);
    _precioMinController = TextEditingController(
      text: widget.precioMin?.toString() ?? '',
    );
    _precioMaxController = TextEditingController(
      text: widget.precioMax?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _precioMinController.dispose();
    _precioMaxController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ProductFiltersWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.busqueda != widget.busqueda &&
        _searchController.text != widget.busqueda) {
      _searchController.text = widget.busqueda;
    }

    if (widget.precioMin == null &&
        oldWidget.precioMin != null &&
        _precioMinController.text.isNotEmpty) {
      _precioMinController.text = '';
    }

    if (widget.precioMax == null &&
        oldWidget.precioMax != null &&
        _precioMaxController.text.isNotEmpty) {
      _precioMaxController.text = '';
    }
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
              hintText: 'Buscar por nombre, descripción o cocina central',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              if (!_ignoreBusquedaChange) {
                widget.onBusquedaChanged(value);
              }
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
        _buildCategoriaFilter(),
        const SizedBox(height: 8),
        _buildPreciosFilter(),
        const SizedBox(height: 8),
        _buildSoloActivosFilter(),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            OutlinedButton(
              onPressed: () {
                setState(() {
                  _searchController.clear();
                  _precioMinController.clear();
                  _precioMaxController.clear();
                });
                widget.onLimpiarFiltros();
              },
              child: const Text('Limpiar filtros'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: widget.onAplicarFiltros,
              child: const Text('Aplicar filtros'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoriaFilter() {
    return DropdownButtonFormField<int?>(
      decoration: const InputDecoration(
        labelText: 'Categoría',
        border: OutlineInputBorder(),
      ),
      value: widget.categoriaIdSeleccionada,
      onChanged: widget.onCategoriaChanged,
      items: [
        const DropdownMenuItem<int?>(
          value: null,
          child: Text('Todas las categorías'),
        ),
        ...widget.categorias.map((cat) {
          return DropdownMenuItem<int?>(value: cat.id, child: Text(cat.nombre));
        }),
      ],
    );
  }

  Widget _buildPreciosFilter() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _precioMinController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Precio mínimo',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              Future.delayed(const Duration(milliseconds: 800), () {
                if (_precioMinController.text == value) {
                  widget.onPrecioMinChanged(value);
                }
              });
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: _precioMaxController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Precio máximo',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              Future.delayed(const Duration(milliseconds: 800), () {
                if (_precioMaxController.text == value) {
                  widget.onPrecioMaxChanged(value);
                }
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSoloActivosFilter() {
    return Row(
      children: [
        Checkbox(
          value: widget.mostrarSoloActivos,
          onChanged:
              (value) => widget.onMostrarSoloActivosChanged(value ?? true),
        ),
        const Text('Solo activos'),
      ],
    );
  }
}
