# COMPONENTES — Le Quint Mobile App

> Especificaciones de los componentes visuales fundamentales.
> REQUIRED = implementar exactamente así. FLEXIBLE = Claude puede mejorar dentro del espíritu del diseño.

---

## GlassCard [REQUIRED]

Componente base para toda card con efecto glass.

```dart
// Uso
GlassCard(
  padding: EdgeInsets.all(AppTokens.cardPadding),
  child: content,
)

// Variantes
GlassCard.elevated()   // mayor blur y opacidad — para modales
GlassCard.subtle()     // menor opacidad — para cards secundarias
```

**Especificación**:
- `BackdropFilter` blur: 12px
- Fondo: `Color(0x1AFFFFFF)`
- Borde: 1px `Color(0x33FFFFFF)`
- Radius: 16px
- Sombra: `AppTokens.shadowCard`
- Padding interno: 16px (configurable)

---

## KPICard [REQUIRED]

Card para mostrar un indicador clave (número + label).

```dart
KPICard(
  value: '12',
  label: 'Llegadas hoy',
  icon: Icons.login,
  color: AppColors.accentPrimary,  // opcional
)
```

**Especificación**:
- Fondo: GlassCard
- Valor: `displayMedium` (28px, bold)
- Label: `labelMedium` (12px, textSecondary)
- Ícono: 20px, color del acento o textTertiary
- Tamaño: flexible (se adapta al grid)
- Mínimo: 2 por fila, máximo 4 por fila

---

## RoomCard [REQUIRED]

Tarjeta de habitación para la vista grid.

```dart
RoomCard(
  room: roomWithStatus,
  onTap: () => ...,
)
```

**Especificación**:
- Forma: cuadrada (aspect ratio 1:1)
- Fondo: color del estado con opacidad 15% (`roomAvailableBg`, etc.)
- Borde: 1px color del estado con opacidad 40%
- Número de habitación: `headlineMedium` (18px, bold), centrado
- Label de estado: `labelSmall` (11px), debajo del número
- Piso: `labelSmall`, esquina superior derecha, textTertiary
- Radius: 12px
- Sin efecto glass (el color de estado es suficiente)

---

## StatusChip [REQUIRED]

Chip para mostrar el estado de una habitación.

```dart
StatusChip(status: RoomStatus.available)
StatusChip(status: RoomStatus.occupied)
// etc.
```

**Especificación**:
- Fondo: color del estado con opacidad 15%
- Borde: 1px color del estado con opacidad 50%
- Texto: `labelSmall`, color del estado
- Radius: 999px (pill)
- Altura: 24px
- Padding horizontal: 8px
- Punto de color antes del texto (4px, color del estado)

---

## PriorityChip [REQUIRED]

Chip para mostrar la prioridad de una tarea.

```dart
PriorityChip(priority: TaskPriority.urgent)
```

**Especificación**: igual que StatusChip pero con colores de prioridad.

---

## TaskCard [REQUIRED]

Tarjeta de tarea en la lista del housekeeper.

```dart
TaskCard(
  task: housekeepingTask,
  onTap: () => ...,
)
```

**Especificación**:
- Fondo: GlassCard.subtle()
- Fila superior: PriorityChip + número de habitación (headlineSmall)
- Fila media: tipo de tarea (bodyMedium)
- Fila inferior: estado (punto animado si in-progress) + piso (textTertiary)
- Borde izquierdo: 3px color de prioridad (acento visual)
- Flecha derecha: ícono chevron, textTertiary

---

## BookingCard [REQUIRED]

Tarjeta de reserva en listas de llegadas/salidas.

```dart
BookingCard(
  booking: booking,
  balance: guestAccount?.balance,  // para salidas
  onTap: () => ...,
)
```

**Especificación**:
- Fondo: GlassCard.subtle()
- Nombre del huésped: `headlineSmall`
- Habitación + tipo: `bodyMedium`, textSecondary
- Badge de estado (confirmada/pendiente): StatusChip
- Para salidas: saldo en verde ($0) o naranja (>$0) — `labelLarge`

---

## PrimaryButton [REQUIRED]

Botón de acción principal.

```dart
PrimaryButton(
  label: 'Realizar Check-In',
  onPressed: () => ...,
  isLoading: false,
)
```

**Especificación**:
- Fondo: `accentPrimary` sólido
- Texto: `labelLarge`, blanco
- Radius: 12px
- Altura: 52px
- Ancho: 100% del contenedor
- Estado loading: spinner blanco, texto oculto, fondo con opacidad 70%
- Estado disabled: opacidad 38%
- Sin efecto glass

---

## SecondaryButton [FLEXIBLE]

Botón de acción secundaria.

```dart
SecondaryButton(
  label: 'Cancelar',
  onPressed: () => ...,
)
```

**Especificación base**:
- Fondo: transparente
- Borde: 1px `glassPrimaryBorder`
- Texto: `labelLarge`, textSecondary
- Radius: 12px
- Altura: 52px

---

## DestructiveButton [REQUIRED]

Botón para acciones destructivas (cerrar sesión, cancelar).

```dart
DestructiveButton(
  label: 'Cerrar Sesión',
  onPressed: () => ...,
)
```

**Especificación**:
- Fondo: `errorBg`
- Borde: 1px `error` con opacidad 50%
- Texto: `labelLarge`, `error`
- Radius: 12px
- Altura: 52px

---

## TextInput [REQUIRED]

Campo de texto estándar.

```dart
AppTextInput(
  label: 'Email',
  controller: controller,
  keyboardType: TextInputType.emailAddress,
  validator: (v) => ...,
)
```

**Especificación**:
- Fondo: `Color(0x1AFFFFFF)`
- Borde reposo: 1px `Color(0x33FFFFFF)`
- Borde focus: 1px `accentPrimary`
- Borde error: 1px `error`
- Label flotante: `labelMedium`
- Texto: `bodyLarge`, textPrimary
- Radius: 12px
- Altura: 52px

---

## SearchBar [FLEXIBLE]

Barra de búsqueda.

```dart
AppSearchBar(
  hint: 'Buscar por nombre o habitación',
  onChanged: (query) => ...,
)
```

**Especificación base**:
- Fondo: `Color(0x1AFFFFFF)`
- Ícono lupa: izquierda, textTertiary
- Texto: `bodyMedium`
- Radius: 999px (pill)
- Altura: 44px

---

## ConfirmDialog [REQUIRED]

Dialog de confirmación reutilizable.

```dart
ConfirmDialog.show(
  context: context,
  title: '¿Confirmar check-in?',
  message: 'Juan García — Hab. 205',
  confirmLabel: 'Confirmar Check-In',
  confirmColor: AppColors.success,
  onConfirm: () => ...,
)
```

**Especificación**:
- Fondo: GlassCard.elevated() sobre overlay oscuro (50% negro)
- Título: `headlineMedium`
- Mensaje: `bodyMedium`, textSecondary
- Botón cancelar: SecondaryButton
- Botón confirmar: PrimaryButton (color configurable)
- Radius: 20px
- Padding: 24px

---

## BottomSheet [REQUIRED]

Bottom sheet estándar (menú "Más", confirmaciones).

**Especificación**:
- Fondo: GlassCard.elevated()
- Handle: barra 4px × 32px, `glassPrimaryBorder`, centrada arriba
- Radius superior: 20px
- Padding: 24px
- Drag para cerrar: habilitado

---

## LoadingState / Skeleton [REQUIRED]

```dart
// Skeleton genérico
SkeletonCard(height: 80)
SkeletonList(count: 4, itemHeight: 80)

// Overlay de loading (para operaciones como check-in)
LoadingOverlay(isLoading: true, child: content)
```

**Especificación skeleton**:
- Color base: `Color(0x1AFFFFFF)`
- Color shimmer: `Color(0x33FFFFFF)`
- Animación: shimmer horizontal, 1.5s loop
- Radius: igual al componente que reemplaza

---

## EmptyState [REQUIRED]

```dart
EmptyState(
  icon: Icons.task_alt,
  title: 'No tienes tareas asignadas',
  subtitle: 'Las tareas aparecerán aquí cuando te sean asignadas',
)
```

**Especificación**:
- Ícono: 48px, textTertiary
- Título: `headlineSmall`, textSecondary
- Subtítulo: `bodyMedium`, textTertiary
- Centrado vertical y horizontal
- Sin fondo especial

---

## ErrorState [REQUIRED]

```dart
ErrorState(
  message: 'No se pudieron cargar las llegadas',
  onRetry: () => ref.refresh(arrivalsProvider),
)
```

**Especificación**:
- Ícono: error_outline, 48px, `error`
- Mensaje: `bodyMedium`, textSecondary
- Botón "Reintentar": SecondaryButton
- Centrado

---

## OfflineBanner [REQUIRED]

```dart
// Se muestra automáticamente cuando connectivityProvider indica offline
OfflineBanner()
```

**Especificación**:
- Posición: parte superior de la pantalla, debajo del AppBar
- Fondo: `warningBg`
- Borde inferior: 1px `warning` con opacidad 50%
- Texto: "Sin conexión — mostrando datos en caché", `labelMedium`, `warning`
- Ícono: wifi_off, 16px
- Altura: 36px
- Animación: slide desde arriba al aparecer/desaparecer

---

## UserAvatar [REQUIRED]

```dart
UserAvatar(
  user: currentUser,
  size: AppTokens.avatarSize,
)
```

**Especificación**:
- Si tiene foto: `CachedNetworkImage` circular
- Si no tiene foto: iniciales (primera letra nombre + primera letra apellido)
- Color de fondo: derivado del nombre (hash → color de la paleta de acentos)
- Texto de iniciales: `labelLarge`, blanco
- Forma: círculo

---

## NotificationItem [REQUIRED]

```dart
NotificationItem(
  notification: appNotification,
  onTap: () => ...,
)
```

**Especificación**:
- No leída: fondo `Color(0x1A3B82F6)` (azul sutil)
- Leída: fondo `glassSecondary`
- Ícono por tipo: 20px, color según tipo
- Título: `labelLarge`
- Mensaje: `bodySmall`, textSecondary
- Tiempo relativo: `labelSmall`, textTertiary
- Punto azul (no leída): 8px, `accentPrimary`, lado izquierdo

---

## BottomNavigation [REQUIRED]

**Especificación**:
- Fondo: `BackdropFilter` blur 20px + `glassElevated`
- Borde superior: 1px `glassElevatedBorder`
- Altura: 64px + SafeArea bottom
- Ítem activo: ícono + label, `accentPrimary`
- Ítem inactivo: ícono + label, textTertiary
- Badge: círculo 18px, fondo `error`, texto blanco `labelSmall`
- Transición activo/inactivo: 150ms easeInOut
