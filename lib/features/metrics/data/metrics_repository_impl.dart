import 'dart:math';

import '../domain/sales_metric.dart';
import 'metrics_repository.dart';

class MetricsRepositoryImpl implements MetricsRepository {
  @override
  Future<List<SalesMetrics>> getMetrics({
    required DateTime from,
    required DateTime to,
  }) async {
    final rng = Random();
    List<SalesMetrics> data = [];

    DateTime current = from;
    while (!current.isAfter(to)) {
      double ingresos = rng.nextInt(1000) + 500 + rng.nextDouble();
      double gastos = rng.nextInt(500) + 200 + rng.nextDouble();
      double beneficio = ingresos - gastos;

      data.add(
        SalesMetrics(
          date: current,
          ingresos: ingresos,
          gastos: gastos,
          beneficio: beneficio,
        ),
      );

      current = current.add(const Duration(days: 1));
    }

    // Simula retardo de red
    await Future.delayed(const Duration(milliseconds: 500));
    return data;
  }
}
