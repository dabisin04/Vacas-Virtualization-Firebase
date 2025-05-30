class Peso {
  final String id;
  final String farmId;
  final String animalId;
  final double pesoKg;
  final DateTime fecha;
  final String registradoPor;
  final DateTime createdAt;
  final DateTime updatedAt;

  Peso({
    required this.id,
    required this.farmId,
    required this.animalId,
    required this.pesoKg,
    required this.fecha,
    required this.registradoPor,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Peso.fromJson(Map<String, dynamic> json) => Peso(
        id: json['id'],
        farmId: json['farm_id'],
        animalId: json['animal_id'],
        pesoKg: json['peso_kg'].toDouble(),
        fecha: DateTime.parse(json['fecha']),
        registradoPor: json['registrado_por'],
        createdAt: DateTime.parse(json['created_at']),
        updatedAt: DateTime.parse(json['updated_at']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'farm_id': farmId,
        'animal_id': animalId,
        'peso_kg': pesoKg,
        'fecha': fecha.toIso8601String(),
        'registrado_por': registradoPor,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}
