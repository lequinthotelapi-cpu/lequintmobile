# TASK-009 — Llegadas y Check-In

**ID**: TASK-009
**SPEC**: SPEC-006
**Dependencias**: TASK-005, TASK-006, TASK-003
**Estado**: PENDING

---

## Objetivo

Implementar la pantalla de llegadas del día y el flujo completo de check-in con confirmación.

## Alcance

### Provider (lib/application/bookings/)

```dart
// bookings_provider.dart

final arrivalsProvider = StreamProvider.autoDispose<List<Booking>>((ref) {
  return ref.read(bookingRepositoryProvider).getArrivalsForDate(DateTime.now());
});

// Acción check-in
// Retorna AsyncValue para manejar loading/error en la UI
```

### Pantallas

1. **arrivals_screen.dart** (lib/presentation/front_desk/)
   - Header con fecha y contador de llegadas
   - Barra de búsqueda (filtra por nombre o habitación)
   - Lista de reservas con badge de estado
   - Pull-to-refresh
   - Empty state: "No hay llegadas programadas para hoy"

2. **arrival_detail_screen.dart**
   - Datos completos de la reserva (ver SPEC-006)
   - Badge VIP si `guest.vip == true`
   - Sección de solicitudes especiales (si existen)
   - Botón "Realizar Check-In"
     - Deshabilitado con tooltip si `status != 'confirmed'`
   - Al tap: mostrar `ConfirmCheckInDialog`

3. **confirm_check_in_dialog.dart** (o usar `confirm_dialog.dart` genérico)
   - Resumen: nombre, habitación, fechas, noches
   - Botón "Confirmar Check-In" en verde

### Flujo de check-in

```dart
// En arrival_detail_screen.dart
Future<void> _performCheckIn() async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (_) => ConfirmCheckInDialog(booking: booking),
  );
  if (confirmed != true) return;
  
  // Mostrar loading overlay
  // Llamar al repositorio (WriteBatch: crear guestAccount + update room + update booking)
  // Éxito: pop + snackbar
  // Error: mostrar mensaje específico
}
```

## Criterios de aceptación

- [ ] Lista muestra solo llegadas del día actual
- [ ] Búsqueda filtra en tiempo real por nombre y habitación
- [ ] Badge de estado correcto (verde=confirmada, amarillo=pendiente)
- [ ] ArrivalDetailScreen muestra todos los datos de la reserva
- [ ] Badge VIP visible si aplica
- [ ] Botón check-in deshabilitado si status != confirmed
- [ ] Dialog de confirmación muestra resumen
- [ ] Check-in exitoso: pop a lista + snackbar con nombre y habitación
- [ ] Check-in crea guestAccount automáticamente
- [ ] Check-in cambia habitación a occupied
- [ ] Error de check-in muestra mensaje específico
- [ ] Widget test: botón deshabilitado si reserva no está confirmed

## Notas

- La query de llegadas requiere índice compuesto en Firestore. Si no existe, Firestore dará un error con el link para crearlo. Documentar el índice necesario.
- El `guestAccount` creado en el check-in usa IVA = 0 para el MVP (DECISION-005 — IVA parametrizado, ignorar por ahora). Dejar un TODO comentado en el código.
