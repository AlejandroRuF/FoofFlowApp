import 'package:foodflow_app/features/metrics/domain/sales_metric.dart';

import '../../data/metrics_repository.dart';

class GetMetricsUseCase {
  final MetricsRepository _repository;

  GetMetricsUseCase(this._repository);

  Future<List<SalesMetrics>> execute(DateTime from, DateTime to) async {
    return await _repository.getMetrics(from: from, to: to);
  }
}
