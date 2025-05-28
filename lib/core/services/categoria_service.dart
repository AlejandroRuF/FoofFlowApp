import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:foodflow_app/core/constants/api_endpoints.dart';
import 'package:foodflow_app/core/services/api_services.dart';
import 'package:foodflow_app/models/categoria_model.dart';

class CategoriaService {
  static final CategoriaService _instance = CategoriaService._internal();
  factory CategoriaService() => _instance;
  CategoriaService._internal();

  Future<List<Categoria>> obtenerCategorias() async {
    try {
      final response = await ApiServices.dio.get(ApiEndpoints.categorias);

      if (response.statusCode == 200) {
        final List<dynamic> categoriasData = response.data;
        final List<Categoria> categorias = [];

        for (var categoriaJson in categoriasData) {
          try {
            final categoria = Categoria.fromJson(categoriaJson);
            categorias.add(categoria);
          } catch (e) {
            if (kDebugMode) {
              print('Error al procesar categoría individual: $e');
            }
          }
        }

        if (kDebugMode) {
          print('Categorías procesadas con éxito: ${categorias.length}');
        }

        return categorias;
      }
      return [];
    } catch (e) {
      if (kDebugMode) {
        print('Error al obtener categorías: $e');
      }
      return [];
    }
  }

  Future<Categoria?> obtenerCategoriaDetalle(int categoriaId) async {
    try {
      final response = await ApiServices.dio.get(
        '${ApiEndpoints.categorias}$categoriaId/',
      );

      if (response.statusCode == 200) {
        return Categoria.fromJson(response.data);
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error al obtener detalle de la categoría: $e');
      }
      return null;
    }
  }

  Future<Categoria?> crearCategoria(Map<String, dynamic> datos) async {
    try {
      final response = await ApiServices.dio.post(
        ApiEndpoints.categorias,
        data: datos,
      );

      if (response.statusCode == 201) {
        return Categoria.fromJson(response.data);
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error al crear categoría: $e');
      }
      return null;
    }
  }

  Future<Categoria?> actualizarCategoria(
    int categoriaId,
    Map<String, dynamic> datos,
  ) async {
    try {
      final response = await ApiServices.dio.patch(
        '${ApiEndpoints.categorias}$categoriaId/',
        data: datos,
      );

      if (response.statusCode == 200) {
        return Categoria.fromJson(response.data);
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error al actualizar categoría: $e');
      }
      return null;
    }
  }

  Future<bool> eliminarCategoria(int categoriaId) async {
    try {
      final response = await ApiServices.dio.delete(
        '${ApiEndpoints.categorias}$categoriaId/',
      );

      return response.statusCode == 204;
    } catch (e) {
      if (kDebugMode) {
        print('Error al eliminar categoría: $e');
      }
      return false;
    }
  }

  Future<List<Categoria>> obtenerCategoriasPrincipales() async {
    try {
      final response = await ApiServices.dio.get(
        '${ApiEndpoints.categorias}?categoria_principal__isnull=true',
      );

      if (response.statusCode == 200) {
        final List<dynamic> categoriasData = response.data;
        final List<Categoria> categorias = [];

        for (var categoriaJson in categoriasData) {
          try {
            final categoria = Categoria.fromJson(categoriaJson);
            categorias.add(categoria);
          } catch (e) {
            if (kDebugMode) {
              print('Error al procesar categoría principal: $e');
            }
          }
        }

        return categorias;
      }
      return [];
    } catch (e) {
      if (kDebugMode) {
        print('Error al obtener categorías principales: $e');
      }
      return [];
    }
  }

  Future<List<Categoria>> obtenerSubcategorias(int categoriaId) async {
    try {
      final response = await ApiServices.dio.get(
        '${ApiEndpoints.categorias}?categoria_principal=$categoriaId',
      );

      if (response.statusCode == 200) {
        final List<dynamic> categoriasData = response.data;
        final List<Categoria> subcategorias = [];

        for (var categoriaJson in categoriasData) {
          try {
            final subcategoria = Categoria.fromJson(categoriaJson);
            subcategorias.add(subcategoria);
          } catch (e) {
            if (kDebugMode) {
              print('Error al procesar subcategoría: $e');
            }
          }
        }

        return subcategorias;
      }
      return [];
    } catch (e) {
      if (kDebugMode) {
        print('Error al obtener subcategorías: $e');
      }
      return [];
    }
  }

  Future<List<Categoria>> buscarCategoriasPorNombre(String nombre) async {
    try {
      final response = await ApiServices.dio.get(
        '${ApiEndpoints.categorias}?search=$nombre',
      );

      if (response.statusCode == 200) {
        final List<dynamic> categoriasData = response.data;
        final List<Categoria> categorias = [];

        for (var categoriaJson in categoriasData) {
          try {
            final categoria = Categoria.fromJson(categoriaJson);
            categorias.add(categoria);
          } catch (e) {
            if (kDebugMode) {
              print('Error al procesar categoría en búsqueda: $e');
            }
          }
        }

        return categorias;
      }
      return [];
    } catch (e) {
      if (kDebugMode) {
        print('Error al buscar categorías por nombre: $e');
      }
      return [];
    }
  }

  Future<Categoria?> crearSubcategoria(
    int categoriaPrincipalId,
    Map<String, dynamic> datos,
  ) async {
    try {
      datos['categoria_principal'] = categoriaPrincipalId;

      final response = await ApiServices.dio.post(
        ApiEndpoints.categorias,
        data: datos,
      );

      if (response.statusCode == 201) {
        return Categoria.fromJson(response.data);
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error al crear subcategoría: $e');
      }
      return null;
    }
  }

  Future<Categoria?> moverCategoria(
    int categoriaId,
    int? nuevaCategoriaPrincipalId,
  ) async {
    try {
      final response = await ApiServices.dio.patch(
        '${ApiEndpoints.categorias}$categoriaId/',
        data: {'categoria_principal': nuevaCategoriaPrincipalId},
      );

      if (response.statusCode == 200) {
        return Categoria.fromJson(response.data);
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error al mover categoría: $e');
      }
      return null;
    }
  }

  Future<List<Categoria>> obtenerJerarquiaCategorias() async {
    try {
      final categoriasRaiz = await obtenerCategoriasPrincipales();
      return categoriasRaiz;
    } catch (e) {
      if (kDebugMode) {
        print('Error al obtener jerarquía de categorías: $e');
      }
      return [];
    }
  }
}
