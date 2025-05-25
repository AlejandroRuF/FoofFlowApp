import 'producto_model.dart';

class Incidencia {
  final int id;
  final int pedidoId;
  final int productoId;
  final String productoNombre;
  final Producto? producto; // Nuevo: objeto anidado producto (opcional)
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

  // Nuevos campos de la API
  final int? restauranteId;
  final String? restauranteNombre;
  final int? cocinaCentralId;
  final String? cocinaCentralNombre;

  Incidencia({
    required this.id,
    required this.pedidoId,
    required this.productoId,
    required this.productoNombre,
    this.producto,
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
    this.restauranteId,
    this.restauranteNombre,
    this.cocinaCentralId,
    this.cocinaCentralNombre,
  });

  factory Incidencia.fromJson(Map<String, dynamic> json) {
    Producto? productoObj;
    int? productoId;
    String? productoNombre;

    // Si producto es objeto (nuevo formato), sino es ID (viejo formato)
    if (json['producto'] is Map) {
      productoObj = Producto.fromJson(json['producto']);
      productoId = json['producto']['id'] ?? 0;
      productoNombre = json['producto']['nombre'] ?? '';
    } else {
      productoId = json['producto'];
      productoNombre = json['producto_nombre'] ?? '';
    }

    return Incidencia(
      id: json['id'],
      pedidoId: json['pedido_id'] ?? json['pedido'],
      productoId: productoId ?? 0,
      productoNombre: productoNombre ?? '',
      producto: productoObj,
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
      restauranteId: json['restaurante_id'],
      restauranteNombre: json['restaurante_nombre'],
      cocinaCentralId: json['cocina_central_id'],
      cocinaCentralNombre: json['cocina_central_nombre'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pedido': pedidoId,
      'producto': producto != null ? producto!.toJson() : productoId,
      'producto_nombre': producto != null ? producto!.nombre : productoNombre,
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
      'restaurante_id': restauranteId,
      'restaurante_nombre': restauranteNombre,
      'cocina_central_id': cocinaCentralId,
      'cocina_central_nombre': cocinaCentralNombre,
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
      'restaurante_nombre': restauranteNombre,
      'cocina_central_nombre': cocinaCentralNombre,
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
