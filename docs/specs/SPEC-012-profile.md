# SPEC-012 — Perfil y Cerrar Sesión

**ID**: SPEC-012
**Nombre**: Perfil de usuario y cierre de sesión
**Estado**: READY_FOR_DEVELOPMENT
**Prioridad**: Must Have
**Release**: MVP
**Personas afectadas**: Todos los roles

---

## Objetivo

Permitir al usuario ver sus datos de perfil, gestionar su sesión activa, y cerrar sesión de forma segura.

## Actores

- Todos los roles autenticados

## Precondiciones

- Usuario autenticado

---

## Pantalla: ProfileScreen

### Layout

```
┌─────────────────────────────────────┐
│  Mi Perfil                          │
│                                     │
│         [Avatar]                    │
│         Juan García                 │
│         Recepcionista               │
│                                     │
│  INFORMACIÓN                        │
│  Email        juan@lequint.com      │
│  Documento    12345678              │
│  Teléfono     +506 8888-8888        │
│  Cargo        Recepcionista         │
│  Departamento Recepción             │
│                                     │
│  SESIÓN                             │
│  Dispositivo  iPhone 14             │
│  Sesión desde Hoy, 8:00 AM          │
│                                     │
│  ┌─────────────────────────────┐    │
│  │       CERRAR SESIÓN         │    │
│  └─────────────────────────────┘    │
└─────────────────────────────────────┘
```

### Secciones

**1. Header de perfil**
- Avatar (foto si existe, iniciales si no)
- Nombre completo
- Rol traducido al español

**2. Información personal**
- Email (solo lectura)
- Documento
- Teléfono (si existe)
- Cargo (si existe)
- Departamento (si existe)

**3. Sesión**
- Información de la sesión actual (informativo)

**4. Botón cerrar sesión**
- Prominente, color de advertencia (rojo suave o naranja)

---

## Flujo — Cerrar Sesión

1. Usuario tap "Cerrar Sesión"
2. App muestra dialog de confirmación:
   ```
   ¿Cerrar sesión?
   
   Se cerrará tu sesión en este dispositivo.
   
   [Cancelar]  [Cerrar Sesión]
   ```
3. Usuario confirma
4. App detiene heartbeat
5. App elimina sesión de `users/{uid}.sessions.{sessionId}`
6. App decrementa `activeSessionsCount`
7. App llama a `FirebaseAuth.signOut()`
8. App navega a LoginScreen (limpiando el stack de navegación)

## Reglas de negocio

1. El cierre de sesión siempre requiere confirmación
2. Al cerrar sesión, la sesión se elimina de Firestore (no solo de Firebase Auth)
3. El heartbeat se detiene antes de cerrar sesión
4. La navegación al LoginScreen limpia el stack completo (no se puede volver con el botón atrás)

## Excepciones

| Condición | Comportamiento |
|---|---|
| Error al limpiar sesión en Firestore | Continuar con el logout de Firebase Auth de todas formas. Loguear el error. |
| Sin conexión | Cerrar sesión localmente (Firebase Auth) y marcar para limpiar en Firestore cuando haya conexión |

## UI/UX

- Avatar: imagen circular. Si no hay foto, mostrar iniciales con color de fondo basado en el nombre
- Información en formato de lista con label + valor
- Campos vacíos (teléfono, cargo, etc.) no se muestran si no tienen valor
- Botón cerrar sesión: color rojo suave, ícono de logout
- Dialog de confirmación: botón "Cerrar Sesión" en rojo

## Estados de pantalla

| Estado | Comportamiento |
|---|---|
| Loading | Skeleton del perfil |
| Success | Datos del usuario |
| Error | "No se pudieron cargar tus datos" + reintentar |

## Permisos

- Todos los roles autenticados
- Solo lectura — no se puede editar el perfil desde la app móvil en el MVP

## Criterios de aceptación

- [ ] ProfileScreen muestra nombre, rol y datos del usuario actual
- [ ] Avatar muestra foto si existe, iniciales si no
- [ ] Campos vacíos no se muestran
- [ ] Botón "Cerrar Sesión" muestra dialog de confirmación
- [ ] Cerrar sesión limpia la sesión en Firestore
- [ ] Cerrar sesión navega a LoginScreen limpiando el stack
- [ ] No se puede volver a la app con el botón atrás después de cerrar sesión

## Consideraciones técnicas

- Los datos del usuario ya están disponibles en el `currentUserProvider` (cargado al hacer login). No se necesita query adicional.
- El `sessionId` debe estar disponible en el provider de auth para poder eliminarlo de Firestore al hacer logout
- Usar `GoRouter.go('/login')` (no `push`) para limpiar el stack de navegación

---

## UX / DESIGN REQUIREMENTS

**Design System**: `docs/ux/design-system.md`
**Tokens**: `docs/ux/design-tokens.md`
**Componentes**: `docs/ux/components.md` — `UserAvatar`, `GlassCard`, `DestructiveButton`, `ConfirmDialog`
**Referencias**: `docs/design-references/general.jpg`

### Elementos REQUIRED
- `UserAvatar` grande (`avatarSizeLarge` = 64px) centrado en el header
- Nombre + rol traducido debajo del avatar
- Información en `GlassCard` con filas label + valor
- Campos vacíos no se muestran
- Botón "Cerrar Sesión": `DestructiveButton` (rojo suave)
- `ConfirmDialog` antes de cerrar sesión

### Elementos FLEXIBLE
- Información de sesión (puede omitirse si no agrega valor)
- Decoración del header de perfil
