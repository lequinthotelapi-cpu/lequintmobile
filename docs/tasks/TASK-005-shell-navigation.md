# TASK-005 — Shell y navegación

**ID**: TASK-005
**SPEC**: SPEC-002
**Dependencias**: TASK-004
**Estado**: PENDING

---

## Objetivo

Implementar el shell de la aplicación con bottom navigation bar diferenciada por rol, routing con GoRouter, y menú secundario.

## Alcance

### 1. GoRouter configuration (lib/core/constants/app_routes.dart + router setup)

- Definir todas las rutas del MVP
- `redirect` para protección de rutas
- `ShellRoute` para el shell con bottom nav
- Deep linking desde notificaciones push

### 2. AppShell (lib/presentation/shell/)

```dart
// shell_screen.dart
// - Recibe el rol del usuario del authProvider
// - Construye el BottomNavigationBar según el rol
// - IndexedStack para mantener estado de cada tab
// - Badge de notificaciones en tiempo real

// Configuración de bottom nav por rol:
// superadmin/admin: Dashboard, Habitaciones, Recepción, Housekeeping, Más
// manager: Dashboard, Habitaciones, Reportes, Housekeeping, Más
// receptionist: Inicio, Llegadas, Salidas, Habitaciones, Más
// housekeeper: Mis Tareas, Habitaciones, Notificaciones, Perfil
```

### 3. Menú "Más" (bottom sheet)

```dart
// more_menu_bottom_sheet.dart
// Lista de opciones según rol
// Cada opción: ícono + label + onTap → GoRouter.go(route)
```

### 4. Splash Screen

- Logo "Le Quint" centrado
- Visible mientras se verifica la sesión inicial
- Transición suave a LoginScreen o HomeScreen

### 5. Badge de notificaciones

- `StreamProvider` para conteo de no leídas
- Badge sobre el ícono de notificaciones en el bottom nav
- Actualización en tiempo real

## Criterios de aceptación

- [ ] Cada rol ve su bottom nav correcto
- [ ] Tap en "Más" abre bottom sheet con opciones del rol
- [ ] Badge de notificaciones se actualiza en tiempo real
- [ ] Splash screen visible durante verificación inicial
- [ ] Navegar entre tabs mantiene el estado (IndexedStack)
- [ ] Deep link desde notificación push navega a la pantalla correcta
- [ ] Ruta no autenticada redirige a /login
- [ ] Widget test: cada rol renderiza el bottom nav correcto

## Notas

- Usar `IndexedStack` para mantener el estado de cada tab al cambiar
- El badge de notificaciones usa el mismo `notificationsProvider` que NotificationsScreen
- Para el deep linking, mapear los `actionUrl` del modelo de notificación (rutas web) a rutas GoRouter
