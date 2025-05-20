class DashboardModel {
  final String id;
  final String userId;
  final Map<String, dynamic> metricasVentas;
  final Map<String, dynamic> previsionDemanda;
  final DateTime fechaActualizacion;

  DashboardModel({
    required this.id,
    required this.userId,
    required this.metricasVentas,
    required this.previsionDemanda,
    required this.fechaActualizacion,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      metricasVentas: json['metricas_ventas'] ?? {},
      previsionDemanda: json['prevision_demanda'] ?? {},
      fechaActualizacion:
          json['fecha_actualizacion'] != null
              ? DateTime.parse(json['fecha_actualizacion'])
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'metricas_ventas': metricasVentas,
      'prevision_demanda': previsionDemanda,
      'fecha_actualizacion': fechaActualizacion.toIso8601String(),
    };
  }

  factory DashboardModel.empty() {
    return DashboardModel(
      id: '',
      userId: '',
      metricasVentas: {},
      previsionDemanda: {},
      fechaActualizacion: DateTime.now(),
    );
  }

  factory DashboardModel.fromInteractorData(Map<String, dynamic> data) {
    return DashboardModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: (data['usuario']?.id ?? '').toString(),
      metricasVentas: data['metricas_ventas'] ?? {},
      previsionDemanda: data['previsiones_demanda'] ?? {},
      fechaActualizacion: DateTime.now(),
    );
  }
}
