# DESIGN TOKENS — Le Quint Mobile App

> Valores concretos para implementación en Flutter.
> REQUIRED = debe cumplirse. DESIGN GUIDELINE = flexible dentro del espíritu del diseño.

---

## COLOR

### Backgrounds [REQUIRED]

```dart
// Fondo base de la app — gradiente vertical
static const backgroundGradientTop = Color(0xFF0A0F1E);     // navy profundo
static const backgroundGradientBottom = Color(0xFF141B2D);  // slate oscuro

// Alternativa sólida (para pantallas sin gradiente)
static const backgroundSolid = Color(0xFF0D1117);
```

### Glass Surfaces [REQUIRED]

```dart
// Glass primario — cards principales, modales, bottom sheets
static const glassPrimary = Color(0x1AFFFFFF);        // white 10%
static const glassPrimaryBorder = Color(0x33FFFFFF);  // white 20%

// Glass secundario — cards de menor jerarquía
static const glassSecondary = Color(0x0DFFFFFF);      // white 5%
static const glassSecondaryBorder = Color(0x1AFFFFFF); // white 10%

// Glass elevado — bottom nav, app bar
static const glassElevated = Color(0x26FFFFFF);       // white 15%
static const glassElevatedBorder = Color(0x40FFFFFF); // white 25%
```

### Blur [REQUIRED]

```dart
// Blur para glass primario
static const double blurPrimary = 12.0;

// Blur para glass elevado (nav, app bar)
static const double blurElevated = 20.0;

// Blur para overlays (modales, bottom sheets)
static const double blurOverlay = 16.0;
```

### Texto [REQUIRED]

```dart
static const textPrimary = Color(0xF2FFFFFF);    // white 95%
static const textSecondary = Color(0x99FFFFFF);  // white 60%
static const textTertiary = Color(0x66FFFFFF);   // white 40%
static const textDisabled = Color(0x33FFFFFF);   // white 20%
```

### Acento / Brand [REQUIRED]

```dart
static const accentPrimary = Color(0xFF3B82F6);      // azul — acción principal
static const accentPrimaryLight = Color(0xFF60A5FA); // azul claro — hover/focus
static const accentSecondary = Color(0xFF06B6D4);    // cyan — acento secundario
```

### Estados de habitación [REQUIRED — consistentes con sistema web]

```dart
static const roomAvailable = Color(0xFF10B981);
static const roomReserved = Color(0xFF8B5CF6);
static const roomOccupied = Color(0xFFEF4444);
static const roomDirty = Color(0xFFF59E0B);
static const roomCleaning = Color(0xFF3B82F6);
static const roomMaintenance = Color(0xFF6366F1);

// Versiones con opacidad para fondos de chips/cards
static const roomAvailableBg = Color(0x1A10B981);    // 10%
static const roomReservedBg = Color(0x1A8B5CF6);
static const roomOccupiedBg = Color(0x1AEF4444);
static const roomDirtyBg = Color(0x1AF59E0B);
static const roomCleaningBg = Color(0x1A3B82F6);
static const roomMaintenanceBg = Color(0x1A6366F1);
```

### Prioridades de tarea [REQUIRED — consistentes con sistema web]

```dart
static const priorityUrgent = Color(0xFFEF4444);
static const priorityHigh = Color(0xFFF59E0B);
static const priorityNormal = Color(0xFF3B82F6);
static const priorityLow = Color(0xFF10B981);
```

### Semánticos [REQUIRED]

```dart
static const success = Color(0xFF10B981);
static const warning = Color(0xFFF59E0B);
static const error = Color(0xFFEF4444);
static const info = Color(0xFF3B82F6);

// Fondos semánticos (para banners, alertas)
static const successBg = Color(0x1A10B981);
static const warningBg = Color(0x1AF59E0B);
static const errorBg = Color(0x1AEF4444);
static const infoBg = Color(0x1A3B82F6);
```

---

## TIPOGRAFÍA [REQUIRED]

```dart
// Fuente: Inter (Google Fonts) o sistema (SF Pro en iOS, Roboto en Android)
// Preferir Inter para consistencia cross-platform

// Display — KPIs grandes, números principales
static const TextStyle displayLarge = TextStyle(
  fontSize: 36,
  fontWeight: FontWeight.w700,
  color: textPrimary,
  letterSpacing: -0.5,
);

static const TextStyle displayMedium = TextStyle(
  fontSize: 28,
  fontWeight: FontWeight.w700,
  color: textPrimary,
  letterSpacing: -0.3,
);

// Títulos de pantalla y sección
static const TextStyle headlineLarge = TextStyle(
  fontSize: 22,
  fontWeight: FontWeight.w600,
  color: textPrimary,
);

static const TextStyle headlineMedium = TextStyle(
  fontSize: 18,
  fontWeight: FontWeight.w600,
  color: textPrimary,
);

static const TextStyle headlineSmall = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w600,
  color: textPrimary,
);

// Cuerpo de texto
static const TextStyle bodyLarge = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w400,
  color: textPrimary,
  height: 1.5,
);

static const TextStyle bodyMedium = TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.w400,
  color: textSecondary,
  height: 1.5,
);

static const TextStyle bodySmall = TextStyle(
  fontSize: 12,
  fontWeight: FontWeight.w400,
  color: textTertiary,
  height: 1.4,
);

// Labels y chips
static const TextStyle labelLarge = TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.w500,
  color: textPrimary,
  letterSpacing: 0.1,
);

static const TextStyle labelMedium = TextStyle(
  fontSize: 12,
  fontWeight: FontWeight.w500,
  color: textSecondary,
  letterSpacing: 0.2,
);

static const TextStyle labelSmall = TextStyle(
  fontSize: 11,
  fontWeight: FontWeight.w500,
  color: textTertiary,
  letterSpacing: 0.3,
);
```

---

## SPACING [REQUIRED]

```dart
// Escala de 4px
static const double space2 = 2.0;
static const double space4 = 4.0;
static const double space6 = 6.0;
static const double space8 = 8.0;
static const double space12 = 12.0;
static const double space16 = 16.0;
static const double space20 = 20.0;
static const double space24 = 24.0;
static const double space32 = 32.0;
static const double space40 = 40.0;
static const double space48 = 48.0;

// Padding de pantalla (horizontal)
static const double screenPadding = 20.0;

// Padding interno de cards
static const double cardPadding = 16.0;

// Gap entre cards
static const double cardGap = 12.0;

// Gap entre secciones
static const double sectionGap = 24.0;
```

---

## BORDER RADIUS [REQUIRED]

```dart
static const double radiusSmall = 8.0;    // chips, badges
static const double radiusMedium = 12.0;  // inputs, botones
static const double radiusLarge = 16.0;   // cards principales
static const double radiusXLarge = 20.0;  // bottom sheets, modales
static const double radiusFull = 999.0;   // pills, avatares
```

---

## SOMBRAS [DESIGN GUIDELINE]

```dart
// Sombra para glass cards
static const List<BoxShadow> shadowCard = [
  BoxShadow(
    color: Color(0x33000000),
    blurRadius: 20,
    offset: Offset(0, 8),
  ),
  BoxShadow(
    color: Color(0x0DFFFFFF),
    blurRadius: 1,
    offset: Offset(0, 1),
    spreadRadius: -1,
  ),
];

// Sombra para elementos elevados (FAB, bottom nav)
static const List<BoxShadow> shadowElevated = [
  BoxShadow(
    color: Color(0x4D000000),
    blurRadius: 32,
    offset: Offset(0, 16),
  ),
];
```

---

## ALTURAS DE CONTROLES [REQUIRED]

```dart
static const double buttonHeight = 52.0;       // botón primario
static const double buttonHeightSmall = 40.0;  // botón secundario/compacto
static const double inputHeight = 52.0;        // campo de texto
static const double chipHeight = 32.0;         // chips de filtro
static const double chipHeightSmall = 24.0;    // chips de estado/prioridad
static const double bottomNavHeight = 64.0;    // bottom navigation bar
static const double appBarHeight = 56.0;       // app bar
static const double avatarSize = 40.0;         // avatar estándar
static const double avatarSizeLarge = 64.0;    // avatar en perfil
static const double iconSize = 22.0;           // ícono estándar
static const double iconSizeSmall = 18.0;      // ícono pequeño
```

---

## ANIMACIONES [DESIGN GUIDELINE]

```dart
// Duraciones
static const Duration durationFast = Duration(milliseconds: 150);
static const Duration durationNormal = Duration(milliseconds: 250);
static const Duration durationSlow = Duration(milliseconds: 400);

// Curvas
static const Curve curveDefault = Curves.easeInOut;
static const Curve curveEnter = Curves.easeOut;
static const Curve curveExit = Curves.easeIn;
static const Curve curveSpring = Curves.elasticOut;
```

---

## OPACIDADES [REQUIRED]

```dart
static const double opacityDisabled = 0.38;
static const double opacityMedium = 0.60;
static const double opacityHigh = 0.87;
static const double opacityFull = 1.0;
```

---

## GRID DE HABITACIONES [REQUIRED]

```dart
// Columnas en vista grid
static const int roomGridColumnsPhone = 3;
static const int roomGridColumnsTablet = 4;

// Aspect ratio de tarjeta de habitación
static const double roomCardAspectRatio = 1.0; // cuadrada
```
