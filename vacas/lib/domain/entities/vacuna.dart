class Vacuna {
  final String id;
  final String farmId;
  final String animalId;
  final String nombre;
  final String motivo;
  final DateTime fecha;
  final String registradoPor;
  final DateTime createdAt;
  final DateTime updatedAt;

  Vacuna({
    required this.id,
    required this.farmId,
    required this.animalId,
    required this.nombre,
    required this.motivo,
    required this.fecha,
    required this.registradoPor,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Vacuna.fromJson(Map<String, dynamic> json) => Vacuna(
        id: json['id'],
        farmId: json['farm_id'],
        animalId: json['animal_id'],
        nombre: json['nombre'],
        motivo: json['motivo'],
        fecha: DateTime.parse(json['fecha']),
        registradoPor: json['registrado_por'],
        createdAt: DateTime.parse(json['created_at']),
        updatedAt: DateTime.parse(json['updated_at']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'farm_id': farmId,
        'animal_id': animalId,
        'nombre': nombre,
        'motivo': motivo,
        'fecha': fecha.toIso8601String(),
        'registrado_por': registradoPor,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}
