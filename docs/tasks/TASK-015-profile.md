# TASK-015 — Perfil y cerrar sesión

**ID**: TASK-015
**SPEC**: SPEC-012
**Dependencias**: TASK-004, TASK-005
**Estado**: DONE

---

## Objetivo

Implementar la pantalla de perfil del usuario y el flujo de cierre de sesión.

## Alcance

### Pantalla: ProfileScreen (lib/presentation/profile/)

- Avatar circular (foto si existe, iniciales si no)
- Nombre completo + rol traducido
- Secciones de información (solo campos con valor)
- Botón "Cerrar Sesión" con confirmación

### UserAvatar widget (ya en TASK-006)

```dart
// Iniciales: primera letra del nombre + primera letra del apellido
// Color de fondo: hash del nombre → color de la paleta
```

### Flujo de logout

```dart
Future<void> _logout(BuildContext context, WidgetRef ref) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (_) => ConfirmDialog(
      title: '¿Cerrar sesión?',
      message: 'Se cerrará tu sesión en este dispositivo.',
      confirmLabel: 'Cerrar Sesión',
      confirmColor: Colors.red,
    ),
  );
  if (confirmed != true) return;
  
  await ref.read(authProvider.notifier).signOut();
  // GoRouter redirige automáticamente a /login por el redirect guard
}
```

### Traducción de roles

```dart
String translateRole(UserRole role) => switch (role) {
  UserRole.superadmin => 'Super Administrador',
  UserRole.admin => 'Administrador',
  UserRole.manager => 'Gerente',
  UserRole.receptionist => 'Recepcionista',
  UserRole.housekeeper => 'Camarera',
  UserRole.guest => 'Huésped',
};
```

## Criterios de aceptación

- [ ] ProfileScreen muestra nombre, rol traducido y datos del usuario
- [ ] Avatar muestra foto si existe, iniciales si no
- [ ] Campos vacíos no se muestran
- [ ] Botón "Cerrar Sesión" muestra dialog de confirmación
- [ ] Cerrar sesión limpia la sesión en Firestore
- [ ] Cerrar sesión navega a LoginScreen limpiando el stack
- [ ] No se puede volver con el botón atrás después de cerrar sesión
- [ ] Widget test: ProfileScreen muestra el rol traducido correctamente

## Notas

- Los datos del usuario ya están en el `currentUserProvider` — no se necesita query adicional
- Usar `GoRouter.go('/login')` para limpiar el stack de navegación
- El `sessionId` debe estar disponible en el `authProvider` para poder eliminarlo de Firestore
