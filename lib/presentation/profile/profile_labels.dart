import '../../domain/models/user.dart';

/// Traducción de [UserRole] al español — ver SPEC-012.
String translateRole(UserRole role) => switch (role) {
  UserRole.superadmin => 'Super Administrador',
  UserRole.admin => 'Administrador',
  UserRole.manager => 'Gerente',
  UserRole.receptionist => 'Recepcionista',
  UserRole.housekeeper => 'Camarera',
  UserRole.guest => 'Huésped',
};
