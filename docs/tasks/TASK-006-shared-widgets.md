# TASK-006 — Widgets compartidos

**ID**: TASK-006
**SPEC**: Todos (componentes base)
**Dependencias**: TASK-001
**Estado**: PENDING

---

## Objetivo

Implementar los widgets reutilizables que se usan en múltiples pantallas del MVP.

## Alcance

### lib/presentation/shared/widgets/

1. **loading_widget.dart** — Skeleton loader genérico y spinner
   - `SkeletonCard`: rectángulo con shimmer animation
   - `SkeletonList(count)`: N skeleton cards apiladas
   - `LoadingOverlay`: overlay semitransparente con spinner (para operaciones como check-in)

2. **empty_state_widget.dart** — Estado vacío
   - Ícono + título + subtítulo opcionales
   - Botón de acción opcional

3. **error_widget.dart** — Estado de error
   - Mensaje de error + botón "Reintentar"
   - `onRetry` callback

4. **offline_banner.dart** — Banner de sin conexión
   - Banner persistente en la parte superior cuando `connectivityProvider` indica sin conexión
   - "Sin conexión — mostrando datos en caché"

5. **status_chip.dart** — Chip de estado de habitación
   - Recibe `RoomStatus` → muestra label + color correcto

6. **priority_chip.dart** — Chip de prioridad de tarea
   - Recibe `TaskPriority` → muestra label + color correcto

7. **confirm_dialog.dart** — Dialog de confirmación reutilizable
   - Título, mensaje, botón cancelar, botón confirmar
   - Colores configurables para el botón de confirmación

8. **user_avatar.dart** — Avatar de usuario
   - Muestra foto si existe, iniciales si no
   - Color de fondo basado en el nombre (hash del nombre → color)

### lib/infrastructure/services/connectivity_service.dart

```dart
// StreamProvider que emite ConnectivityStatus (online/offline)
// Usa connectivity_plus
```

## Criterios de aceptación

- [ ] Todos los widgets compilan sin errores
- [ ] SkeletonList muestra animación shimmer
- [ ] OfflineBanner aparece/desaparece según conectividad
- [ ] ConfirmDialog es reutilizable con diferentes textos y colores
- [ ] StatusChip muestra el color correcto para cada estado
- [ ] PriorityChip muestra el color correcto para cada prioridad
- [ ] Widget tests para StatusChip y PriorityChip

## Notas

- Para el shimmer usar el paquete `shimmer`
- Los colores de estado y prioridad vienen de `app_colors.dart` (TASK-001)
