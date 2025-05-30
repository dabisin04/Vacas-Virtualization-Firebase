class EventoReproductivo {
  final String id;
  final String farmId;
  final String animalId;
  final String tipo;
  final DateTime fecha;
  final String resultado;
  final String realizadoPor;
  final DateTime createdAt;
  final DateTime updatedAt;

  EventoReproductivo({
    required this.id,
    required this.farmId,
    required this.animalId,
    required this.tipo,
    required this.fecha,
    required this.resultado,
    required this.realizadoPor,
    required this.createdAt,
    required this.updatedAt,
  });

  factory EventoReproductivo.fromJson(Map<String, dynamic> json) =>
      EventoReproductivo(
        id: json['id'],
        farmId: json['farm_id'],
        animalId: json['animal_id'],
        tipo: json['tipo'],
        fecha: DateTime.parse(json['fecha']),
        resultado: json['resultado'],
        realizadoPor: json['realizado_por'],
        createdAt: DateTime.parse(json['created_at']),
        updatedAt: DateTime.parse(json['updated_at']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'farm_id': farmId,
        'animal_id': animalId,
        'tipo': tipo,
        'fecha': fecha.toIso8601String(),
        'resultado': resultado,
        'realizado_por': realizadoPor,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}
