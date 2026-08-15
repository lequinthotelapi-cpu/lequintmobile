# TASK-007 — Dashboard por rol

**ID**: TASK-007
**SPEC**: SPEC-003
**Dependencias**: TASK-005, TASK-006, TASK-003
**Estado**: PENDING

---

## Objetivo

Implementar las pantallas de dashboard diferenciadas por rol: superadmin/admin, manager, receptionist y housekeeper.

## Alcance

### Providers (lib/application/dashboard/)

```dart
// dashboard_provider.dart
final operationalStatsProvider = FutureProvider.autoDispose<OperationalStats>(...);
// OperationalStats: arrivalsToday, departuresToday, roomsByStatus, openAccountsCount

final roomsWithStatusProvider = StreamProvider<List<RoomWithStatus>>(...);
// Combina rooms stream + bookings stream → calcula displayStatus
```

### Pantallas (lib/presentation/dashboard/)

1. **dashboard_screen.dart** — Router que renderiza el dashboard correcto según rol:
   ```dart
   switch (userRole) {
     case UserRole.superadmin:
     case UserRole.admin: return AdminDashboard();
     case UserRole.manager: return ManagerDashboard();
     case UserRole.receptionist: return ReceptionistDashboard();
     case UserRole.housekeeper: return HousekeeperDashboard();
   }
   ```

2. **widgets/admin_dashboard.dart** — KPIs operacionales + financieros + estado habitaciones + accesos rápidos

3. **widgets/manager_dashboard.dart** — KPIs operacionales + financieros + resumen housekeeping

4. **widgets/receptionist_dashboard.dart** — Llegadas/salidas del día prominentes + estado habitaciones + accesos rápidos

5. **widgets/housekeeper_dashboard.dart** — Resumen de tareas del día + lista de las primeras 5 tareas

### Widgets del dashboard (lib/presentation/dashboard/widgets/)

- `operational_kpis_card.dart` — Tarjetas de llegadas, salidas, ocupación, cuentas abiertas
- `room_status_summary.dart` — Resumen visual de habitaciones por estado (contadores con colores)
- `quick_actions_row.dart` — Fila de botones de acceso rápido
- `financial_kpis_card.dart` — Tarjetas de ingresos, RevPAR, ADR, por cobrar (solo para admin/manager)
- `housekeeping_summary_card.dart` — Resumen de tareas (solo para admin/manager)
- `task_preview_list.dart` — Lista preview de tareas (solo para housekeeper dashboard)

## Criterios de aceptación

- [ ] Cada rol ve su dashboard correcto
- [ ] Pull-to-refresh actualiza todos los datos
- [ ] Skeleton visible durante carga inicial
- [ ] Estado vacío con mensaje contextual
- [ ] Accesos rápidos navegan a la pantalla correcta
- [ ] Estado "reserved" calculado correctamente en el resumen de habitaciones
- [ ] Housekeeper dashboard muestra solo sus tareas
- [ ] Widget test: cada dashboard renderiza las secciones correctas para su rol

## Notas

- Los KPIs financieros del dashboard admin/manager usan el mismo cálculo que SPEC-010 pero solo para el día actual (para el dashboard). El ReportsScreen tiene el selector de período completo.
- El `roomsWithStatusProvider` es compartido entre el dashboard y RoomsScreen — definirlo una sola vez
