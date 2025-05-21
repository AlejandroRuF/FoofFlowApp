import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:foodflow_app/features/orders/orders_viewmodel/order_form_viewmodel.dart';
import 'package:foodflow_app/features/shared/widgets/responsive_scaffold_widget.dart';

class OrderFormScreen extends StatefulWidget {
  final int pedidoId;

  const OrderFormScreen({Key? key, required this.pedidoId}) : super(key: key);

  @override
  State<OrderFormScreen> createState() => _OrderFormScreenState();
}

class _OrderFormScreenState extends State<OrderFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notasController = TextEditingController();
  bool _urgente = false;
  String? _estado;
  DateTime? _fechaEntregaReal;
  String? _motivoCancelacion;
  final _motivoCancelacionController = TextEditingController();

  @override
  void dispose() {
    _notasController.dispose();
    _motivoCancelacionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final viewModel = OrderFormViewModel();
        viewModel.cargarPedido(widget.pedidoId);
        return viewModel;
      },
      child: Consumer<OrderFormViewModel>(
        builder: (context, viewModel, _) {
          if (viewModel.pedido != null && _notasController.text.isEmpty) {
            _notasController.text = viewModel.pedido!.notas ?? '';
            _urgente = viewModel.pedido!.urgente;
            _estado = viewModel.pedido!.estado;
            if (viewModel.pedido!.fechaEntregaReal != null) {
              _fechaEntregaReal = DateTime.parse(
                viewModel.pedido!.fechaEntregaReal!,
              );
            }
            if (viewModel.pedido!.motivoCancelacion != null) {
              _motivoCancelacionController.text =
                  viewModel.pedido!.motivoCancelacion!;
            }
          }

          return ResponsiveScaffold(
            title: 'Editar Pedido #${widget.pedidoId}',
            body: _buildBody(context, viewModel),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, OrderFormViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Error: ${viewModel.error}',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => viewModel.cargarPedido(widget.pedidoId),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    final pedido = viewModel.pedido;
    if (pedido == null) {
      return const Center(child: Text('No se encontró el pedido'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Información del Pedido',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    _buildInfoText('Restaurante', pedido.restauranteNombre),
                    _buildInfoText(
                      'Cocina Central',
                      pedido.cocinaCentralNombre,
                    ),
                    _buildInfoText(
                      'Fecha de Pedido',
                      _formatDate(pedido.fechaPedido),
                    ),
                    _buildInfoText(
                      'Monto Total',
                      '€${pedido.montoTotal.toStringAsFixed(2)}',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Modificar Pedido',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    _buildEstadoDropdown(pedido.estado),
                    const SizedBox(height: 16),
                    if (_estado == 'cancelado') _buildMotivoCancelacionField(),
                    if (_estado == 'completado')
                      _buildFechaEntregaField(context),
                    const SizedBox(height: 16),
                    _buildNotasField(),
                    const SizedBox(height: 16),
                    _buildUrgenteSwitch(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () => _guardarCambios(context, viewModel),
                  child: const Text('Guardar Cambios'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoText(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildEstadoDropdown(String estadoActual) {
    List<String> estadosDisponibles = [];
    switch (estadoActual) {
      case 'pendiente':
        estadosDisponibles = ['pendiente', 'en_proceso', 'cancelado'];
        break;
      case 'en_proceso':
        estadosDisponibles = ['en_proceso', 'enviado', 'cancelado'];
        break;
      case 'enviado':
        estadosDisponibles = ['enviado', 'completado', 'cancelado'];
        break;
      case 'completado':
      case 'cancelado':
        estadosDisponibles = [estadoActual];
        break;
      default:
        estadosDisponibles = [
          'pendiente',
          'en_proceso',
          'enviado',
          'completado',
          'cancelado',
        ];
    }

    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: 'Estado del Pedido',
        border: OutlineInputBorder(),
      ),
      value: _estado,
      items:
          estadosDisponibles.map((estado) {
            return DropdownMenuItem<String>(
              value: estado,
              child: Text(_formatEstado(estado)),
            );
          }).toList(),
      onChanged: (value) {
        setState(() {
          _estado = value;
        });
      },
    );
  }

  Widget _buildMotivoCancelacionField() {
    return TextFormField(
      controller: _motivoCancelacionController,
      decoration: const InputDecoration(
        labelText: 'Motivo de Cancelación',
        border: OutlineInputBorder(),
      ),
      maxLines: 3,
      validator: (value) {
        if (_estado == 'cancelado' && (value == null || value.trim().isEmpty)) {
          return 'Por favor, indique el motivo de la cancelación';
        }
        return null;
      },
    );
  }

  Widget _buildFechaEntregaField(BuildContext context) {
    return InkWell(
      onTap: () => _selectDate(context),
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Fecha de Entrega Real',
          border: OutlineInputBorder(),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _fechaEntregaReal != null
                  ? '${_fechaEntregaReal!.day}/${_fechaEntregaReal!.month}/${_fechaEntregaReal!.year}'
                  : 'Seleccionar fecha',
            ),
            const Icon(Icons.calendar_today),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fechaEntregaReal ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _fechaEntregaReal) {
      setState(() {
        _fechaEntregaReal = picked;
      });
    }
  }

  Widget _buildNotasField() {
    return TextFormField(
      controller: _notasController,
      decoration: const InputDecoration(
        labelText: 'Notas',
        border: OutlineInputBorder(),
      ),
      maxLines: 3,
    );
  }

  Widget _buildUrgenteSwitch() {
    return Row(
      children: [
        const Text(
          'Marcar como Urgente',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const Spacer(),
        Switch(
          value: _urgente,
          onChanged: (value) {
            setState(() {
              _urgente = value;
            });
          },
        ),
      ],
    );
  }

  void _guardarCambios(BuildContext context, OrderFormViewModel viewModel) {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final cambios = <String, dynamic>{
      'estado': _estado,
      'notas': _notasController.text,
      'urgente': _urgente,
    };

    if (_estado == 'cancelado') {
      cambios['motivoCancelacion'] = _motivoCancelacionController.text;
    }

    if (_fechaEntregaReal != null) {
      cambios['fechaEntregaReal'] = _fechaEntregaReal!.toIso8601String();
    }

    viewModel.guardarCambios(cambios).then((success) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cambios guardados con éxito')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(viewModel.error ?? 'Error al guardar los cambios'),
          ),
        );
      }
    });
  }

  String _formatDate(String date) {
    final parsedDate = DateTime.parse(date);
    return '${parsedDate.day}/${parsedDate.month}/${parsedDate.year} ${parsedDate.hour}:${parsedDate.minute}';
  }

  String _formatEstado(String estado) {
    switch (estado) {
      case 'pendiente':
        return 'Pendiente';
      case 'en_proceso':
        return 'En Proceso';
      case 'enviado':
        return 'Enviado';
      case 'completado':
        return 'Completado';
      case 'cancelado':
        return 'Cancelado';
      default:
        return estado.replaceAll('_', ' ');
    }
  }
}
