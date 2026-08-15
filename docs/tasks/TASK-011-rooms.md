# TASK-011 — Estado de habitaciones

**ID**: TASK-011
**SPEC**: SPEC-008
**Dependencias**: TASK-005, TASK-006, TASK-003
**Estado**: DONE

---

## Objetivo

Implementar la pantalla de habitaciones con vista grid/lista, filtros por estado, y pantalla de detalle.

## Alcance

### Provider

```dart
// rooms_provider.dart

// Stream combinado rooms + bookings → calcula displayStatus
// (compartido con dashboard — definir en un solo lugar)
final roomsWithStatusProvider = StreamProvider<List<RoomWithStatus>>((ref) {
  final roomsStream = ref.watch(roomRepositoryProvider).getAll();
  final bookingsStream = ref.watch(bookingRepositoryProvider).getAll();
  
  return Rx.combineLatest2(roomsStream, bookingsStream, (rooms, bookings) {
    return _calculateRoomsWithStatus(rooms, bookings);
  });
});

// Lógica de cálculo de displayStatus (igual que RoomStatusService del sistema web)
List<RoomWithStatus> _calculateRoomsWithStatus(List<Room> rooms, List<Booking> bookings) {
  final today = DateTime.now();
  // Si room.status != 'available' → displayStatus = room.status
  // Si room.status == 'available' Y tiene booking confirmed/pending con checkInDate == hoy
  //   → displayStatus = 'reserved'
  // Sino → displayStatus = 'available'
}

// Filtro por estado
final roomStatusFilterProvider = StateProvider<String?>((ref) => null); // null = todos
```

### Pantallas

1. **rooms_screen.dart** (lib/presentation/rooms/)
   - Header con contador total y ocupadas
   - Chips de filtro horizontal con scroll
   - Toggle grid/lista
   - Grid: 3 columnas, tarjetas cuadradas con color de estado
   - Lista: más información por habitación
   - Pull-to-refresh

2. **room_detail_screen.dart**
   - Información completa de la habitación
   - Estado con color
   - Si occupied: nombre del huésped + fecha check-out + enlace "Ver cuenta"
   - Si cleaning/maintenance: enlace "Ver tarea activa"
   - Si reserved: enlace "Ver reserva" → ArrivalDetailScreen

### Widgets

- `room_grid_card.dart` — Tarjeta cuadrada para la vista grid
- `room_list_tile.dart` — Tile para la vista lista
- `room_status_filter_chips.dart` — Chips de filtro con scroll horizontal

## Criterios de aceptación

- [ ] Grid muestra todas las habitaciones con color de estado correcto
- [ ] Estado "reserved" calculado correctamente
- [ ] Filtros por estado funcionan
- [ ] Toggle grid/lista funciona
- [ ] Vista lista muestra nombre del huésped en habitaciones ocupadas
- [ ] RoomDetailScreen muestra información completa
- [ ] Enlace a cuenta del huésped visible en habitaciones ocupadas
- [ ] Pull-to-refresh actualiza los datos
- [ ] Lista se actualiza en tiempo real
- [ ] Housekeeper ve todas las habitaciones
- [ ] Widget test: colores de estado correctos en RoomGridCard

## Notas

- El `roomsWithStatusProvider` es compartido con el dashboard (TASK-007). Asegurarse de definirlo en un solo lugar y reutilizarlo.
- Para obtener el nombre del huésped en habitaciones ocupadas, el booking activo (`status == 'checked-in'`) ya tiene `guestName` — no se necesita query adicional a `guests`.
