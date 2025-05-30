class ChequeoSalud {
  final String id;
  final String farmId;
  final String animalId;
  final DateTime fecha;
  final String diagnostico;
  final String tratamiento;
  final String observaciones;
  final String realizadoPor;
  final DateTime createdAt;
  final DateTime updatedAt;

  ChequeoSalud({
    required this.id,
    required this.farmId,
    required this.animalId,
    required this.fecha,
    required this.diagnostico,
    required this.tratamiento,
    required this.observaciones,
    required this.realizadoPor,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ChequeoSalud.fromJson(Map<String, dynamic> json) => ChequeoSalud(
        id: json['id'],
        farmId: json['farm_id'],
        animalId: json['animal_id'],
        fecha: DateTime.parse(json['fecha']),
        diagnostico: json['diagnostico'],
        tratamiento: json['tratamiento'],
        observaciones: json['observaciones'],
        realizadoPor: json['realizado_por'],
        createdAt: DateTime.parse(json['created_at']),
        updatedAt: DateTime.parse(json['updated_at']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'farm_id': farmId,
        'animal_id': animalId,
        'fecha': fecha.toIso8601String(),
        'diagnostico': diagnostico,
        'tratamiento': tratamiento,
        'observaciones': observaciones,
        'realizado_por': realizadoPor,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}
