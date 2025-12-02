class Usuario {
  final int idUsuario;
  final String nombre;
  final String? appPaterno;
  final String? appMaterno;
  final int ci;
  final int telefono;
  final String email;
  final String estado;
  final String rol;

  Usuario({
    required this.idUsuario,
    required this.nombre,
    this.appPaterno,
    this.appMaterno,
    required this.ci,
    required this.telefono,
    required this.email,
    required this.estado,
    required this.rol,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      idUsuario: json['id_usuario'],
      nombre: json['nombre'],
      appPaterno: json['app_paterno'],
      appMaterno: json['app_materno'],
      ci: json['ci'],
      telefono: json['telefono'],
      email: json['email'],
      estado: json['estado'],
      rol: json['rol'],
    );
  }

  String get nombreCompleto {
    return '$nombre ${appPaterno ?? ''} ${appMaterno ?? ''}'.trim();
  }
}