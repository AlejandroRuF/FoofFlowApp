import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class VentasChartWidget extends StatelessWidget {
  final Map<String, dynamic> metricas;
  final String titulo;

  const VentasChartWidget({
    super.key,
    required this.metricas,
    this.titulo = 'Métricas de Ventas',
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titulo,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Comparativa mes actual vs mes anterior',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            SizedBox(height: 250, child: _buildChart(context)),
            const SizedBox(height: 8),
            _buildLeyenda(context),
          ],
        ),
      ),
    );
  }

  Widget _buildChart(BuildContext context) {
    if (metricas.isEmpty ||
        metricas['actual'] == null ||
        metricas['anterior'] == null) {
      return const Center(child: Text('No hay datos disponibles'));
    }

    final actual = metricas['actual'];
    final anterior = metricas['anterior'];

    final actuales = [
      actual['ingresos'] ?? 0.0,
      actual['gastos'] ?? 0.0,
      actual['beneficio'] ?? 0.0,
    ];

    final anteriores = [
      anterior['ingresos'] ?? 0.0,
      anterior['gastos'] ?? 0.0,
      anterior['beneficio'] ?? 0.0,
    ];

    final maxY =
        [
          ...actuales,
          ...anteriores,
        ].reduce((max, value) => value > max ? value : max) *
        1.2;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.blueGrey,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              String categoria;
              switch (group.x) {
                case 0:
                  categoria = 'Ingresos';
                  break;
                case 1:
                  categoria = 'Gastos';
                  break;
                case 2:
                  categoria = 'Beneficio';
                  break;
                default:
                  categoria = '';
              }

              String valor =
                  rodIndex == 0
                      ? '${actuales[group.x].toStringAsFixed(2)} €'
                      : '${anteriores[group.x].toStringAsFixed(2)} €';

              String periodo = rodIndex == 0 ? 'Actual' : 'Anterior';

              return BarTooltipItem(
                '$categoria\n$valor\n$periodo',
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
                String text;
                switch (value.toInt()) {
                  case 0:
                    text = 'Ingresos';
                    break;
                  case 1:
                    text = 'Gastos';
                    break;
                  case 2:
                    text = 'Beneficio';
                    break;
                  default:
                    text = '';
                }

                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    text,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value == 0) {
                  return const Text('0 €');
                }

                String label;
                if (value >= 1000000) {
                  label = '${(value / 1000000).toStringAsFixed(1)}M €';
                } else if (value >= 1000) {
                  label = '${(value / 1000).toStringAsFixed(1)}K €';
                } else {
                  label = '${value.toInt()} €';
                }

                return Text(label, style: const TextStyle(fontSize: 10));
              },
              reservedSize: 40,
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        barGroups: [
          BarChartGroupData(
            x: 0,
            barRods: [
              BarChartRodData(
                toY: actuales[0],
                color: Colors.blue,
                width: 15,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(3),
                ),
              ),
              BarChartRodData(
                toY: anteriores[0],
                color: Colors.blue.withOpacity(0.5),
                width: 15,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(3),
                ),
              ),
            ],
          ),
          BarChartGroupData(
            x: 1,
            barRods: [
              BarChartRodData(
                toY: actuales[1],
                color: Colors.red,
                width: 15,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(3),
                ),
              ),
              BarChartRodData(
                toY: anteriores[1],
                color: Colors.red.withOpacity(0.5),
                width: 15,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(3),
                ),
              ),
            ],
          ),
          BarChartGroupData(
            x: 2,
            barRods: [
              BarChartRodData(
                toY: actuales[2],
                color: Colors.green,
                width: 15,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(3),
                ),
              ),
              BarChartRodData(
                toY: anteriores[2],
                color: Colors.green.withOpacity(0.5),
                width: 15,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(3),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLeyenda(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLeyendaItem(Colors.blue, 'Mes Actual'),
        const SizedBox(width: 16),
        _buildLeyendaItem(Colors.blue.withOpacity(0.5), 'Mes Anterior'),
      ],
    );
  }

  Widget _buildLeyendaItem(Color color, String texto) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 4),
        Text(texto),
      ],
    );
  }
}
