# API Y DATOS — Le Quint Mobile App

**Nota**: La app accede directamente a Firestore. No hay REST API. Este documento mapea colecciones, queries y operaciones necesarias por funcionalidad.

---

## COLECCIONES FIRESTORE UTILIZADAS

### `users/{uid}`
**Uso**: Autenticación, datos del usuario, control de sesiones
**Campos relevantes**: `role`, `active`, `activeUntil`, `maxSessions`, `activeSessionsCount`, `sessions`, `fcmToken`
**Operaciones**:
- Read: obtener datos del usuario actual
- Update: crear/eliminar sesión, heartbeat, guardar fcmToken

### `rooms/{roomId}`
**Uso**: Estado de habitaciones
**Campos relevantes**: `roomNumber`, `floor`, `roomType`, `status`, `isActive`, `basePrice`, `capacity`, `currentGuestId`
**Operaciones**:
- Read (stream): lista de habitaciones en tiempo real

### `bookings/{bookingId}`
**Uso**: Reservas, llegadas, salidas, huéspedes en casa
**Campos relevantes**: `status`, `checkInDate`, `checkOutDate`, `guestName`, `roomNumber`, `roomId`, `guestId`
**Operaciones**:
- Read (stream): todas las reservas (para calcular estado de habitaciones)
- Read (query): llegadas del día (`checkInDate == hoy AND status in [confirmed, pending]`)
- Read (query): salidas del día (`checkOutDate == hoy AND status == checked-in`)
- Read (query): en casa (`status == checked-in`)
- Update: `checkIn()` → status = checked-in
- Update: `checkOut()` → status = checked-out

### `guestAccounts/{accountId}`
**Uso**: Cuentas de huéspedes, saldos, cargos
**Campos relevantes**: `bookingId`, `guestName`, `roomNumber`, `status`, `charges`, `payments`, `balance`, `total`
**Operaciones**:
- Read (stream): cuentas abiertas
- Read (single): cuenta por bookingId
- Update: agregar cargo (`charges` array)

### `housekeepingTasks/{taskId}`
**Uso**: Tareas de limpieza y mantenimiento
**Campos relevantes**: `assignedTo`, `roomNumber`, `floor`, `taskType`, `status`, `priority`, `scheduledDate`
**Operaciones**:
- Read (stream): tareas del usuario actual (`assignedTo == uid`)
- Read (stream): todas las tareas (manager/admin)
- Update: `status = in-progress`, `startedAt`
- Update: `status = completed`, `completedAt`, `actualDuration`, `completionNotes`, `issuesFound`

### `notifications/{notificationId}`
**Uso**: Notificaciones del usuario
**Campos relevantes**: `userId`, `type`, `title`, `message`, `read`, `priority`, `actionUrl`
**Operaciones**:
- Read (stream): notificaciones del usuario actual
- Update: `read = true`

---

## QUERIES CRÍTICAS

### Llegadas del día
```dart
FirebaseFirestore.instance
  .collection('bookings')
  .where('checkInDate', isGreaterThanOrEqualTo: startOfDay)
  .where('checkInDate', isLessThan: endOfDay)
  .where('status', whereIn: ['confirmed', 'pending'])
  .snapshots()
```
**Índice requerido**: `checkInDate ASC + status ASC` (verificar si existe en Firestore)

### Salidas del día
```dart
FirebaseFirestore.instance
  .collection('bookings')
  .where('checkOutDate', isGreaterThanOrEqualTo: startOfDay)
  .where('checkOutDate', isLessThan: endOfDay)
  .where('status', isEqualTo: 'checked-in')
  .snapshots()
```

### Mis tareas (housekeeper)
```dart
FirebaseFirestore.instance
  .collection('housekeepingTasks')
  .where('assignedTo', isEqualTo: currentUserId)
  .where('status', whereIn: ['pending', 'in-progress'])
  .snapshots()
```

### Cuentas abiertas
```dart
FirebaseFirestore.instance
  .collection('guestAccounts')
  .where('status', isEqualTo: 'open')
  .snapshots()
```

---

## OPERACIONES DE ESCRITURA CRÍTICAS

### Check-In
```
1. Verificar booking.status == 'confirmed'
2. Verificar que no existe guestAccount para este bookingId
3. Crear guestAccount con cargo de alojamiento
4. Update room.status = 'occupied'
5. Update booking.status = 'checked-in'
```
**Nota**: Estas operaciones deben ejecutarse en orden. Idealmente en una transacción Firestore o batch write.

### Check-Out
```
1. Verificar booking.status == 'checked-in'
2. Verificar guestAccount.balance == 0
3. Update room.status = 'dirty'
4. Update booking.status = 'checked-out'
```

### Completar Tarea
```
1. Verificar task.status == 'in-progress'
2. Update task: status = 'completed', completedAt, actualDuration, completionNotes, issuesFound
3. Si requiresMaintenance:
   a. Update room.status = 'maintenance'
   b. Crear nueva tarea de mantenimiento
4. Si !requiresMaintenance:
   a. Update room.status = 'available'
   b. Update room.assignedHousekeeperId = null
```

---

## CÁLCULOS DEL DASHBOARD FINANCIERO

Los cálculos se realizan en el cliente (igual que el sistema web):

### Ingresos totales del período
```
= Σ guestAccounts.total WHERE status='closed' AND closedAt IN período
+ Σ sales.total WHERE createdAt IN período
```

### Tasa de ocupación
```
= (noches vendidas / noches disponibles) * 100
noches disponibles = totalRooms * días del período
noches vendidas = Σ noches de bookings checked-in/checked-out que intersectan el período
```

### RevPAR
```
= ingresos totales / (totalRooms * días del período)
```

### ADR
```
= ingresos totales / noches vendidas
```

---

## APIs FALTANTES / LIMITACIONES IDENTIFICADAS

### Sin limitaciones críticas para el MVP
Todas las operaciones necesarias están disponibles directamente en Firestore con las colecciones existentes.

### Consideraciones de índices Firestore
Los siguientes índices compuestos pueden ser necesarios y deben verificarse en la consola Firebase:

| Colección | Campos | Tipo |
|---|---|---|
| bookings | checkInDate ASC, status ASC | Compuesto |
| bookings | checkOutDate ASC, status ASC | Compuesto |
| bookings | status ASC, checkInDate ASC | Compuesto |
| housekeepingTasks | assignedTo ASC, status ASC | Compuesto |
| housekeepingTasks | status ASC, scheduledDate ASC | Compuesto |
| notifications | userId ASC, createdAt DESC | Compuesto (ya existe) |
| notifications | userId ASC, read ASC | Compuesto (ya existe) |

### Transacciones para operaciones críticas
Check-in y check-out involucran múltiples documentos. Se recomienda usar `WriteBatch` o `runTransaction` en Firestore para garantizar atomicidad, igual que el sistema web.
