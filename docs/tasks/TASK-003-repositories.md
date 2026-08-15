# TASK-003 — Repositorios Firebase

**ID**: TASK-003
**SPEC**: SPEC-001 al SPEC-012
**Dependencias**: TASK-002
**Estado**: DONE

---

## Objetivo

Implementar las interfaces de repositorios y sus implementaciones Firebase para todas las colecciones necesarias en el MVP.

## Alcance

### Interfaces (lib/domain/repositories/)

1. `auth_repository.dart` — signIn, signOut, getCurrentUser, getUserData, createSession, deleteSession, heartbeat
2. `room_repository.dart` — getAll (stream)
3. `booking_repository.dart` — getAll (stream), getArrivalsForDate, getDeparturesForDate, getByStatus, checkIn, checkOut
4. `housekeeping_repository.dart` — getByEmployee (stream), getAll (stream), startTask, completeTask
5. `guest_account_repository.dart` — getById, getByBooking, getOpenAccounts, addCharge
6. `notification_repository.dart` — getByUserId (stream), getUnreadCount (stream), markAsRead, markAllAsRead
7. `product_repository.dart` — getActiveWithStock (stream)

### Implementaciones Firebase (lib/infrastructure/firebase/)

Para cada repositorio, implementar usando `cloud_firestore`:

**Patrones comunes**:
```dart
// Stream en tiempo real
Stream<List<T>> getAll() {
  return _firestore.collection('collectionName')
    .snapshots()
    .map((snap) => snap.docs.map((doc) => T.fromFirestore(doc)).toList());
}

// Query con filtros
Stream<List<Booking>> getArrivalsForDate(DateTime date) {
  final start = DateTime(date.year, date.month, date.day);
  final end = start.add(const Duration(days: 1));
  return _firestore.collection('bookings')
    .where('checkInDate', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
    .where('checkInDate', isLessThan: Timestamp.fromDate(end))
    .where('status', whereIn: ['confirmed', 'pending'])
    .snapshots()
    .map(...);
}
```

**Operaciones de escritura críticas** (usar WriteBatch):

`checkIn(bookingId, userId)`:
```dart
// 1. Obtener booking y room
// 2. Verificar booking.status == 'confirmed'
// 3. Verificar que no existe guestAccount para bookingId
// 4. WriteBatch:
//    - Create guestAccount con cargo de alojamiento
//    - Update room.status = 'occupied'
//    - Update booking.status = 'checked-in'
```

`checkOut(bookingId, userId)`:
```dart
// 1. Obtener booking y guestAccount
// 2. Verificar booking.status == 'checked-in'
// 3. Verificar guestAccount.balance == 0
// 4. WriteBatch:
//    - Update room.status = 'dirty'
//    - Update booking.status = 'checked-out'
```

`completeTask(taskId, dto, userId)`:
```dart
// 1. Obtener task
// 2. Verificar task.status == 'in-progress'
// 3. WriteBatch:
//    - Update task: status='completed', completedAt, actualDuration, etc.
//    - Update room.status = requiresMaintenance ? 'maintenance' : 'available'
//    - Si requiresMaintenance: Create nueva tarea de mantenimiento
```

`addCharge(accountId, items, userId)`:
```dart
// WriteBatch:
//   - Update guestAccount: agregar cargo, recalcular totales
//   - Update product.currentStock -= quantity (por cada producto)
```

## Criterios de aceptación

- [ ] Todos los repositorios compilan sin errores
- [ ] Streams emiten datos correctamente desde Firestore
- [ ] `checkIn` es atómico (WriteBatch)
- [ ] `checkOut` es atómico (WriteBatch) y verifica balance = 0
- [ ] `completeTask` es atómico (WriteBatch)
- [ ] `addCharge` es atómico (WriteBatch)
- [ ] Errores de Firestore se convierten a `AppException` tipadas
- [ ] Unit tests con mocks para la lógica de validación de checkIn/checkOut/completeTask

## Notas

- No usar `.toPromise()` — en Dart usar `await future` directamente
- Los Timestamps de Firestore se convierten a DateTime en los modelos
- Para el `addCharge`, el recálculo de totales de la cuenta (subtotal, IVA, total, balance) debe replicar la lógica de `GuestAccountService.calculateTotals()` del sistema web
