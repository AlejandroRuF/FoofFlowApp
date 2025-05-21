import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/login/login_viewmodel/login_viewmodel.dart';
import '../../shared/widgets/responsive_scaffold_widget.dart';
import '../dashboard_viewmodel/dashboard_viewmodel.dart';
import 'widgets/ventas_chart_widget.dart';
import 'widgets/prevision_demanda_chart_widget.dart';
import 'widgets/pedidos_activos_widget.dart';
import 'widgets/inventario_widget.dart';
import 'widgets/incidencias_widget.dart';

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

                if (viewModel.metricasVentas != null)
                  VentasChartWidget(
                    metricas: viewModel.metricasVentas ?? {},
                    titulo: 'Métricas de Ventas',
                  ),
                const SizedBox(height: 24),

                if (viewModel.dashboardData?['pedidos_activos'] != null)
                  PedidosActivosWidget(
                    pedidos: viewModel.pedidosActivos!,
                    tipoUsuario: viewModel.tipoUsuario,
                    usuarioId: viewModel.usuario?.id,
                    isDarkMode: Theme.of(context).brightness == Brightness.dark,
                  ),
                if (viewModel.dashboardData?['pedidos_activos'] != null)
                  const SizedBox(height: 24),

                if (viewModel.dashboardData?['inventario'] != null)
                  InventarioWidget(
                    inventario: viewModel.inventario!,
                    tipoUsuario: viewModel.tipoUsuario,
                  ),
                if (viewModel.dashboardData?['inventario'] != null)
                  const SizedBox(height: 24),

                if (viewModel.dashboardData?['incidencias'] != null)
                  IncidenciasWidget(
                    incidencias: viewModel.incidencias!,
                    tipoUsuario: viewModel.tipoUsuario,
                    usuarioId: viewModel.usuario?.id,
                    isDarkMode: Theme.of(context).brightness == Brightness.dark,
                  ),
                if (viewModel.dashboardData?['incidencias'] != null)
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
    final screenWidth = MediaQuery.of(context).size.width;

    if (metricas == null || metricas['actual'] == null) {
      return const SizedBox.shrink();
    }

    final actual = metricas['actual'];
    final variacion = metricas['variacion'];

    int crossAxisCount = 2;
    if (screenWidth > 900) {
      crossAxisCount = 4;
    } else if (screenWidth > 600) {
      crossAxisCount = 3;
    }

    return GridView.count(
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio:
          screenWidth > 600 ? (screenWidth / (150 * crossAxisCount)) : 1.0,
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
    final isWideScreen = MediaQuery.of(context).size.width > 600;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Container(
        constraints:
            isWideScreen
                ? const BoxConstraints(maxHeight: 150)
                : const BoxConstraints(),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: isWideScreen ? MainAxisSize.min : MainAxisSize.max,
            children: [
              Icon(icono, size: 28, color: color),
              const SizedBox(height: 4),
              Text(
                titulo,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                valor,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
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
      ),
    );
  }
}
