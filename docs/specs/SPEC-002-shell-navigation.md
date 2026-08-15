# SPEC-002 — Shell y Navegación

**ID**: SPEC-002
**Nombre**: Shell de la aplicación y navegación por rol
**Estado**: READY_FOR_DEVELOPMENT
**Prioridad**: Must Have
**Release**: MVP
**Personas afectadas**: Todos los roles

---

## Objetivo

Proveer la estructura de navegación principal de la app: shell con bottom navigation bar adaptada al rol del usuario, routing protegido por autenticación y rol, y acceso al menú secundario.

## Contexto

Cada rol tiene necesidades distintas. La navegación debe reflejar eso sin exponer secciones irrelevantes. Decisión DECISION-008 y DECISION-009.

## Actores

- Todos los roles autenticados

## Precondiciones

- Usuario autenticado (SPEC-001 completada)
- Rol del usuario disponible en el provider de autenticación

## Bottom Navigation por rol

### Superadmin / Admin
```
[Dashboard] [Habitaciones] [Recepción] [Housekeeping] [Más]
  home         bed_double     desk        cleaning_services   menu
```

### Manager
```
[Dashboard] [Habitaciones] [Reportes] [Housekeeping] [Más]
  home         bed_double    bar_chart   cleaning_services   menu
```

### Receptionist
```
[Inicio] [Llegadas] [Salidas] [Habitaciones] [Más]
  home    login      logout    bed_double     menu
```

### Housekeeper
```
[Mis Tareas] [Habitaciones] [Notificaciones] [Perfil]
  task         bed_double      notifications    person
```

## Menú secundario ([Más])

Abre un bottom sheet con las secciones no incluidas en el bottom nav del rol.

### Superadmin / Admin — Más
- Huéspedes en casa
- Notificaciones
- Perfil

### Manager — Más
- Huéspedes en casa
- Notificaciones
- Perfil

### Receptionist — Más
- Huéspedes en casa
- Buscar huésped
- Notificaciones
- Perfil

## Protección de rutas

- Rutas privadas redirigen a `/login` si no hay sesión activa
- Cada pantalla verifica que el rol del usuario tenga acceso
- Si un rol intenta acceder a una ruta no permitida → redirigir a su home

## Comportamiento del badge de notificaciones

- El ícono de notificaciones muestra un badge con el conteo de no leídas
- Se actualiza en tiempo real (stream de Firestore)
- Máximo mostrado: "99+"

## Estados de pantalla del shell

- **Loading inicial**: mientras se verifica la sesión y se carga el rol → splash screen con logo "Le Quint"
- **Autenticado**: shell con bottom nav
- **No autenticado**: LoginScreen

## UI/UX

- Bottom nav con fondo del color primario de la app
- Ítem activo: color de acento + label visible
- Ítem inactivo: color gris + label visible
- Transiciones entre tabs: sin animación (instantáneo, estándar en apps nativas)
- Bottom sheet del menú "Más": lista de opciones con ícono y label

## Criterios de aceptación

- [ ] Superadmin ve su bottom nav correcto
- [ ] Manager ve su bottom nav correcto
- [ ] Receptionist ve su bottom nav correcto
- [ ] Housekeeper ve su bottom nav correcto (4 ítems, sin "Más")
- [ ] Tap en "Más" abre bottom sheet con opciones del rol
- [ ] Badge de notificaciones se actualiza en tiempo real
- [ ] Ruta no autenticada redirige a login
- [ ] Splash screen visible durante verificación inicial de sesión
- [ ] Navegar entre tabs no recarga datos innecesariamente

## Consideraciones técnicas

- Usar `ShellRoute` de GoRouter para el shell con bottom nav
- El rol se obtiene del `currentUserProvider` (Riverpod)
- El bottom nav se construye condicionalmente según el rol
- Usar `IndexedStack` para mantener el estado de cada tab al cambiar

---

## UX / DESIGN REQUIREMENTS

**Design System**: `docs/ux/design-system.md`
**Tokens**: `docs/ux/design-tokens.md`
**Componentes**: `docs/ux/components.md` — `BottomNavigation`, `OfflineBanner`
**Referencias**: `docs/design-references/general.jpg`, `docs/design-references/dashboard.jpg`

### Elementos REQUIRED
- Bottom navigation: componente `BottomNavigation` (glass, blur 20px)
- Splash screen: logo "Le Quint" centrado sobre fondo gradiente oscuro
- Badge de notificaciones: círculo rojo, máximo "99+"
- Ítem activo: `accentPrimary` + label visible
- Ítem inactivo: `textTertiary` + label visible
- Transición entre tabs: instantánea (sin animación)
- `IndexedStack` para preservar estado de cada tab

### Elementos FLEXIBLE
- Animación del splash screen
- Estilo exacto del bottom sheet del menú "Más"
- Microinteracción al cambiar tab activo
