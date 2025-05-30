enum RolUsuario {
  administrador,
  veterinario,
  asistente,
}

RolUsuario rolUsuarioFromString(String rol) {
  return RolUsuario.values.firstWhere(
    (e) => e.name == rol,
    orElse: () => RolUsuario.asistente, // Valor por defecto
  );
}

String rolUsuarioToString(RolUsuario rol) => rol.name;
