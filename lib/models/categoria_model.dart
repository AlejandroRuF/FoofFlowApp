class Categoria {
  final int id;
  final String nombre;
  final String? descripcion;
  final int? categoriaPrincipal;
  final List<Categoria> subcategorias;

  Categoria({
    required this.id,
    required this.nombre,
    this.descripcion,
    this.categoriaPrincipal,
    required this.subcategorias,
  });

  factory Categoria.fromJson(Map<String, dynamic> json) {
    return Categoria(
      id: json['id'],
      nombre: json['nombre'],
      descripcion: json['descripcion'],
      categoriaPrincipal: json['categoria_principal'],
      subcategorias:
          (json['subcategorias'] as List<dynamic>)
              .map((e) => Categoria.fromJson(e))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'categoria_principal': categoriaPrincipal,
      'subcategorias': subcategorias.map((e) => e.toJson()).toList(),
    };
  }
}
