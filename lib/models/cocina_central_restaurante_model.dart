
class CocinaCentralRestaurante {
  final int id;
  final int cocinaCentralId;
  final int restauranteId;
  final String? cocinaCentralNombre;
  final String? restauranteNombre;

  CocinaCentralRestaurante({
    required this.id,
    required this.cocinaCentralId,
    required this.restauranteId,
    this.cocinaCentralNombre,
    this.restauranteNombre,
  });

  factory CocinaCentralRestaurante.fromJson(Map<String, dynamic> json) {
    return CocinaCentralRestaurante(
      id: json['id'],
      cocinaCentralId: json['cocina_central'],
      restauranteId: json['restaurante'],
      cocinaCentralNombre: json['cocina_central_nombre'],
      restauranteNombre: json['restaurante_nombre'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cocina_central': cocinaCentralId,
      'restaurante': restauranteId,
    };
  }

  @override
  String toString() {
    return 'CocinaCentralRestaurante{id: $id, cocinaCentral: $cocinaCentralId, restaurante: $restauranteId}';
  }
}

class CocinaCentralRestauranteRequest {
  final int cocinaCentralId;
  final int restauranteId;

  CocinaCentralRestauranteRequest({
    required this.cocinaCentralId,
    required this.restauranteId,
  });

  Map<String, dynamic> toJson() {
    return {
      'cocina_central': cocinaCentralId,
      'restaurante': restauranteId,
    };
  }
}