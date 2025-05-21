class User {
  final int id;
  final String email;
  final String nombre;
  final String tipoUsuario;
  final String? direccion;
  final String? telefono;
  final String? fechaCreacion;
  final bool isActive;
  final bool isStaff;
  final bool isSuperuser;
  final String? empresaAsociada;
  final String? imagen;
  final int? propietarioId;
  final int? empleadorId;

  User({
    required this.id,
    required this.email,
    required this.nombre,
    required this.tipoUsuario,
    this.direccion,
    this.telefono,
    this.fechaCreacion,
    this.isActive = true,
    this.isStaff = false,
    this.isSuperuser = false,
    this.empresaAsociada,
    this.imagen,
    this.propietarioId,
    this.empleadorId,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['usuario_id'] ?? json['id'],
      email: json['email'],
      nombre: json['nombre'],
      tipoUsuario: json['tipo_usuario'],
      direccion: json['direccion'],
      telefono: json['telefono'],
      fechaCreacion: json['fecha_creacion'],
      isActive: json['is_active'] ?? true,
      isStaff: json['is_staff'] ?? false,
      isSuperuser: json['is_superuser'] ?? false,
      empresaAsociada: json['empresa_asociada'],
      imagen: json['imagen'],
      propietarioId: json['propietario'],
      empleadorId: json['empleador_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'nombre': nombre,
      'tipo_usuario': tipoUsuario,
      'direccion': direccion,
      'telefono': telefono,
      'fecha_creacion': fechaCreacion,
      'is_active': isActive,
      'is_staff': isStaff,
      'is_superuser': isSuperuser,
      'empresa_asociada': empresaAsociada,
      'imagen': imagen,
      'propietario': propietarioId,
      'empleador_id': empleadorId,
    };
  }

  bool get esEmpleado => tipoUsuario == 'empleado';
}
