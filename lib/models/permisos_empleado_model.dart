class PermisosEmpleado {
  final int id;
  final bool puedeVerProductos;
  final bool puedeCrearProductos;
  final bool puedeEditarProductos;
  final bool puedeDesactivarProductos;
  final bool puedeVerHistorialProducto;
  final bool puedeVerUsuarios;
  final bool puedeCrearUsuarios;
  final bool puedeEditarUsuarios;
  final bool puedeEliminarUsuarios;
  final bool puedeVerAlmacenes;
  final bool puedeCrearAlmacenes;
  final bool puedeModificarAlmacenes;
  final bool puedeVerPedidos;
  final bool puedeCrearPedidos;
  final bool puedeEditarPedidos;
  final bool puedeVerIncidencias;
  final bool puedeCrearIncidencias;
  final bool puedeVerPedidoProducto;
  final bool puedeCrearPedidoProducto;
  final bool puedeEditarPedidoProducto;
  final bool puedeEliminarPedidoProducto;
  final bool puedeVerMetricas;
  final bool puedeVerPrevisionDemanda;
  final int empleadoId;

  PermisosEmpleado({
    required this.id,
    required this.puedeVerProductos,
    required this.puedeCrearProductos,
    required this.puedeEditarProductos,
    required this.puedeDesactivarProductos,
    required this.puedeVerHistorialProducto,
    required this.puedeVerUsuarios,
    required this.puedeCrearUsuarios,
    required this.puedeEditarUsuarios,
    required this.puedeEliminarUsuarios,
    required this.puedeVerAlmacenes,
    required this.puedeCrearAlmacenes,
    required this.puedeModificarAlmacenes,
    required this.puedeVerPedidos,
    required this.puedeCrearPedidos,
    required this.puedeEditarPedidos,
    required this.puedeVerIncidencias,
    required this.puedeCrearIncidencias,
    required this.puedeVerPedidoProducto,
    required this.puedeCrearPedidoProducto,
    required this.puedeEditarPedidoProducto,
    required this.puedeEliminarPedidoProducto,
    required this.puedeVerMetricas,
    required this.puedeVerPrevisionDemanda,
    required this.empleadoId,
  });

  factory PermisosEmpleado.fromJson(Map<String, dynamic> json) {
    return PermisosEmpleado(
      id: json['id'],
      puedeVerProductos: json['puede_ver_productos'] ?? false,
      puedeCrearProductos: json['puede_crear_productos'] ?? false,
      puedeEditarProductos: json['puede_editar_productos'] ?? false,
      puedeDesactivarProductos: json['puede_desactivar_productos'] ?? false,
      puedeVerHistorialProducto: json['puede_ver_historial_producto'] ?? false,
      puedeVerUsuarios: json['puede_ver_usuarios'] ?? false,
      puedeCrearUsuarios: json['puede_crear_usuarios'] ?? false,
      puedeEditarUsuarios: json['puede_editar_usuarios'] ?? false,
      puedeEliminarUsuarios: json['puede_eliminar_usuarios'] ?? false,
      puedeVerAlmacenes: json['puede_ver_almacenes'] ?? false,
      puedeCrearAlmacenes: json['puede_crear_almacenes'] ?? false,
      puedeModificarAlmacenes: json['puede_modificar_almacenes'] ?? false,
      puedeVerPedidos: json['puede_ver_pedidos'] ?? false,
      puedeCrearPedidos: json['puede_crear_pedidos'] ?? false,
      puedeEditarPedidos: json['puede_editar_pedidos'] ?? false,
      puedeVerIncidencias: json['puede_ver_incidencias'] ?? false,
      puedeCrearIncidencias: json['puede_crear_incidencias'] ?? false,
      puedeVerPedidoProducto: json['puede_ver_pedidoProducto'] ?? false,
      puedeCrearPedidoProducto: json['puede_crear_pedidoProducto'] ?? false,
      puedeEditarPedidoProducto: json['puede_editar_pedidoProducto'] ?? false,
      puedeEliminarPedidoProducto:
          json['puede_eliminar_pedidoProducto'] ?? false,
      puedeVerMetricas: json['puede_ver_metricas'] ?? false,
      puedeVerPrevisionDemanda: json['puede_ver_prevision_demanda'] ?? false,
      empleadoId: json['empleado'],
    );
  }

  bool get puedeVerInventario => puedeVerProductos || puedeVerAlmacenes;

  bool get tieneAccesoAlDashboard =>
      puedeVerMetricas ||
      puedeVerPrevisionDemanda ||
      puedeVerPedidos ||
      puedeVerInventario ||
      puedeVerIncidencias;

  bool get puedeGestionarProductos =>
      puedeCrearProductos || puedeEditarProductos || puedeDesactivarProductos;

  bool get puedeGestionarPedidos => puedeCrearPedidos || puedeEditarPedidos;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'puede_ver_productos': puedeVerProductos,
      'puede_crear_productos': puedeCrearProductos,
      'puede_editar_productos': puedeEditarProductos,
      'puede_desactivar_productos': puedeDesactivarProductos,
      'puede_ver_historial_producto': puedeVerHistorialProducto,
      'puede_ver_usuarios': puedeVerUsuarios,
      'puede_crear_usuarios': puedeCrearUsuarios,
      'puede_editar_usuarios': puedeEditarUsuarios,
      'puede_eliminar_usuarios': puedeEliminarUsuarios,
      'puede_ver_almacenes': puedeVerAlmacenes,
      'puede_crear_almacenes': puedeCrearAlmacenes,
      'puede_modificar_almacenes': puedeModificarAlmacenes,
      'puede_ver_pedidos': puedeVerPedidos,
      'puede_crear_pedidos': puedeCrearPedidos,
      'puede_editar_pedidos': puedeEditarPedidos,
      'puede_ver_incidencias': puedeVerIncidencias,
      'puede_crear_incidencias': puedeCrearIncidencias,
      'puede_ver_pedidoProducto': puedeVerPedidoProducto,
      'puede_crear_pedidoProducto': puedeCrearPedidoProducto,
      'puede_editar_pedidoProducto': puedeEditarPedidoProducto,
      'puede_eliminar_pedidoProducto': puedeEliminarPedidoProducto,
      'puede_ver_metricas': puedeVerMetricas,
      'puede_ver_prevision_demanda': puedeVerPrevisionDemanda,
      'empleado': empleadoId,
    };
  }
}
