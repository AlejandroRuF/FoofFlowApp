import 'package:foodflow_app/features/metrics/domain/sales_metric.dart';

abstract class MetricsRepository {
  Future<List<SalesMetrics>> getMetrics({
    required DateTime from,
    required DateTime to,
  });
}
