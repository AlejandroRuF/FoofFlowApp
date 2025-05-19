class MetricasVentas {
  final int id;
  final int usuarioId;
  final int productoId;
  final int anio;
  final int mes;
  final int? dia;
  final int totalVendido;
  final double ingresos;
  final double gastos;
  final double beneficio;
  
  MetricasVentas({
    required this.id,
    required this.usuarioId,
    required this.productoId,
    required this.anio,
    required this.mes,
    this.dia,
    required this.totalVendido,
    required this.ingresos,
    required this.gastos,
    required this.beneficio,
  });
  
  factory MetricasVentas.fromJson(Map<String, dynamic> json) {
    return MetricasVentas(
      id: json['id'],
      usuarioId: json['usuario'],
      productoId: json['producto'],
      anio: json['anio'],
      mes: json['mes'],
      dia: json['dia'],
      totalVendido: json['total_vendido'],
      ingresos: json['ingresos'].toDouble(),
      gastos: json['gastos'].toDouble(),
      beneficio: json['beneficio'].toDouble(),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'usuario': usuarioId,
      'producto': productoId,
      'anio': anio,
      'mes': mes,
      'dia': dia,
      'total_vendido': totalVendido,
      'ingresos': ingresos,
      'gastos': gastos,
      'beneficio': beneficio,
    };
  }
}