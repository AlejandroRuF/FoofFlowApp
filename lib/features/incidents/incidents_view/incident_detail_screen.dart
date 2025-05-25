import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:foodflow_app/features/incidents/incidents_viewmodel/incident_detail_view_model.dart';
import 'package:foodflow_app/features/shared/widgets/responsive_scaffold_widget.dart';

import '../../../../models/incidencia_model.dart';

class IncidentDetailScreen extends StatelessWidget {
  final int incidenciaId;

  const IncidentDetailScreen({Key? key, required this.incidenciaId})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final viewModel = IncidentDetailViewModel();
        viewModel.cargarIncidenciaDetalle(incidenciaId);
        return viewModel;
      },
      child: Consumer<IncidentDetailViewModel>(
        builder: (context, viewModel, _) {
          return ResponsiveScaffold(
            title: 'Detalle de Incidencia #$incidenciaId',
            body: _buildBody(context, viewModel),
            showBackButton: true,
            initialIndex: 3,
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, IncidentDetailViewModel viewModel) {
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
              onPressed: () => viewModel.cargarIncidenciaDetalle(incidenciaId),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    final incidencia = viewModel.incidencia;
    if (incidencia == null) {
      return const Center(child: Text('No se encontró la incidencia'));
    }

    final dateFormatter = DateFormat('dd/MM/yyyy HH:mm');
    final fechaReporte = DateTime.parse(incidencia.fechaReporte);
    final fechaReporteFormateada = dateFormatter.format(fechaReporte);

    DateTime? fechaResolucion;
    String fechaResolucionFormateada = 'Pendiente';
    if (incidencia.fechaResolucion != null) {
      fechaResolucion = DateTime.parse(incidencia.fechaResolucion!);
      fechaResolucionFormateada = dateFormatter.format(fechaResolucion);
    }

    final nombreProducto =
        incidencia.producto?.nombre ?? incidencia.productoNombre;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildEstadoCard(context, incidencia, viewModel),
            const SizedBox(height: 16),
            _buildInfoCard('Información de la Incidencia', [
              InfoItem('ID', '${incidencia.id}'),
              InfoItem('Pedido', '#${incidencia.pedidoId}'),
              InfoItem('Producto', nombreProducto),
              InfoItem('Nueva cantidad', '${incidencia.nuevaCantidad}'),
              InfoItem('Reportado por', incidencia.reportadoPorNombre ?? 'N/A'),
              InfoItem('Cliente', incidencia.clienteNombre ?? 'N/A'),
              InfoItem('Proveedor', incidencia.proveedorNombre ?? 'N/A'),
              if (incidencia.restauranteNombre != null)
                InfoItem('Restaurante', incidencia.restauranteNombre!),
              if (incidencia.cocinaCentralNombre != null)
                InfoItem('Cocina Central', incidencia.cocinaCentralNombre!),
              InfoItem('Fecha de reporte', fechaReporteFormateada),
              InfoItem('Fecha de resolución', fechaResolucionFormateada),
            ]),
            const SizedBox(height: 16),
            _buildDescripcionCard(incidencia.descripcion),
          ],
        ),
      ),
    );
  }

  Widget _buildEstadoCard(
    BuildContext context,
    Incidencia incidencia,
    IncidentDetailViewModel viewModel,
  ) {
    Color colorEstado;
    IconData iconoEstado;

    switch (incidencia.estado) {
      case 'pendiente':
        colorEstado = Colors.orange;
        iconoEstado = Icons.pending_actions;
        break;
      case 'resuelta':
        colorEstado = Colors.green;
        iconoEstado = Icons.check_circle;
        break;
      case 'cancelada':
        colorEstado = Colors.red;
        iconoEstado = Icons.cancel;
        break;
      default:
        colorEstado = Colors.grey;
        iconoEstado = Icons.help;
    }

    return Card(
      color: colorEstado.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(iconoEstado, color: colorEstado, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Estado: ${incidencia.estadoDisplay}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorEstado,
                  ),
                ),
              ],
            ),
            if (incidencia.estado == 'pendiente' &&
                viewModel.puedeGestionarIncidencia) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.check),
                    label: const Text('Marcar como resuelta'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder:
                            (dialogContext) => AlertDialog(
                              title: const Text('Confirmar resolución'),
                              content: const Text(
                                '¿Está seguro de marcar esta incidencia como resuelta? Esta acción no se puede deshacer.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(dialogContext),
                                  child: const Text('Cancelar'),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                  ),
                                  onPressed: () {
                                    Navigator.pop(dialogContext);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Esta funcionalidad aún no está implementada',
                                        ),
                                      ),
                                    );
                                  },
                                  child: const Text('Confirmar'),
                                ),
                              ],
                            ),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.cancel),
                    label: const Text('Cancelar incidencia'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder:
                            (dialogContext) => AlertDialog(
                              title: const Text('Confirmar cancelación'),
                              content: const Text(
                                '¿Está seguro de cancelar esta incidencia? Esta acción no se puede deshacer.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(dialogContext),
                                  child: const Text('No cancelar'),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                  ),
                                  onPressed: () {
                                    Navigator.pop(dialogContext);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Esta funcionalidad aún no está implementada',
                                        ),
                                      ),
                                    );
                                  },
                                  child: const Text('Sí, cancelar'),
                                ),
                              ],
                            ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _mostrarConfirmacionResolucion(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmar resolución'),
            content: const Text(
              '¿Está seguro de marcar esta incidencia como resuelta? Esta acción no se puede deshacer.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Esta funcionalidad aún no está implementada',
                      ),
                    ),
                  );
                },
                child: const Text('Confirmar'),
              ),
            ],
          ),
    );
  }

  void _mostrarConfirmacionCancelacion(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmar cancelación'),
            content: const Text(
              '¿Está seguro de cancelar esta incidencia? Esta acción no se puede deshacer.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('No cancelar'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Esta funcionalidad aún no está implementada',
                      ),
                    ),
                  );
                },
                child: const Text('Sí, cancelar'),
              ),
            ],
          ),
    );
  }

  Widget _buildInfoCard(String title, List<InfoItem> items) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 140,
                      child: Text(
                        '${item.label}:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                    Expanded(child: Text(item.value)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescripcionCard(String descripcion) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Descripción',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            Text(descripcion),
          ],
        ),
      ),
    );
  }
}

class InfoItem {
  final String label;
  final String value;

  InfoItem(this.label, this.value);
}
