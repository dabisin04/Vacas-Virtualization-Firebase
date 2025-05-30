class Animal {
  final String id;
  final String farmId;
  final String nombre;
  final String tipo;
  final String raza;
  final String proposito;
  final String ganaderia;
  final String corral;
  final String numAnimal;
  final String codigoReferencia;
  final DateTime fechaNacimiento;
  final double pesoNacimiento;
  final String? padreId;
  final String? madreId;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? fotoUrl; // <- NUEVO CAMPO
  final String? localFotoUrl;

  Animal({
    required this.id,
    required this.farmId,
    required this.nombre,
    required this.tipo,
    required this.raza,
    required this.proposito,
    required this.ganaderia,
    required this.corral,
    required this.numAnimal,
    required this.codigoReferencia,
    required this.fechaNacimiento,
    required this.pesoNacimiento,
    this.padreId,
    this.madreId,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.fotoUrl, // <- NUEVO CAMPO
    this.localFotoUrl,
  });

  factory Animal.fromJson(Map<String, dynamic> json) => Animal(
        id: json['id'],
        farmId: json['farm_id'],
        nombre: json['nombre'],
        tipo: json['tipo'],
        raza: json['raza'],
        proposito: json['proposito'],
        ganaderia: json['ganaderia'],
        corral: json['corral'],
        numAnimal: json['num_animal'],
        codigoReferencia: json['codigo_referencia'],
        fechaNacimiento: DateTime.parse(json['fecha_nacimiento']),
        pesoNacimiento: (json['peso_nacimiento'] ?? 0).toDouble(),
        padreId: json['padre_id'],
        madreId: json['madre_id'],
        createdBy: json['created_by'],
        createdAt: DateTime.parse(json['created_at']),
        updatedAt: DateTime.parse(json['updated_at']),
        fotoUrl: json['foto_url'], // <- NUEVO CAMPO
        localFotoUrl: json['local_foto_url'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'farm_id': farmId,
        'nombre': nombre,
        'tipo': tipo,
        'raza': raza,
        'proposito': proposito,
        'ganaderia': ganaderia,
        'corral': corral,
        'num_animal': numAnimal,
        'codigo_referencia': codigoReferencia,
        'fecha_nacimiento': fechaNacimiento.toIso8601String(),
        'peso_nacimiento': pesoNacimiento,
        'padre_id': padreId,
        'madre_id': madreId,
        'created_by': createdBy,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'foto_url': fotoUrl, // <- NUEVO CAMPO
        'local_foto_url': localFotoUrl,
      };

  Animal copyWith({
    String? id,
    String? farmId,
    String? nombre,
    String? tipo,
    String? raza,
    String? proposito,
    String? ganaderia,
    String? corral,
    String? numAnimal,
    String? codigoReferencia,
    DateTime? fechaNacimiento,
    double? pesoNacimiento,
    String? padreId,
    String? madreId,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? fotoUrl,
    String? localFotoUrl,
  }) {
    return Animal(
      id: id ?? this.id,
      farmId: farmId ?? this.farmId,
      nombre: nombre ?? this.nombre,
      tipo: tipo ?? this.tipo,
      raza: raza ?? this.raza,
      proposito: proposito ?? this.proposito,
      ganaderia: ganaderia ?? this.ganaderia,
      corral: corral ?? this.corral,
      numAnimal: numAnimal ?? this.numAnimal,
      codigoReferencia: codigoReferencia ?? this.codigoReferencia,
      fechaNacimiento: fechaNacimiento ?? this.fechaNacimiento,
      pesoNacimiento: pesoNacimiento ?? this.pesoNacimiento,
      padreId: padreId ?? this.padreId,
      madreId: madreId ?? this.madreId,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      fotoUrl: fotoUrl ?? this.fotoUrl,
      localFotoUrl: localFotoUrl ?? this.localFotoUrl,
    );
  }
}
