import 'package:vacas/domain/enums/rol_usuario.dart';

class Usuario {
  late final String id;
  final String nombre;
  final String email;
  final String password; // 🔒 Nueva propiedad agregada
  final RolUsuario rol;
  final DateTime createdAt;
  final DateTime updatedAt;

  Usuario({
    required this.id,
    required this.nombre,
    required this.email,
    required this.password,
    required this.rol,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) => Usuario(
        id: json['id'],
        nombre: json['nombre'],
        email: json['email'],
        password: json['password'] ?? '', // Evita fallo si el campo no viene
        rol: rolUsuarioFromString(json['rol']),
        createdAt: DateTime.parse(json['created_at']),
        updatedAt: DateTime.parse(json['updated_at']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
        'email': email,
        'password': password,
        'rol': rolUsuarioToString(rol),
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  Usuario copyWith({
    String? id,
    String? nombre,
    String? email,
    String? password,
    RolUsuario? rol,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Usuario(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      email: email ?? this.email,
      password: password ?? this.password,
      rol: rol ?? this.rol,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
