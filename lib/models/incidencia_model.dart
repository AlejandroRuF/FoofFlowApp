class Incidencia {
  final int id;
  final int pedidoId;
  final int productoId;
  final String productoNombre;
  final int nuevaCantidad;
  final String descripcion;
  final String estado;
  final String estadoDisplay;
  final int? reportadoPorId;
  final String? reportadoPorNombre;
  final String? reportadoPorEmail;
  final String fechaReporte;
  final String? fechaResolucion;

  final String? clienteNombre;
  final String? proveedorNombre;

  Incidencia({
    required this.id,
    required this.pedidoId,
    required this.productoId,
    required this.productoNombre,
    required this.nuevaCantidad,
    required this.descripcion,
    required this.estado,
    required this.estadoDisplay,
    this.reportadoPorId,
    this.reportadoPorNombre,
    this.reportadoPorEmail,
    required this.fechaReporte,
    this.fechaResolucion,
    this.clienteNombre,
    this.proveedorNombre,
  });

  factory Incidencia.fromJson(Map<String, dynamic> json) {
    return Incidencia(
      id: json['id'],
      pedidoId: json['pedido_id'] ?? json['pedido'],
      productoId: json['producto'],
      productoNombre: json['producto_nombre'] ?? '',
      nuevaCantidad: json['nueva_cantidad'],
      descripcion: json['descripcion'],
      estado: json['estado'],
      estadoDisplay:
          json['estado_display'] ?? json['estado'].replaceAll('_', ' '),
      reportadoPorId: json['reportado_por'],
      reportadoPorNombre: json['reportado_por_nombre'],
      reportadoPorEmail: json['reportado_por_email'],
      fechaReporte: json['fecha_reporte'],
      fechaResolucion: json['fecha_resolucion'],
      clienteNombre: json['cliente_nombre'],
      proveedorNombre: json['proveedor_nombre'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pedido': pedidoId,
      'producto': productoId,
      'producto_nombre': productoNombre,
      'nueva_cantidad': nuevaCantidad,
      'descripcion': descripcion,
      'estado': estado,
      'estado_display': estadoDisplay,
      'reportado_por': reportadoPorId,
      'reportado_por_nombre': reportadoPorNombre,
      'reportado_por_email': reportadoPorEmail,
      'fecha_reporte': fechaReporte,
      'fecha_resolucion': fechaResolucion,
      'cliente_nombre': clienteNombre,
      'proveedor_nombre': proveedorNombre,
    };
  }

  Map<String, dynamic> toResumenDashboard() {
    final fechaFormateada = fechaReporte.substring(0, 10);
    return {
      'id': id,
      'pedido_id': pedidoId,
      'producto_id': productoId,
      'producto_nombre': productoNombre,
      'nueva_cantidad': nuevaCantidad,
      'descripcion': descripcion,
      'estado': estadoDisplay,
      'fecha_reporte': fechaReporte,
      'fecha': fechaFormateada,
      'reportado_por_nombre': reportadoPorNombre,
      'cliente_nombre': clienteNombre,
      'proveedor_nombre': proveedorNombre,
      'prioridad': _determinarPrioridad(),
    };
  }

  String _determinarPrioridad() {
    if (estado == 'pendiente') {
      return 'Alta';
    } else if (estado == 'en_proceso') {
      return 'Media';
    } else {
      return 'Baja';
    }
  }
}
