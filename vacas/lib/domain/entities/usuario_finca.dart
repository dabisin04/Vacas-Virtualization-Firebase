class UsuarioFinca {
  final String id;
  final String userId;
  final String farmId;

  UsuarioFinca({
    required this.id,
    required this.userId,
    required this.farmId,
  });

  factory UsuarioFinca.fromJson(Map<String, dynamic> json) => UsuarioFinca(
        id: json['id'],
        userId: json['user_id'],
        farmId: json['farm_id'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'farm_id': farmId,
      };
}
