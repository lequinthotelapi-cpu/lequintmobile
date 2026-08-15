# TASK-016 — Supervisión de housekeeping (Manager/Admin)

**ID**: TASK-016
**SPEC**: SPEC-003 (sección housekeeping manager), F-015
**Dependencias**: TASK-008
**Estado**: PENDING

---

## Objetivo

Implementar la vista de supervisión de tareas de housekeeping para el manager y admin: todas las tareas del día, estado por empleado, tareas urgentes.

## Alcance

### Provider (extender housekeeping_provider.dart)

```dart
// Todas las tareas (no filtradas por usuario)
final allTasksProvider = StreamProvider.autoDispose<List<HousekeepingTask>>(...);

// Tareas agrupadas por empleado
final tasksByEmployeeProvider = Provider.autoDispose<Map<String, List<HousekeepingTask>>>((ref) {
  final tasks = ref.watch(allTasksProvider).value ?? [];
  return groupBy(tasks, (t) => t.assignedTo ?? 'unassigned');
});
```

### Pantalla: AllTasksScreen (lib/presentation/housekeeping/)

**Secciones**:
1. Resumen del día: pendientes, en progreso, completadas hoy, vencidas
2. Filtros: Todos / Pendiente / En progreso / Completada / Urgentes
3. Lista de tareas con información completa
   - Habitación, piso, tipo, prioridad, estado, empleado asignado
4. Pull-to-refresh

**Vista por empleado** (tab o toggle):
- Lista de empleados con sus tareas activas
- Contador de pendientes e in-progress por empleado

## Criterios de aceptación

- [ ] AllTasksScreen muestra todas las tareas (no solo las del usuario)
- [ ] Filtros por estado funcionan
- [ ] Resumen del día con contadores correctos
- [ ] Tareas urgentes destacadas visualmente
- [ ] Vista por empleado muestra tareas agrupadas
- [ ] Solo manager/admin/superadmin pueden acceder
- [ ] Pull-to-refresh actualiza los datos

## Notas

- Esta pantalla es accesible desde el bottom nav de manager/admin (ítem Housekeeping)
- El housekeeper accede a MyTasksScreen (TASK-008), no a esta pantalla
