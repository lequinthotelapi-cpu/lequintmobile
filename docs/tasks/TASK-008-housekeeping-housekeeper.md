# TASK-008 — Mis tareas y completar tarea (Housekeeper)

**ID**: TASK-008
**SPEC**: SPEC-004, SPEC-005
**Dependencias**: TASK-005, TASK-006, TASK-003
**Estado**: PENDING

---

## Objetivo

Implementar el flujo completo del housekeeper: ver sus tareas asignadas, ver el detalle de una tarea, iniciarla y completarla.

## Alcance

### Provider (lib/application/housekeeping/)

```dart
// housekeeping_provider.dart

// Tareas del usuario actual (housekeeper)
final myTasksProvider = StreamProvider.autoDispose<List<HousekeepingTask>>((ref) {
  final uid = ref.watch(currentUserProvider).value?.uid;
  return ref.read(housekeepingRepositoryProvider).getByEmployee(uid!);
});

// Todas las tareas (para manager/admin)
final allTasksProvider = StreamProvider.autoDispose<List<HousekeepingTask>>(...);

// Acción: iniciar tarea
final startTaskProvider = ...

// Acción: completar tarea
final completeTaskProvider = ...
```

### Pantallas

1. **my_tasks_screen.dart** (lib/presentation/housekeeping/)
   - Sección "En progreso" (si hay)
   - Sección "Pendientes" ordenadas por prioridad
   - Pull-to-refresh
   - Empty state: "No tienes tareas asignadas por ahora"
   - Tap → TaskDetailScreen

2. **task_detail_screen.dart**
   - Información completa de la tarea
   - Botón "Iniciar Tarea" (si pending) con confirmación
   - Botón "Completar Tarea" (si in-progress)
   - Loading overlay durante operaciones

3. **complete_task_screen.dart**
   - Campo duración real (número, requerido, mínimo 1)
   - Campo notas de completación (opcional)
   - Checkbox "¿Requiere mantenimiento?"
   - Campo notas de mantenimiento (visible si checkbox activo)
   - Botón "Confirmar Completación" (deshabilitado si duración vacía)
   - Validación antes de enviar

### Widgets

- `task_card.dart` — Tarjeta de tarea en la lista (prioridad chip, habitación, tipo, estado)
- `task_priority_chip.dart` — Chip de prioridad con color

## Criterios de aceptación

- [ ] MyTasksScreen muestra solo tareas del usuario actual
- [ ] Tareas in-progress aparecen primero
- [ ] Tareas ordenadas por prioridad (urgent primero)
- [ ] Tareas completadas/canceladas no aparecen
- [ ] Tap en tarea navega a TaskDetailScreen
- [ ] Botón "Iniciar" visible solo si status == pending
- [ ] Botón "Completar" visible solo si status == in-progress
- [ ] Iniciar tarea muestra confirmación
- [ ] CompleteTaskScreen valida duración > 0
- [ ] Campo mantenimiento aparece solo si checkbox activo
- [ ] Completar sin mantenimiento → habitación a available
- [ ] Completar con mantenimiento → habitación a maintenance
- [ ] Tarea completada desaparece de MyTasksScreen en tiempo real
- [ ] Widget test: CompleteTaskScreen valida duración > 0

## Notas

- El ordenamiento por prioridad se hace en el cliente: `urgent > high > normal > low`, luego por `scheduledDate`
- La operación de completar tarea usa `WriteBatch` (implementado en TASK-003)
- Si la tarea está `pending` y el usuario toca "Completar", iniciarla automáticamente primero (igual que sistema web)
