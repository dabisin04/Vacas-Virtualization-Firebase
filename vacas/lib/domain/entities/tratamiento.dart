class Tratamiento {
  final String id;
  final String farmId;
  final String animalId;
  final String medicamento;
  final String motivo;
  final DateTime fecha;
  final String registradoPor;
  final DateTime createdAt;
  final DateTime updatedAt;

  Tratamiento({
    required this.id,
    required this.farmId,
    required this.animalId,
    required this.medicamento,
    required this.motivo,
    required this.fecha,
    required this.registradoPor,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Tratamiento.fromJson(Map<String, dynamic> json) => Tratamiento(
        id: json['id'],
        farmId: json['farm_id'],
        animalId: json['animal_id'],
        medicamento: json['medicamento'],
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
        'medicamento': medicamento,
        'motivo': motivo,
        'fecha': fecha.toIso8601String(),
        'registrado_por': registradoPor,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}
