import 'package:flutter/material.dart';

class ProductFiltersWidget extends StatelessWidget {
  final String busqueda;
  final bool mostrarInactivos;
  final Function(String) onBusquedaChanged;
  final VoidCallback? onMostrarInactivosChanged;

  const ProductFiltersWidget({
    Key? key,
    required this.busqueda,
    required this.mostrarInactivos,
    required this.onBusquedaChanged,
    this.onMostrarInactivosChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Buscar productos...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: onBusquedaChanged,
            controller: TextEditingController(text: busqueda),
          ),
          if (onMostrarInactivosChanged != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                children: [
                  Checkbox(
                    value: mostrarInactivos,
                    onChanged: (_) => onMostrarInactivosChanged!(),
                  ),
                  const Text('Mostrar productos inactivos'),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
