import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class PrevisionDemandaChartWidget extends StatelessWidget {
  final Map<String, dynamic> previsiones;
  final String titulo;

  const PrevisionDemandaChartWidget({
    super.key,
    required this.previsiones,
    this.titulo = 'Previsión de Demanda',
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titulo,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Tramo actual: ${_obtenerNombreTramo(previsiones['tramo_actual'] ?? 0)}',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            if (previsiones['fecha_actualizacion'] != null)
              Text(
                'Última actualización: ${_formatearFecha(previsiones['fecha_actualizacion'])}',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            const SizedBox(height: 16),
            SizedBox(height: 250, child: _buildChart(context)),
            const SizedBox(height: 16),
            _buildIndicadores(context),
          ],
        ),
      ),
    );
  }

  String _obtenerNombreTramo(int tramo) {
    switch (tramo) {
      case 1:
        return "Días 1–10";
      case 2:
        return "Días 11–20";
      case 3:
        return "Días 21–fin de mes";
      default:
        return "No definido";
    }
  }

  String _formatearFecha(String fechaIso) {
    try {
      final fecha = DateTime.parse(fechaIso);
      return '${fecha.day}/${fecha.month}/${fecha.year} ${fecha.hour}:${fecha.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Fecha no disponible';
    }
  }

  Widget _buildChart(BuildContext context) {
    final previsionesTramoActual =
        previsiones['previsiones_tramo_actual'] ?? [];

    if (previsionesTramoActual.isEmpty) {
      return const Center(
        child: Text('No hay previsiones disponibles para el tramo actual'),
      );
    }

    final datos = previsionesTramoActual;
    double maxY = 0;

    final barGroups = <BarChartGroupData>[];

    for (int i = 0; i < datos.length; i++) {
      final item = datos[i];
      final demandaPrevista = (item['demanda_prevista'] ?? 0).toDouble();

      if (demandaPrevista > maxY) {
        maxY = demandaPrevista;
      }

      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: demandaPrevista,
              color: _obtenerColorSegunVariacion(
                (item['variacion_porcentual'] ?? 0.0).toDouble(),
              ),
              width: 18,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(3),
              ),
            ),
          ],
        ),
      );
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY * 1.2,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.blueGrey,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final item = datos[group.x];
              final producto =
                  item['producto_nombre'] ?? 'Producto ${group.x + 1}';
              final demanda = item['demanda_prevista'] ?? 0;
              final variacion =
                  (item['variacion_porcentual'] ?? 0.0).toDouble();

              return BarTooltipItem(
                '$producto\nDemanda: $demanda\nVariación: ${variacion.toStringAsFixed(1)}%',
                const TextStyle(color: Colors.white),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < datos.length) {
                  final item = datos[index];
                  final productoNombre =
                      item['producto_nombre'] ?? 'P${index + 1}';
                  String titulo = '';

                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      titulo,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value == 0) {
                  return const Text('0');
                }
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 10),
                );
              },
              reservedSize: 30,
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        barGroups: barGroups,
      ),
    );
  }

  Color _obtenerColorSegunVariacion(double variacion) {
    if (variacion > 10) {
      return Colors.green[800]!;
    } else if (variacion > 0) {
      return Colors.green[400]!;
    } else if (variacion > -10) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  Widget _buildIndicadores(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    final previsionesTramoActual =
        previsiones['previsiones_tramo_actual'] ?? [];
    final totalDemandaPrevista = _calcularTotalDemanda(previsionesTramoActual);
    final promedioVariacion = _calcularPromedioVariacion(
      previsionesTramoActual,
    );
    final totalProductos = previsiones['total_productos_prevision'] ?? 0;

    if (isSmallScreen) {
      return Column(
        children: [
          _buildIndicador(
            'Total demanda',
            totalDemandaPrevista.toString(),
            Icons.trending_up,
            Colors.blue,
          ),
          const SizedBox(height: 8),
          _buildIndicador(
            'Variación promedio',
            '${promedioVariacion.toStringAsFixed(1)}%',
            Icons.percent,
            Colors.amber,
          ),
          const SizedBox(height: 8),
          _buildIndicador(
            'Productos analizados',
            totalProductos.toString(),
            Icons.bar_chart,
            Colors.purple,
          ),
        ],
      );
    } else {
      return Column(
        children: [
          Row(
            children: [
              Flexible(
                child: _buildIndicador(
                  'Total demanda',
                  totalDemandaPrevista.toString(),
                  Icons.trending_up,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: _buildIndicador(
                  'Variación promedio',
                  '${promedioVariacion.toStringAsFixed(1)}%',
                  Icons.percent,
                  Colors.amber,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildIndicador(
            'Productos analizados',
            totalProductos.toString(),
            Icons.bar_chart,
            Colors.purple,
          ),
        ],
      );
    }
  }

  int _calcularTotalDemanda(List<dynamic> previsiones) {
    if (previsiones.isEmpty) return 0;
    return previsiones.fold<int>(
      0,
      (sum, item) => sum + (item['demanda_prevista'] ?? 0) as int,
    );
  }

  double _calcularPromedioVariacion(List<dynamic> previsiones) {
    if (previsiones.isEmpty) return 0.0;
    final suma = previsiones.fold<double>(
      0.0,
      (sum, item) => sum + (item['variacion_porcentual'] ?? 0.0).toDouble(),
    );
    return suma / previsiones.length;
  }

  Widget _buildIndicador(
    String titulo,
    String valor,
    IconData icono,
    Color color,
  ) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Column(
            children: [
              Icon(icono, color: color),
              const SizedBox(height: 4),
              Text(
                titulo,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              Text(
                valor,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
