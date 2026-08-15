# INTERACCIÓN — Le Quint Mobile App

> Patrones de interacción, feedback y comportamiento de la UI.

---

## Principios de interacción

1. **Feedback inmediato** — Toda acción del usuario recibe respuesta visual en < 100ms
2. **Confirmación en acciones críticas** — Check-in, check-out, completar tarea, cerrar sesión
3. **Reversibilidad** — Cuando sea posible, permitir deshacer o cancelar
4. **Prevención de errores** — Deshabilitar acciones no disponibles en lugar de mostrar error después

---

## Gestos estándar [REQUIRED]

| Gesto | Acción |
|---|---|
| Tap | Acción principal del elemento |
| Long press | Acciones contextuales (si aplica) |
| Swipe horizontal | Navegación entre tabs (si aplica) |
| Pull-to-refresh | Recargar datos de la pantalla actual |
| Swipe down | Cerrar bottom sheet / modal |
| Swipe back (iOS) | Navegar atrás |

---

## Estados de botones [REQUIRED]

| Estado | Visual |
|---|---|
| Default | Color normal, opacidad 100% |
| Pressed | Escala 0.97, opacidad 90% — duración 100ms |
| Loading | Spinner blanco, texto oculto, opacidad 70%, no interactuable |
| Disabled | Opacidad 38%, no interactuable |
| Success | Ícono check verde, 1.5s, luego vuelve a default |

---

## Feedback de operaciones [REQUIRED]

### Operaciones rápidas (< 500ms esperado)
- Mostrar loading en el botón (spinner inline)
- No bloquear el resto de la pantalla

### Operaciones lentas (> 500ms esperado)
- `LoadingOverlay` semitransparente sobre la pantalla
- Pantalla no interactuable durante la operación
- Ejemplos: check-in, check-out, completar tarea

### Éxito
- `SnackBar` en la parte inferior
- Fondo: `successBg`, borde `success`
- Texto: mensaje específico (ej: "Check-in realizado — Juan García, Hab. 205")
- Duración: 3 segundos
- Acción opcional (ej: "Ver cuenta")

### Error
- `SnackBar` en la parte inferior
- Fondo: `errorBg`, borde `error`
- Texto: mensaje específico del error
- Duración: 4 segundos (más tiempo para leer)
- Sin acción automática de retry en el snackbar (el retry va en la pantalla)

---

## Confirmaciones [REQUIRED]

Las siguientes acciones SIEMPRE requieren confirmación antes de ejecutarse:

| Acción | Tipo de confirmación |
|---|---|
| Check-in | `ConfirmDialog` con resumen de la operación |
| Check-out | `ConfirmDialog` con resumen de la operación |
| Iniciar tarea | `ConfirmDialog` simple |
| Completar tarea | Pantalla completa (`CompleteTaskScreen`) |
| Agregar cargo | `ConfirmDialog` con resumen del carrito |
| Cerrar sesión | `ConfirmDialog` |

---

## Pull-to-refresh [REQUIRED en todas las listas y dashboards]

- Indicador: spinner circular, `accentPrimary`
- Threshold: 80px de arrastre
- Comportamiento: invalida el provider y recarga datos
- No mostrar skeleton durante pull-to-refresh (los datos actuales permanecen visibles)

---

## Scroll behavior [DESIGN GUIDELINE]

- AppBar: puede colapsar al hacer scroll (opcional, Claude decide)
- Listas largas: `ListView.builder` siempre
- Scroll infinito: no en MVP (cargar todo con LIMIT razonable)
- Scroll horizontal: solo para chips de filtro

---

## Teclado [REQUIRED]

- Al abrir un formulario, el primer campo recibe focus automáticamente
- Al confirmar en el teclado (`TextInputAction.next`): mover al siguiente campo
- Al confirmar en el último campo (`TextInputAction.done`): cerrar teclado
- El scroll del formulario debe ajustarse para que el campo activo sea visible sobre el teclado

---

## Notificaciones in-app (foreground) [REQUIRED]

- Banner en la parte superior de la pantalla
- Fondo: GlassCard.elevated()
- Ícono + título + mensaje (truncado a 1 línea)
- Duración: 4 segundos
- Tap: navegar al destino + cerrar banner
- Swipe up: cerrar banner
- No bloquea la interacción con la pantalla actual

---

## Estados de conectividad [REQUIRED]

### Al perder conexión
- `OfflineBanner` aparece con animación slide-down
- Los datos en caché siguen siendo visibles
- Las acciones de escritura se encolan (Firestore offline)
- No mostrar error en cada pantalla — el banner es suficiente

### Al recuperar conexión
- `OfflineBanner` desaparece con animación slide-up
- Los datos se sincronizan automáticamente (Firestore)
- No mostrar snackbar de "conexión restaurada" (innecesario)

---

## Navegación [REQUIRED]

### Atrás
- Botón atrás en AppBar: siempre visible en pantallas de detalle
- Swipe back (iOS): habilitado
- Botón atrás de Android: comportamiento estándar

### Deep links desde notificaciones
- Si la app está cerrada: abrir app → navegar directamente a la pantalla
- Si la app está en background: traer al frente → navegar
- Si la app está en foreground: navegar directamente

### Logout
- Usar `GoRouter.go('/login')` — limpia el stack completo
- No se puede volver con el botón atrás después del logout

---

## Accesibilidad [REQUIRED]

- Área táctil mínima: 44×44px (aunque el elemento visual sea más pequeño)
- Todos los íconos interactivos tienen `Tooltip` o `Semantics` label
- Los estados de loading tienen `Semantics(label: 'Cargando...')`
- Los errores tienen `Semantics(label: 'Error: [mensaje]')`
- No depender solo del color para comunicar estado
