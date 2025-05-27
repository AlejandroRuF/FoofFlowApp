import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:foodflow_app/features/incidents/incidents_view/widgets/incident_card_widget.dart';
import 'package:foodflow_app/features/incidents/incidents_view/widgets/incident_filters_widget.dart';
import 'package:foodflow_app/features/shared/widgets/responsive_scaffold_widget.dart';

import '../incidents_viewmodel/incidents_viewmodel.dart';

class IncidentsScreen extends StatelessWidget {
  const IncidentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final viewModel = IncidentsViewModel();
        viewModel.cargarIncidencias();
        return viewModel;
      },
      child: Consumer<IncidentsViewModel>(
        builder: (context, viewModel, _) {
          if (!viewModel.puedeVerIncidencias) {
            return const ResponsiveScaffold(
              title: 'Gestión de Incidencias',
              body: Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'No tienes permiso para ver las incidencias',
                    style: TextStyle(fontSize: 18, color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              initialIndex: 4,
            );
          }

          return ResponsiveScaffold(
            title: 'Gestión de Incidencias',
            body: _buildBody(context, viewModel),
            floatingActionButton:
                viewModel.puedeCrearIncidencias
                    ? FloatingActionButton(
                      onPressed: () => context.push('/incidents/new'),
                      child: const Icon(Icons.add),
                    )
                    : null,
            initialIndex: 4,
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, IncidentsViewModel viewModel) {
    if (viewModel.isLoading) {
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
              onPressed: () => viewModel.cargarIncidencias(),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    final incidencias = viewModel.incidenciasFiltradas;

    if (incidencias.isEmpty) {
      return Column(
        children: [
          IncidentFiltersWidget(viewModel: viewModel),
          const Expanded(
            child: Center(
              child: Text(
                'No se encontraron incidencias con los filtros aplicados',
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        IncidentFiltersWidget(viewModel: viewModel),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => viewModel.cargarIncidencias(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: incidencias.length,
              itemBuilder: (context, index) {
                final incidencia = incidencias[index];
                return IncidentCardWidget(
                  incidencia: incidencia,
                  onTap:
                      () => context.push('/incidents/detail/${incidencia.id}'),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
