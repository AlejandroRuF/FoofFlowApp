import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class PrevisionDemandaChartWidget extends StatelessWidget {
  final Map<String, dynamic> previsiones;
  final String titulo;

  const PrevisionDemandaChartWidget({
    Key? key,
    required this.previsiones,
    this.titulo = 'Previsión de Demanda',
  }) : super(key: key);

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

  Widget _buildChart(BuildContext context) {
    final tramo = previsiones['tramo_actual'] ?? 0;
    final previsionesTramoActual =
        previsiones['previsiones_tramo_actual'] ?? [];

    if (previsionesTramoActual.isEmpty) {
      return const Center(
        child: Text('No hay previsiones disponibles para el tramo actual'),
      );
    }

    final datos =
        previsionesTramoActual.isEmpty
            ? _generarDatosEjemplo()
            : previsionesTramoActual;

    double maxY = 0;

    final barGroups = <BarChartGroupData>[];

    for (int i = 0; i < datos.length; i++) {
      final item = datos[i];
      final demandaPrevista = item['demanda_prevista'] ?? 0;

      if (demandaPrevista > maxY) {
        maxY = demandaPrevista.toDouble();
      }

      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: demandaPrevista.toDouble(),
              color: _obtenerColorSegunVariacion(
                item['variacion_porcentual'] ?? 0,
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

    return datos.isEmpty
        ? const Center(child: Text('No hay datos disponibles'))
        : BarChart(
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
                  final variacion = item['variacion_porcentual'] ?? 0.0;

                  return BarTooltipItem(
                    '$producto\nDemanda: $demanda\nVariación: ${variacion.toStringAsFixed(2)}%',
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
                      String titulo =
                          productoNombre.length > 6
                              ? '${productoNombre.substring(0, 5)}...'
                              : productoNombre;

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
              rightTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            borderData: FlBorderData(show: false),
            barGroups: barGroups,
          ),
        );
  }

  List<Map<String, dynamic>> _generarDatosEjemplo() {
    return [
      {
        'producto_nombre': 'Hamburguesa',
        'demanda_prevista': 120,
        'variacion_porcentual': 5.3,
      },
      {
        'producto_nombre': 'Pizza',
        'demanda_prevista': 93,
        'variacion_porcentual': -2.1,
      },
      {
        'producto_nombre': 'Ensalada',
        'demanda_prevista': 45,
        'variacion_porcentual': 12.7,
      },
      {
        'producto_nombre': 'Pasta',
        'demanda_prevista': 67,
        'variacion_porcentual': -8.4,
      },
      {
        'producto_nombre': 'Postre',
        'demanda_prevista': 38,
        'variacion_porcentual': 3.9,
      },
    ];
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
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildIndicador(
              'Total demanda',
              '${previsiones['total_demanda_prevista'] ?? 0}',
              Icons.trending_up,
              Colors.blue,
            ),
            _buildIndicador(
              'Variación promedio',
              '${(previsiones['promedio_variacion'] ?? 0).toStringAsFixed(2)}%',
              Icons.percent,
              Colors.amber,
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildIndicador(
          'Previsiones estimadas',
          '${(previsiones['porcentaje_estimadas'] ?? 0).toStringAsFixed(1)}%',
          Icons.bar_chart,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildIndicador(
    String titulo,
    String valor,
    IconData icono,
    Color color,
  ) {
    return Card(
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
            ),
            Text(
              valor,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
