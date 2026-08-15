# VISUAL DIRECTION — Le Quint Mobile App

**Basado en**: Referencias visuales en `docs/design-references/` + identidad del producto
**Estilo**: Premium Hospitality / Enterprise Glass UI

---

## Intención visual

La app debe sentirse como una herramienta profesional de alta gama diseñada para el personal de un hotel boutique. No es una app de consumo masivo. No es una demo visual. Es una herramienta operativa que debe ser rápida, legible y confiable — con una estética que refleje la calidad del establecimiento.

**Palabras clave**: moderno · premium · tecnológico · elegante · limpio · funcional · hospitalario

---

## Análisis de referencias visuales

### dashboard.jpg
- Fondos oscuros con gradientes profundos (azul marino / negro)
- Cards con efecto glass: fondo semitransparente, borde sutil, blur del fondo
- Tipografía blanca sobre fondo oscuro — alto contraste
- KPIs con números grandes y prominentes
- Jerarquía clara: número principal → label secundario → contexto terciario
- Separación visual mediante elevación y transparencia, no mediante líneas duras

### glass-effect.jpg
- Glass aplicado con moderación: no toda la UI es glass
- El glass funciona sobre fondos con textura o gradiente — no sobre fondos planos
- Blur suave (8-16px), no excesivo
- Borde del glass: 1px con opacidad 20-30% del color blanco
- Sombra exterior suave para separar el card del fondo
- El contenido dentro del glass tiene contraste suficiente para ser legible

### colors.jpg
- Paleta base: tonos oscuros (navy, slate, charcoal) como fondo
- Acentos: azul eléctrico, cyan, verde esmeralda
- Colores de estado: semánticos y consistentes
- No usar colores saturados en grandes áreas — reservarlos para acentos y estados
- Gradientes sutiles en backgrounds, no en elementos de UI

### controls.jpg
- Inputs con fondo glass o semitransparente sobre fondo oscuro
- Bordes de inputs: 1px, color sutil, se iluminan al focus
- Botones primarios: fondo sólido con color de acento, bordes redondeados (radius 12px)
- Botones secundarios: outline o glass
- Chips: pequeños, redondeados, con color semántico
- Switches y checkboxes: estilo moderno, no Material Design estándar

### general.jpg
- Layout con padding generoso — no abarrotar la pantalla
- Secciones separadas por espacio, no por líneas
- Iconografía: línea fina, moderna (no filled Material icons por defecto)
- Listas con separación visual entre ítems mediante espacio o glass cards
- Bottom navigation: fondo glass o sólido oscuro, ítem activo con acento de color

---

## Dirección de diseño

### Fondo de la app
- Fondo base: gradiente oscuro vertical (navy profundo → slate oscuro)
- No fondo blanco. No fondo gris claro.
- El gradiente da profundidad sin ser distractivo

### Superficies
- **Surface primaria**: glass card (backdrop-filter blur + fondo semitransparente)
- **Surface secundaria**: fondo ligeramente más claro que el background, sin blur
- **Surface de acción**: color de acento sólido (botones primarios)

### Tipografía
- Fuente: Inter o SF Pro (sistema) — limpia, moderna, legible
- Jerarquía estricta: no más de 3 tamaños en una pantalla
- Texto principal: blanco o blanco con opacidad alta (90%)
- Texto secundario: blanco con opacidad media (60%)
- Texto terciario / labels: blanco con opacidad baja (40%)

### Iconografía
- Preferir iconos de línea fina (Lucide, Phosphor, o Material Outlined)
- Tamaño estándar: 20-24px
- Color: heredado del texto (blanco con opacidad)

### Colores de estado
Estos colores son REQUIRED — deben ser consistentes en toda la app y con el sistema web:

| Estado habitación | Color |
|---|---|
| available | #10b981 |
| reserved | #8b5cf6 |
| occupied | #ef4444 |
| dirty | #f59e0b |
| cleaning | #3b82f6 |
| maintenance | #6366f1 |

| Prioridad tarea | Color |
|---|---|
| urgent | #ef4444 |
| high | #f59e0b |
| normal | #3b82f6 |
| low | #10b981 |

---

## Principios de aplicación del glass

### Cuándo usar glass
- Cards de KPIs en dashboards
- Cards de información en pantallas de detalle
- Bottom navigation bar
- Modales y bottom sheets
- Elementos flotantes (FAB, banners)
- AppBar cuando hay contenido detrás

### Cuándo NO usar glass
- Inputs de formulario (usar surface sólida semitransparente)
- Botones primarios (usar color sólido)
- Listas largas (el glass en cada ítem es costoso y visualmente ruidoso)
- Texto sobre glass (el texto va dentro del glass, no encima de otro glass)

### Regla fundamental
**El contenido siempre tiene prioridad visual sobre el efecto glass.**
Si el glass perjudica la legibilidad, reducir el blur o aumentar la opacidad del fondo.

---

## Jerarquía visual por pantalla

Cada pantalla debe tener exactamente:
1. **Un elemento de máxima jerarquía** (número KPI grande, título de sección, acción principal)
2. **Elementos de jerarquía media** (cards de información, listas)
3. **Elementos de jerarquía baja** (labels, metadatos, acciones secundarias)

No competir por atención. No todo puede ser prominente.

---

## Diferenciación por rol

La identidad visual es la misma para todos los roles. Lo que cambia es el contenido y la densidad de información:

- **Housekeeper**: UI más simple, elementos más grandes, menos información por pantalla
- **Receptionist**: Densidad media, acciones prominentes
- **Manager / Superadmin**: Mayor densidad de información, KPIs numéricos prominentes

---

## Lo que esta app NO debe parecer

- Una app de Material Design estándar con colores azul/blanco
- Una app de consumo (Instagram, WhatsApp)
- Una demo de glassmorphism con efectos por todos lados
- Una app web adaptada a móvil
- Una app con fondo blanco y texto negro
