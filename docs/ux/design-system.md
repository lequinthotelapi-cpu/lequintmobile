# DESIGN SYSTEM — Le Quint Mobile App

> Documento central del sistema de diseño.
> Lee también: `visual-direction.md`, `design-tokens.md`, `components.md`, `interaction.md`

---

## Principios

1. **Usabilidad primero** — Ningún efecto visual puede perjudicar la usabilidad
2. **Legibilidad siempre** — Contraste mínimo WCAG AA en todo texto
3. **Jerarquía clara** — El usuario sabe qué es lo más importante en cada pantalla
4. **Consistencia** — Los mismos patrones en toda la app
5. **Velocidad** — Las acciones frecuentes requieren el mínimo de pasos
6. **Feedback inmediato** — El usuario siempre sabe qué está pasando

---

## Identidad visual

### Estilo general
Premium Hospitality / Enterprise Glass UI sobre fondo oscuro.

Ver `visual-direction.md` para el análisis completo de referencias.

### Fondo de la app [REQUIRED]
Gradiente oscuro vertical: `#0A0F1E` → `#141B2D`

Implementación Flutter:
```dart
Container(
  decoration: const BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [AppColors.backgroundGradientTop, AppColors.backgroundGradientBottom],
    ),
  ),
)
```

### Glass cards [REQUIRED]
Toda card principal usa `BackdropFilter` con blur + fondo semitransparente + borde sutil.

```dart
ClipRRect(
  borderRadius: BorderRadius.circular(AppTokens.radiusLarge),
  child: BackdropFilter(
    filter: ImageFilter.blur(sigmaX: AppTokens.blurPrimary, sigmaY: AppTokens.blurPrimary),
    child: Container(
      decoration: BoxDecoration(
        color: AppColors.glassPrimary,
        borderRadius: BorderRadius.circular(AppTokens.radiusLarge),
        border: Border.all(color: AppColors.glassPrimaryBorder, width: 1),
        boxShadow: AppTokens.shadowCard,
      ),
      padding: const EdgeInsets.all(AppTokens.cardPadding),
      child: content,
    ),
  ),
)
```

---

## Estructura de pantalla

### Layout estándar
```
SafeArea
  └── Scaffold (backgroundColor: transparent)
        ├── AppBar (glass, opcional)
        └── Body
              └── Stack
                    ├── GradientBackground (posición fija)
                    └── SingleChildScrollView / ListView
                          └── Padding(horizontal: screenPadding)
                                └── Column(children: [...])
```

### Secciones dentro de una pantalla
- Separar secciones con `SizedBox(height: sectionGap)` — no con Dividers
- Cada sección puede tener un header label (labelMedium, textTertiary)
- Las cards dentro de una sección se separan con `SizedBox(height: cardGap)`

---

## Componentes base

Ver `components.md` para especificaciones detalladas de cada componente.

### Jerarquía de componentes

```
AppShell
  ├── GradientBackground
  ├── AppBar (glass)
  ├── BottomNavigation (glass)
  └── Screen content
        ├── GlassCard (KPI, info, detalle)
        ├── GlassListTile (ítems de lista)
        ├── StatusChip (habitaciones, tareas)
        ├── PriorityChip (tareas)
        ├── PrimaryButton
        ├── SecondaryButton
        ├── TextInput
        ├── SearchBar
        ├── FilterChips
        ├── LoadingState (skeleton)
        ├── EmptyState
        └── ErrorState
```

---

## Patrones de pantalla

### Pantalla de lista
```
Header (título + contador)
SearchBar (si aplica)
FilterChips (si aplica)
ListView
  └── GlassListTile × N
EmptyState (si lista vacía)
```

### Pantalla de detalle
```
AppBar (← Atrás + título)
ScrollView
  ├── GlassCard (información principal)
  ├── GlassCard (sección 2)
  └── GlassCard (sección 3)
BottomActionBar (botón de acción principal)
```

### Pantalla de formulario
```
AppBar (← Cancelar + título)
ScrollView
  └── GlassCard
        └── Form fields
BottomActionBar (botón confirmar)
```

### Dashboard
```
Header (saludo + fecha)
ScrollView
  ├── KPIRow (2-4 KPI cards)
  ├── GlassCard (sección principal)
  ├── GlassCard (sección secundaria)
  └── QuickActionsRow
```

---

## Estados de pantalla [REQUIRED en todas las pantallas]

Toda pantalla que carga datos debe implementar los 5 estados:

| Estado | Componente | Descripción |
|---|---|---|
| Loading | `SkeletonLoader` | Skeleton con shimmer, misma estructura que el contenido real |
| Success | Contenido normal | Datos cargados |
| Empty | `EmptyState` | Ícono + mensaje contextual |
| Error | `ErrorState` | Mensaje + botón reintentar |
| Offline | `OfflineBanner` + caché | Banner superior + datos del caché si disponibles |

---

## Navegación

### Bottom Navigation [REQUIRED]
- Fondo: glass elevado con blur 20px
- Ítem activo: color de acento + label visible
- Ítem inactivo: textTertiary + label visible
- Badge de notificaciones: círculo rojo con número, máximo "99+"
- Altura: 64px + SafeArea bottom

### AppBar [REQUIRED]
- Fondo: glass elevado o transparente (según si hay scroll)
- Título: headlineSmall, textPrimary
- Botón atrás: ícono flecha, textSecondary
- Acciones: íconos, textSecondary

### Transiciones [DESIGN GUIDELINE]
- Entre tabs del bottom nav: sin animación (instantáneo)
- Push de pantalla: slide desde la derecha (estándar iOS/Android)
- Modal / bottom sheet: slide desde abajo
- Dialog: fade + scale

---

## Formularios

### Inputs [REQUIRED]
- Fondo: `Color(0x1AFFFFFF)` (glass sutil)
- Borde: 1px `Color(0x33FFFFFF)` en reposo, `accentPrimary` en focus
- Texto: textPrimary
- Label flotante: textSecondary → accentPrimary en focus
- Error: borde rojo + mensaje debajo en rojo
- Altura: 52px
- Radius: 12px

### Validación [REQUIRED]
- Validar al perder el foco (onBlur), no en cada keystroke
- Mensajes de error específicos (no "Campo requerido" genérico)
- Botón de submit deshabilitado si hay errores o campos requeridos vacíos

---

## Accesibilidad [REQUIRED]

- Contraste mínimo texto/fondo: 4.5:1 (WCAG AA)
- Tamaño mínimo de área táctil: 44×44px
- Todos los íconos interactivos tienen `Semantics` label
- Los estados de loading tienen `Semantics` con descripción
- No depender solo del color para comunicar estado (usar ícono + color)

---

## Rendimiento [REQUIRED]

- Usar `const` constructors donde sea posible
- `BackdropFilter` solo en elementos que realmente lo necesitan (no en listas largas)
- Para listas largas: usar `ListView.builder` (no `Column` con children)
- Imágenes: `CachedNetworkImage` con placeholder
- Shimmer: solo durante loading, no como decoración permanente

---

## Consistencia con el sistema web

Los colores de estado de habitaciones y prioridades de tareas son IDÉNTICOS al sistema web.
Ver `design-tokens.md` para los valores exactos.

No inventar nuevos colores de estado. No cambiar los existentes.
