class User {
  final int id;
  final String email;
  final String nombre;
  final String tipoUsuario;
  final String? imagenPerfil;
  final String? telefono;
  final String? direccion;
  final String? empresaAsociada;
  final String? fechaCreacion;
  final Map<String, dynamic>? permisos;

  User({
    required this.id,
    required this.email,
    required this.nombre,
    required this.tipoUsuario,
    this.imagenPerfil,
    this.telefono,
    this.direccion,
    this.empresaAsociada,
    this.fechaCreacion,
    this.permisos,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? json['usuario_id'] ?? 0,
      email: json['email'] ?? '',
      nombre: json['nombre'] ?? '',
      tipoUsuario: json['tipo_usuario'] ?? '',
      imagenPerfil: json['imagen_perfil'],
      telefono: json['telefono'],
      direccion: json['direccion'],
      empresaAsociada: json['empresa_asociada'],
      fechaCreacion: json['fecha_creacion'],
      permisos:
          json['permisos'] != null
              ? Map<String, dynamic>.from(json['permisos'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'nombre': nombre,
      'tipo_usuario': tipoUsuario,
      'imagen_perfil': imagenPerfil,
      'telefono': telefono,
      'direccion': direccion,
      'empresa_asociada': empresaAsociada,
      'fecha_creacion': fechaCreacion,
      'permisos': permisos,
    };
  }

  bool esEmpleado() {
    return tipoUsuario == 'empleado';
  }

  bool tienePermiso(String permiso) {
    if (!esEmpleado() || permisos == null) {
      return true; // Los no empleados tienen todos los permisos por defecto
    }
    return permisos![permiso] == true;
  }
}
