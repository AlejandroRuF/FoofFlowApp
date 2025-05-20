import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/login/login_viewmodel/login_viewmodel.dart';
import '../../shared/widgets/responsive_scaffold_widget.dart';
import '../dashboard_viewmodel/dashboard_viewmodel.dart';
import 'widgets/ventas_chart_widget.dart';
import 'widgets/prevision_demanda_chart_widget.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DashboardViewModel>(
        context,
        listen: false,
      ).cargarDatosDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      title: 'FoodFlow - Dashboard',
      actions: [
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder:
                  (context) => AlertDialog(
                    title: const Text('Cerrar sesión'),
                    content: const Text(
                      '¿Estás seguro de que quieres cerrar sesión?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancelar'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('Cerrar sesión'),
                      ),
                    ],
                  ),
            );

            if (confirm == true) {
              final loginViewModel = Provider.of<LoginViewModel>(
                context,
                listen: false,
              );
              final success = await loginViewModel.logout();

              if (success) {
                Navigator.of(context).pushReplacementNamed('/login');
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      loginViewModel.errorMessage ?? 'Error al cerrar sesión',
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
        ),
      ],
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Consumer<DashboardViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (viewModel.errorMessage != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Error: ${viewModel.errorMessage}',
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    viewModel.cargarDatosDashboard();
                  },
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }

        if (viewModel.dashboardData == null) {
          return const Center(child: Text('No hay datos disponibles'));
        }

        return RefreshIndicator(
          onRefresh: () => viewModel.recargarDatos(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildEncabezado(viewModel),
                const SizedBox(height: 24),
                _buildTarjetasResumen(viewModel),
                const SizedBox(height: 24),
                VentasChartWidget(
                  metricas: viewModel.metricasVentas ?? {},
                  titulo: 'Métricas de Ventas',
                ),
                const SizedBox(height: 24),
                if (viewModel.debeMostrarPrevisiones() &&
                    viewModel.previsionDemanda != null)
                  PrevisionDemandaChartWidget(
                    previsiones: viewModel.previsionDemanda ?? {},
                    titulo: 'Previsión de Demanda',
                  ),
                SizedBox(
                  height: MediaQuery.of(context).size.width < 600 ? 60 : 0,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEncabezado(DashboardViewModel viewModel) {
    final usuario = viewModel.usuario;
    final nombreUsuario = usuario?.nombre ?? 'Usuario';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '¡Bienvenido, $nombreUsuario!',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Panel de control - ${_obtenerTipoUsuarioFormateado(viewModel.tipoUsuario)}',
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
      ],
    );
  }

  String _obtenerTipoUsuarioFormateado(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'administrador':
        return 'Administrador';
      case 'cocina_central':
        return 'Cocina Central';
      case 'restaurante':
        return 'Restaurante';
      case 'empleado':
        return 'Empleado';
      default:
        return 'Usuario';
    }
  }

  Widget _buildTarjetasResumen(DashboardViewModel viewModel) {
    final metricas = viewModel.metricasVentas;

    if (metricas == null || metricas['actual'] == null) {
      return const SizedBox.shrink();
    }

    final actual = metricas['actual'];
    final variacion = metricas['variacion'];

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildTarjetaResumen(
          'Ingresos',
          '${actual['ingresos'].toStringAsFixed(2)} €',
          variacion['ingresos'] ?? 0.0,
          Icons.trending_up,
          Colors.blue,
        ),
        _buildTarjetaResumen(
          'Gastos',
          '${actual['gastos'].toStringAsFixed(2)} €',
          variacion['gastos'] ?? 0.0,
          Icons.trending_down,
          Colors.red,
        ),
        _buildTarjetaResumen(
          'Beneficio',
          '${actual['beneficio'].toStringAsFixed(2)} €',
          variacion['beneficio'] ?? 0.0,
          Icons.account_balance,
          Colors.green,
        ),
        _buildTarjetaResumen(
          'Productos Vendidos',
          '${actual['productos_vendidos']}',
          variacion['productos_vendidos'] ?? 0.0,
          Icons.shopping_cart,
          Colors.amber,
        ),
      ],
    );
  }

  Widget _buildTarjetaResumen(
    String titulo,
    String valor,
    double variacion,
    IconData icono,
    Color color,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icono, size: 28, color: color),
            const SizedBox(height: 4),
            Text(
              titulo,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              valor,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  variacion >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 14,
                  color: variacion >= 0 ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 2),
                Flexible(
                  child: Text(
                    '${variacion.abs().toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: variacion >= 0 ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
