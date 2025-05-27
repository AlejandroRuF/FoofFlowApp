import 'package:flutter/material.dart';

class OrderFiltersWidget extends StatefulWidget {
  final String busquedaTexto;
  final String estadoSeleccionado;
  final String tipoPedidoSeleccionado;
  final bool? urgenteSeleccionado;
  final double? importeMin;
  final double? importeMax;
  final DateTime? fechaInicio;
  final DateTime? fechaFin;
  final Function(String) onBusquedaTextoChanged;
  final Function(String) onEstadoChanged;
  final Function(String) onTipoPedidoChanged;
  final Function(bool?) onUrgenteChanged;
  final Function(double?) onImporteMinChanged;
  final Function(double?) onImporteMaxChanged;
  final Function(DateTime?) onFechaInicioChanged;
  final Function(DateTime?) onFechaFinChanged;
  final VoidCallback onLimpiarFiltros;
  final VoidCallback onAplicarFiltros;

  const OrderFiltersWidget({
    super.key,
    required this.busquedaTexto,
    required this.estadoSeleccionado,
    required this.tipoPedidoSeleccionado,
    required this.urgenteSeleccionado,
    required this.importeMin,
    required this.importeMax,
    required this.fechaInicio,
    required this.fechaFin,
    required this.onBusquedaTextoChanged,
    required this.onEstadoChanged,
    required this.onTipoPedidoChanged,
    required this.onUrgenteChanged,
    required this.onImporteMinChanged,
    required this.onImporteMaxChanged,
    required this.onFechaInicioChanged,
    required this.onFechaFinChanged,
    required this.onLimpiarFiltros,
    required this.onAplicarFiltros,
  });

  @override
  State<OrderFiltersWidget> createState() => _OrderFiltersWidgetState();
}

class _OrderFiltersWidgetState extends State<OrderFiltersWidget> {
  bool _filtersExpanded = false;
  late final TextEditingController _busquedaController;
  late final TextEditingController _importeMinController;
  late final TextEditingController _importeMaxController;

  @override
  void initState() {
    super.initState();
    _busquedaController = TextEditingController(text: widget.busquedaTexto);
    _importeMinController = TextEditingController(
      text: widget.importeMin?.toString() ?? '',
    );
    _importeMaxController = TextEditingController(
      text: widget.importeMax?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _busquedaController.dispose();
    _importeMinController.dispose();
    _importeMaxController.dispose();
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
              _buildExpandedFilters(context),
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
            controller: _busquedaController,
            decoration: const InputDecoration(
              hintText: 'Buscar por restaurante, cocina, producto, notas...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              widget.onBusquedaTextoChanged(value);
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

  Widget _buildExpandedFilters(BuildContext context) {
    return Column(
      children: [
        _buildEstadoFilter(),
        const SizedBox(height: 8),
        _buildTipoPedidoFilter(),
        const SizedBox(height: 8),
        _buildUrgenteFilter(),
        const SizedBox(height: 8),
        _buildImporteFilters(),
        const SizedBox(height: 8),
        _buildFechaFilters(context),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            OutlinedButton(
              onPressed: () {
                _busquedaController.clear();
                _importeMinController.clear();
                _importeMaxController.clear();
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

  Widget _buildEstadoFilter() {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: 'Estado',
        border: OutlineInputBorder(),
      ),
      value:
          widget.estadoSeleccionado.isNotEmpty
              ? widget.estadoSeleccionado
              : null,
      onChanged: (String? value) {
        widget.onEstadoChanged(value ?? '');
      },
      items: const [
        DropdownMenuItem(value: '', child: Text('Todos los estados')),
        DropdownMenuItem(value: 'pendiente', child: Text('Pendiente')),
        DropdownMenuItem(value: 'en_proceso', child: Text('En proceso')),
        DropdownMenuItem(value: 'enviado', child: Text('Enviado')),
        DropdownMenuItem(value: 'completado', child: Text('Completado')),
        DropdownMenuItem(value: 'cancelado', child: Text('Cancelado')),
      ],
    );
  }

  Widget _buildTipoPedidoFilter() {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: 'Tipo de pedido',
        border: OutlineInputBorder(),
      ),
      value:
          widget.tipoPedidoSeleccionado.isNotEmpty
              ? widget.tipoPedidoSeleccionado
              : null,
      onChanged: (String? value) {
        widget.onTipoPedidoChanged(value ?? '');
      },
      items: const [
        DropdownMenuItem(value: '', child: Text('Todos los tipos')),
        DropdownMenuItem(value: 'normal', child: Text('Pedido normal')),
        DropdownMenuItem(value: 'por_prevision', child: Text('Por previsión')),
      ],
    );
  }

  Widget _buildUrgenteFilter() {
    return Row(
      children: [
        const Text('Urgente', style: TextStyle(fontSize: 16)),
        Checkbox(
          value: widget.urgenteSeleccionado ?? false,
          tristate: true,
          onChanged: (value) {
            widget.onUrgenteChanged(
              value == null || value == false ? null : value,
            ); // null = todos, true/false = filtrado
          },
        ),
        const Text('(Marcar para solo urgentes)'),
      ],
    );
  }

  Widget _buildImporteFilters() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _importeMinController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Importe mínimo',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              double? val = double.tryParse(value.replaceAll(',', '.'));
              widget.onImporteMinChanged(val);
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: _importeMaxController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Importe máximo',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              double? val = double.tryParse(value.replaceAll(',', '.'));
              widget.onImporteMaxChanged(val);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFechaFilters(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () async {
              final fecha = await showDatePicker(
                context: context,
                initialDate: widget.fechaInicio ?? DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (fecha != null) {
                widget.onFechaInicioChanged(fecha);
                setState(() {});
              }
            },
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Desde',
                border: OutlineInputBorder(),
              ),
              child: Text(
                widget.fechaInicio != null
                    ? '${widget.fechaInicio!.day}/${widget.fechaInicio!.month}/${widget.fechaInicio!.year}'
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
                initialDate: widget.fechaFin ?? DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (fecha != null) {
                widget.onFechaFinChanged(fecha);
                setState(() {});
              }
            },
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Hasta',
                border: OutlineInputBorder(),
              ),
              child: Text(
                widget.fechaFin != null
                    ? '${widget.fechaFin!.day}/${widget.fechaFin!.month}/${widget.fechaFin!.year}'
                    : 'Seleccionar',
              ),
            ),
          ),
        ),
      ],
    );
  }
}
