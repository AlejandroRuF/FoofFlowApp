class Almacen {
  final int id;
  final int usuarioId;
  final String usuarioNombre;
  final int productoId;
  final String productoNombre;
  final int stockActual;

  Almacen({
    required this.id,
    required this.usuarioId,
    required this.usuarioNombre,
    required this.productoId,
    required this.productoNombre,
    required this.stockActual,
  });

  factory Almacen.fromJson(Map<String, dynamic> json) {
    return Almacen(
      id: json['id'],
      usuarioId: json['usuario_id'],
      usuarioNombre: json['usuario_nombre'] ?? '',
      productoId: json['producto_id'],
      productoNombre: json['producto_nombre'] ?? '',
      stockActual: json['stock_actual'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'usuario_id': usuarioId,
      'usuario_nombre': usuarioNombre,
      'producto_id': productoId,
      'producto_nombre': productoNombre,
      'stock_actual': stockActual,
    };
  }

  Map<String, dynamic> toResumenDashboard() {
    return {
      'nombre': productoNombre,
      'cantidad': stockActual,
      'stock_minimo': 10,
      'unidad': 'unidad',
    };
  }
}
