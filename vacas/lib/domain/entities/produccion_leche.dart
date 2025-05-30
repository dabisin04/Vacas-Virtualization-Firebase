class ProduccionLeche {
  final String id;
  final String farmId;
  final String animalId;
  final DateTime fecha;
  final double cantidadLitros;
  final String registradoPor;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProduccionLeche({
    required this.id,
    required this.farmId,
    required this.animalId,
    required this.fecha,
    required this.cantidadLitros,
    required this.registradoPor,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProduccionLeche.fromJson(Map<String, dynamic> json) =>
      ProduccionLeche(
        id: json['id'],
        farmId: json['farm_id'],
        animalId: json['animal_id'],
        fecha: DateTime.parse(json['fecha']),
        cantidadLitros: json['cantidad_litros'].toDouble(),
        registradoPor: json['registrado_por'],
        createdAt: DateTime.parse(json['created_at']),
        updatedAt: DateTime.parse(json['updated_at']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'farm_id': farmId,
        'animal_id': animalId,
        'fecha': fecha.toIso8601String(),
        'cantidad_litros': cantidadLitros,
        'registrado_por': registradoPor,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}
