import 'package:foodflow_app/core/constants/api_endpoints.dart';

class Producto {
  final int id;
  final String nombre;
  final String? descripcion;
  final int? categoriaId;
  final String? categoriaNombre;
  final double precio;
  final double impuestos;
  final String? imagenQrUrl;
  final String unidadMedida;
  final String? imagenUrl;
  final int cocinaCentralId;
  final bool isActive;
  final double precioFinal;
  final String? imagen;

  Producto({
    required this.id,
    required this.nombre,
    this.descripcion,
    this.categoriaId,
    this.categoriaNombre,
    required this.precio,
    required this.impuestos,
    this.imagenQrUrl,
    required this.unidadMedida,
    this.imagenUrl,
    required this.cocinaCentralId,
    required this.isActive,
    required this.precioFinal,
    this.imagen,
  });

  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      id: json['id'],
      nombre: json['nombre'],
      descripcion: json['descripcion'],
      categoriaId: json['categoria'],
      categoriaNombre: json['categoria_nombre'],
      precio: double.parse(json['precio'].toString()),
      impuestos: double.parse(json['impuestos'].toString()),
      imagenQrUrl: json['imagen_qr_url'],
      unidadMedida: json['unidad_medida'] ?? 'unidad',
      imagenUrl: json['imagen_url'],
      cocinaCentralId: json['cocina_central'],
      isActive: json['is_active'] ?? true,
      precioFinal: double.parse(json['precio_final']?.toString() ?? '0.0'),
      imagen: json['imagen'],
    );
  }

  String? getImagenUrlCompleta() {
    if (imagen != null && imagen!.isNotEmpty) {
      return imagen;
    } else if (imagenUrl != null && imagenUrl!.isNotEmpty) {
      return ApiConfig.hostUrl + imagenUrl!;
    }
    return null;
  }

  String? getImagenQrUrlCompleta() {
    if (imagenQrUrl != null && imagenQrUrl!.isNotEmpty) {
      if (imagenQrUrl!.startsWith('http')) {
        return imagenQrUrl;
      } else {
        return ApiConfig.hostUrl + imagenQrUrl!;
      }
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'categoria': categoriaId,
      'categoria_nombre': categoriaNombre,
      'precio': precio,
      'impuestos': impuestos,
      'imagen_qr_url': imagenQrUrl,
      'unidad_medida': unidadMedida,
      'imagen_url': imagenUrl,
      'cocina_central': cocinaCentralId,
      'is_active': isActive,
      'precio_final': precioFinal,
      'imagen': imagen,
    };
  }
}
