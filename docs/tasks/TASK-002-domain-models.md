# TASK-002 — Modelos de dominio

**ID**: TASK-002
**SPEC**: SPEC-001 al SPEC-012 (todos los modelos)
**Dependencias**: TASK-001
**Estado**: PENDING

---

## Objetivo

Implementar todos los modelos de dominio en Dart, equivalentes a los modelos TypeScript del sistema web.

## Alcance

Crear los siguientes archivos con sus modelos, enums y métodos `fromFirestore` / `toFirestore`:

1. `lib/domain/models/user.dart`
   - `UserRole` enum: superadmin, admin, manager, receptionist, housekeeper, guest
   - `User` class con todos los campos del modelo web
   - `fromFirestore(DocumentSnapshot)` factory

2. `lib/domain/models/room.dart`
   - `RoomStatus` enum: available, occupied, dirty, cleaning, maintenance, blocked
   - `Room` class
   - `RoomWithStatus` class (agrega `displayStatus` calculado)
   - `fromFirestore` factory

3. `lib/domain/models/booking.dart`
   - `BookingStatus` enum: pending, confirmed, checked-in, checked-out, cancelled, no-show
   - `Booking` class
   - `fromFirestore` factory

4. `lib/domain/models/guest.dart`
   - `Guest` class (campos básicos necesarios para el MVP)
   - `fromFirestore` factory

5. `lib/domain/models/guest_account.dart`
   - `GuestAccountStatus` enum: open, closed
   - `ChargeType` enum
   - `PaymentMethod` enum
   - `Charge` class
   - `Payment` class
   - `GuestAccount` class
   - `fromFirestore` factory

6. `lib/domain/models/housekeeping_task.dart`
   - `TaskType` enum: cleaning, maintenance, inspection, deep-cleaning
   - `TaskStatus` enum: pending, in-progress, completed, cancelled
   - `TaskPriority` enum: low, normal, high, urgent
   - `HousekeepingTask` class
   - `fromFirestore` factory

7. `lib/domain/models/notification.dart`
   - `NotificationType` enum
   - `NotificationPriority` enum
   - `AppNotification` class (nombre diferente para evitar conflicto con Flutter)
   - `fromFirestore` factory

8. `lib/domain/models/product.dart`
   - `Product` class (campos necesarios para catálogo)
   - `fromFirestore` factory

9. `lib/domain/models/sale.dart`
   - `SaleItem` class
   - `Sale` class
   - `fromFirestore` factory

## Criterios de aceptación

- [ ] Todos los modelos compilan sin errores
- [ ] `fromFirestore` maneja campos nulos correctamente (sin lanzar excepciones)
- [ ] Los enums tienen métodos de conversión desde/hacia String
- [ ] Unit tests para `fromFirestore` de los modelos críticos (Booking, HousekeepingTask, GuestAccount)
- [ ] `flutter analyze` sin warnings en los modelos

## Notas

- Los Timestamps de Firestore deben convertirse a `DateTime` en el `fromFirestore`
- Usar `freezed` es opcional — para el MVP, clases simples con `fromFirestore` son suficientes
- El modelo `AppNotification` usa ese nombre para evitar conflicto con `flutter/material.dart`
