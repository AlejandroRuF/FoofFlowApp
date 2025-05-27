import 'package:flutter/material.dart';
import 'package:foodflow_app/models/user_model.dart';

class OrderFiltersWidget extends StatelessWidget {
  final DateTime? fechaInicio;
  final DateTime? fechaFin;
  final User? usuarioFiltro;
  final List<User> usuariosDisponibles;
  final Function(DateTime?) onFechaInicioChanged;
  final Function(DateTime?) onFechaFinChanged;
  final Function(User?) onUsuarioChanged;
  final VoidCallback onLimpiarFiltros;

  const OrderFiltersWidget({
    super.key,
    this.fechaInicio,
    this.fechaFin,
    this.usuarioFiltro,
    required this.usuariosDisponibles,
    required this.onFechaInicioChanged,
    required this.onFechaFinChanged,
    required this.onUsuarioChanged,
    required this.onLimpiarFiltros,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Filtros', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildDateField(
                    context,
                    'Desde',
                    fechaInicio,
                    onFechaInicioChanged,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDateField(
                    context,
                    'Hasta',
                    fechaFin,
                    onFechaFinChanged,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (usuariosDisponibles.isNotEmpty) ...[
              _buildUserDropdown(context),
              const SizedBox(height: 16),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: onLimpiarFiltros,
                  child: const Text('Limpiar filtros'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateField(
    BuildContext context,
    String label,
    DateTime? selectedDate,
    Function(DateTime?) onDateChanged,
  ) {
    return InkWell(
      onTap: () => _selectDate(context, selectedDate, onDateChanged),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              selectedDate != null
                  ? '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'
                  : 'Seleccionar fecha',
              style: TextStyle(
                color:
                    selectedDate != null ? Colors.black : Colors.grey.shade600,
              ),
            ),
            const Icon(Icons.calendar_today, size: 18),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(
    BuildContext context,
    DateTime? initialDate,
    Function(DateTime?) onDateChanged,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != initialDate) {
      onDateChanged(picked);
    }
  }

  Widget _buildUserDropdown(BuildContext context) {
    return DropdownButtonFormField<User?>(
      decoration: const InputDecoration(
        labelText: 'Filtrar por usuario',
        border: OutlineInputBorder(),
      ),
      value: usuarioFiltro,
      hint: const Text('Seleccionar usuario'),
      isExpanded: true,
      items: [
        const DropdownMenuItem<User?>(value: null, child: Text('Todos')),
        ...usuariosDisponibles.map((user) {
          return DropdownMenuItem<User?>(
            value: user,
            child: Text(
              '${user.nombre} (${_getTipoUsuario(user.tipoUsuario)})',
            ),
          );
        }),
      ],
      onChanged: (value) => onUsuarioChanged(value),
    );
  }

  String _getTipoUsuario(String tipo) {
    switch (tipo) {
      case 'restaurante':
        return 'Restaurante';
      case 'cocina_central':
        return 'Cocina Central';
      case 'administrador':
        return 'Admin';
      case 'empleado':
        return 'Empleado';
      default:
        return tipo;
    }
  }
}
