import 'package:foodflow_app/models/incidencia_model.dart';

class IncidentsModel {
  final List<Incidencia> incidencias;
  final Incidencia? incidenciaSeleccionada;
  final bool isLoading;
  final String? error;
  final Map<String, dynamic> filtrosActivos;

  IncidentsModel({
    this.incidencias = const [],
    this.incidenciaSeleccionada,
    this.isLoading = false,
    this.error,
    this.filtrosActivos = const {},
  });

  IncidentsModel copyWith({
    List<Incidencia>? incidencias,
    Incidencia? incidenciaSeleccionada,
    bool? isLoading,
    String? error,
    Map<String, dynamic>? filtrosActivos,
  }) {
    return IncidentsModel(
      incidencias: incidencias ?? this.incidencias,
      incidenciaSeleccionada:
          incidenciaSeleccionada ?? this.incidenciaSeleccionada,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      filtrosActivos: filtrosActivos ?? this.filtrosActivos,
    );
  }

  List<Incidencia> filtrarIncidencias({
    String? textoBusqueda,
    String? estado,
    int? pedidoId,
    int? productoId,
    DateTime? fechaDesde,
    DateTime? fechaHasta,
    int? usuarioId,
  }) {
    return incidencias.where((incidencia) {
      bool coincideTexto =
          textoBusqueda == null ||
          textoBusqueda.isEmpty ||
          incidencia.descripcion.toLowerCase().contains(
            textoBusqueda.toLowerCase(),
          ) ||
          (incidencia.productoNombre.toLowerCase().contains(
            textoBusqueda.toLowerCase(),
          )) ||
          ((incidencia.producto != null &&
              incidencia.producto!.nombre.toLowerCase().contains(
                textoBusqueda.toLowerCase(),
              )));

      bool coincideEstado =
          estado == null || estado.isEmpty || incidencia.estado == estado;

      bool coincidePedido = pedidoId == null || incidencia.pedidoId == pedidoId;

      bool coincideProducto =
          productoId == null ||
          incidencia.productoId == productoId ||
          (incidencia.producto != null &&
              incidencia.producto!.id == productoId);

      bool coincideUsuario =
          usuarioId == null || incidencia.reportadoPorId == usuarioId;

      bool coincideFecha = true;
      if (fechaDesde != null || fechaHasta != null) {
        final fechaIncidencia = DateTime.parse(incidencia.fechaReporte);
        if (fechaDesde != null && fechaIncidencia.isBefore(fechaDesde)) {
          coincideFecha = false;
        }
        if (fechaHasta != null && fechaIncidencia.isAfter(fechaHasta)) {
          coincideFecha = false;
        }
      }

      return coincideTexto &&
          coincideEstado &&
          coincidePedido &&
          coincideProducto &&
          coincideUsuario &&
          coincideFecha;
    }).toList();
  }
}
