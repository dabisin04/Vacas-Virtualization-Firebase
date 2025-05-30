class Farm {
  final String id;
  final String nombre;
  final String ubicacion;
  final String descripcion;
  final String propietarioId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? fotoUrl;
  final String? localFotoUrl;

  Farm({
    required this.id,
    required this.nombre,
    required this.ubicacion,
    required this.descripcion,
    required this.propietarioId,
    required this.createdAt,
    required this.updatedAt,
    this.fotoUrl,
    this.localFotoUrl,
  });

  factory Farm.fromJson(Map<String, dynamic> json) => Farm(
        id: json['id'],
        nombre: json['nombre'],
        ubicacion: json['ubicacion'],
        descripcion: json['descripcion'],
        propietarioId: json['propietario_id'],
        createdAt: DateTime.parse(json['created_at']),
        updatedAt: DateTime.parse(json['updated_at']),
        fotoUrl: json['foto_url'],
        localFotoUrl: json['local_foto_url'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
        'ubicacion': ubicacion,
        'descripcion': descripcion,
        'propietario_id': propietarioId,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'foto_url': fotoUrl,
        'local_foto_url': localFotoUrl,
      };

  Farm copyWith({
    String? id,
    String? nombre,
    String? ubicacion,
    String? descripcion,
    String? propietarioId,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? fotoUrl,
    String? localFotoUrl,
  }) {
    return Farm(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      ubicacion: ubicacion ?? this.ubicacion,
      descripcion: descripcion ?? this.descripcion,
      propietarioId: propietarioId ?? this.propietarioId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      fotoUrl: fotoUrl ?? this.fotoUrl,
      localFotoUrl: localFotoUrl ?? this.localFotoUrl,
    );
  }
}
