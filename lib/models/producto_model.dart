import 'package:flutter/foundation.dart';
import 'package:foodflow_app/models/categoria_model.dart';
import '../core/constants/api_endpoints.dart';

class Producto {
  final int id;
  final String nombre;
  final String? descripcion;
  final double precio;
  final double impuestos;
  final String unidadMedida;
  final String? imagen;
  final Categoria? categoria;
  final String? imagenQr;
  final bool isActive;
  final int cocinaCentralId;
  final String? imagenQrUrl;
  final String? imagenUrl;
  final double precioFinal;

  String? get categoriaNombre => categoria?.nombre;

  Producto({
    required this.id,
    required this.nombre,
    this.descripcion,
    required this.precio,
    required this.impuestos,
    required this.unidadMedida,
    this.imagen,
    this.categoria,
    this.imagenQr,
    required this.isActive,
    required this.cocinaCentralId,
    this.imagenQrUrl,
    this.imagenUrl,
    required this.precioFinal,
  });

  factory Producto.fromJson(Map<String, dynamic> json) {
    double parseDoubleValue(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) {
        return double.tryParse(value.replaceAll(',', '.')) ?? 0.0;
      }
      return 0.0;
    }

    Categoria? categoriaObj;
    if (json['categoria'] != null) {
      try {
        categoriaObj = Categoria.fromJson(
          json['categoria'] as Map<String, dynamic>,
        );
      } catch (e) {
        if (kDebugMode) {
          print('Error al procesar categoría: $e');
        }
        categoriaObj = null;
      }
    }

    return Producto(
      id: json['id'],
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'],
      precio: parseDoubleValue(json['precio']),
      impuestos: parseDoubleValue(json['impuestos']),
      unidadMedida: json['unidad_medida'] ?? 'unidad',
      imagen: json['imagen'],
      categoria: categoriaObj,
      imagenQr: json['imagen_qr'],
      isActive: json['is_active'] ?? true,
      cocinaCentralId: json['cocina_central'],
      imagenQrUrl: json['imagen_qr_url'],
      imagenUrl: json['imagen_url'],
      precioFinal: parseDoubleValue(json['precio_final']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'precio': precio,
      'impuestos': impuestos,
      'unidad_medida': unidadMedida,
      'imagen': imagen,
      'categoria': categoria?.toJson(),
      'imagen_qr': imagenQr,
      'is_active': isActive,
      'cocina_central': cocinaCentralId,
      'imagen_qr_url': imagenQrUrl,
      'imagen_url': imagenUrl,
      'precio_final': precioFinal,
    };
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

  Producto copyWith({
    int? id,
    String? nombre,
    String? descripcion,
    double? precio,
    double? impuestos,
    String? unidadMedida,
    String? imagen,
    Categoria? categoria,
    String? imagenQr,
    bool? isActive,
    int? cocinaCentralId,
    String? imagenQrUrl,
    String? imagenUrl,
    double? precioFinal,
  }) {
    return Producto(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      precio: precio ?? this.precio,
      impuestos: impuestos ?? this.impuestos,
      unidadMedida: unidadMedida ?? this.unidadMedida,
      imagen: imagen ?? this.imagen,
      categoria: categoria ?? this.categoria,
      imagenQr: imagenQr ?? this.imagenQr,
      isActive: isActive ?? this.isActive,
      cocinaCentralId: cocinaCentralId ?? this.cocinaCentralId,
      imagenQrUrl: imagenQrUrl ?? this.imagenQrUrl,
      imagenUrl: imagenUrl ?? this.imagenUrl,
      precioFinal: precioFinal ?? this.precioFinal,
    );
  }
}
