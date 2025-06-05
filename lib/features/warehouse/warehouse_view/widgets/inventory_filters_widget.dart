import 'package:flutter/material.dart';
import 'package:foodflow_app/models/categoria_model.dart';

class InventoryFiltersWidget extends StatefulWidget {
  final String busqueda;
  final bool mostrarStockBajo;
  final double? stockMinimo;
  final double? stockMaximo;
  final int? categoriaIdSeleccionada;
  final bool soloActivos;
  final List<Categoria> categorias;
  final ValueChanged<String> onBusquedaChanged;
  final ValueChanged<bool> onMostrarStockBajoChanged;
  final ValueChanged<String?> onStockMinimoChanged;
  final ValueChanged<String?> onStockMaximoChanged;
  final ValueChanged<int?> onCategoriaChanged;
  final ValueChanged<bool> onSoloActivosChanged;
  final VoidCallback onLimpiarFiltros;
  final VoidCallback onAplicarFiltros;

  const InventoryFiltersWidget({
    super.key,
    required this.busqueda,
    required this.mostrarStockBajo,
    this.stockMinimo,
    this.stockMaximo,
    this.categoriaIdSeleccionada,
    required this.soloActivos,
    this.categorias = const [],
    required this.onBusquedaChanged,
    required this.onMostrarStockBajoChanged,
    required this.onStockMinimoChanged,
    required this.onStockMaximoChanged,
    required this.onCategoriaChanged,
    required this.onSoloActivosChanged,
    required this.onLimpiarFiltros,
    required this.onAplicarFiltros,
  });

  @override
  State<InventoryFiltersWidget> createState() => _InventoryFiltersWidgetState();
}

class _InventoryFiltersWidgetState extends State<InventoryFiltersWidget> {
  bool _filtersExpanded = false;
  late final TextEditingController _searchController;
  late final TextEditingController _stockMinimoController;
  late final TextEditingController _stockMaximoController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.busqueda);
    _stockMinimoController = TextEditingController(
      text: widget.stockMinimo?.toString() ?? '',
    );
    _stockMaximoController = TextEditingController(
      text: widget.stockMaximo?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _stockMinimoController.dispose();
    _stockMaximoController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant InventoryFiltersWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.busqueda != widget.busqueda &&
        _searchController.text != widget.busqueda) {
      _searchController.text = widget.busqueda;
    }

    if (widget.stockMinimo == null &&
        oldWidget.stockMinimo != null &&
        _stockMinimoController.text.isNotEmpty) {
      _stockMinimoController.text = '';
    }

    if (widget.stockMaximo == null &&
        oldWidget.stockMaximo != null &&
        _stockMaximoController.text.isNotEmpty) {
      _stockMaximoController.text = '';
    }

    if (oldWidget.categoriaIdSeleccionada != widget.categoriaIdSeleccionada) {
      setState(() {});
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
              hintText: 'Buscar productos en inventario...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: widget.onBusquedaChanged,
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
        if (widget.categorias.isNotEmpty) ...[
          _buildCategoriaFilter(),
          const SizedBox(height: 8),
        ],
        _buildStockFilter(),
        const SizedBox(height: 8),
        _buildCheckboxFilters(),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            OutlinedButton(
              onPressed: _limpiarTodosFiltros,
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

  void _limpiarTodosFiltros() {
    setState(() {
      _searchController.clear();
      _stockMinimoController.clear();
      _stockMaximoController.clear();
    });
    widget.onCategoriaChanged(null);
    widget.onLimpiarFiltros();
  }

  Widget _buildCategoriaFilter() {
    return DropdownButtonFormField<int?>(
      decoration: const InputDecoration(
        labelText: 'Categoría',
        border: OutlineInputBorder(),
      ),
      value: widget.categoriaIdSeleccionada,
      onChanged: (value) {
        widget.onCategoriaChanged(value);
      },
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

  Widget _buildStockFilter() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _stockMinimoController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Stock mínimo',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              Future.delayed(const Duration(milliseconds: 800), () {
                if (_stockMinimoController.text == value) {
                  widget.onStockMinimoChanged(value);
                }
              });
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: _stockMaximoController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Stock máximo',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              Future.delayed(const Duration(milliseconds: 800), () {
                if (_stockMaximoController.text == value) {
                  widget.onStockMaximoChanged(value);
                }
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCheckboxFilters() {
    return Column(
      children: [
        Row(
          children: [
            Checkbox(
              value: widget.mostrarStockBajo,
              onChanged:
                  (value) => widget.onMostrarStockBajoChanged(value ?? false),
            ),
            const Text('Mostrar solo productos con stock bajo'),
          ],
        ),
        Row(
          children: [
            Checkbox(
              value: widget.soloActivos,
              onChanged: (value) => widget.onSoloActivosChanged(value ?? true),
            ),
            const Text('Solo activos'),
          ],
        ),
      ],
    );
  }
}
