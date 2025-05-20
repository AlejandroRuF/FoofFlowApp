class PrevisionDemanda {
  final int id;
  final int? tramoMes;
  final int restauranteId;
  final int productoId;
  final int mes;
  final int anyo;
  final int demandaPrevista;
  final double variacionPorcentual;
  final bool esEstimada;

  PrevisionDemanda({
    required this.id,
    this.tramoMes,
    required this.restauranteId,
    required this.productoId,
    required this.mes,
    required this.anyo,
    required this.demandaPrevista,
    required this.variacionPorcentual,
    required this.esEstimada,
  });

  factory PrevisionDemanda.fromJson(Map<String, dynamic> json) {
    return PrevisionDemanda(
      id: json['id'],
      tramoMes: json['tramo_mes'],
      restauranteId: json['restaurante'],
      productoId: json['producto'],
      mes: json['mes'],
      anyo: json['anyo'],
      demandaPrevista: json['demanda_prevista'],
      variacionPorcentual: json['variacion_porcentual'].toDouble(),
      esEstimada: json['es_estimada'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tramo_mes': tramoMes,
      'restaurante': restauranteId,
      'producto': productoId,
      'mes': mes,
      'anyo': anyo,
      'demanda_prevista': demandaPrevista,
      'variacion_porcentual': variacionPorcentual,
      'es_estimada': esEstimada,
    };
  }

  String obtenerNombreTramo() {
    switch (tramoMes) {
      case 1:
        return "Días 1–10";
      case 2:
        return "Días 11–20";
      case 3:
        return "Días 21–fin de mes";
      default:
        return "Tramo no definido";
    }
  }
}
