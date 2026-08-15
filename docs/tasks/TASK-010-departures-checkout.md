# TASK-010 — Salidas y Check-Out

**ID**: TASK-010
**SPEC**: SPEC-007
**Dependencias**: TASK-005, TASK-006, TASK-003
**Estado**: DONE

---

## Objetivo

Implementar la pantalla de salidas del día y el flujo completo de check-out con verificación de saldo y confirmación.

## Alcance

### Provider

```dart
// En bookings_provider.dart (extender TASK-009)

final departuresProvider = StreamProvider.autoDispose<List<Booking>>((ref) {
  return ref.read(bookingRepositoryProvider).getDeparturesForDate(DateTime.now());
});

// Provider para obtener guestAccount por bookingId
final guestAccountByBookingProvider = FutureProvider.autoDispose.family<GuestAccount?, String>(
  (ref, bookingId) => ref.read(guestAccountRepositoryProvider).getByBooking(bookingId),
);
```

### Pantallas

1. **departures_screen.dart** (lib/presentation/front_desk/)
   - Header con fecha y contador de salidas
   - Barra de búsqueda
   - Lista con indicador de saldo (verde $0 / naranja >$0)
   - Pull-to-refresh
   - Empty state: "No hay salidas programadas para hoy"

2. **departure_detail_screen.dart**
   - Datos de la reserva
   - Resumen de cuenta: total, pagado, saldo
   - Si saldo > 0: card de advertencia naranja con enlace "Ver cuenta"
   - Botón "Realizar Check-Out":
     - Habilitado solo si balance == 0
     - Si balance > 0: deshabilitado con mensaje explicativo
   - Al tap: mostrar ConfirmCheckOutDialog

3. **confirm_check_out_dialog.dart**
   - Resumen: nombre, habitación, noches, total pagado
   - Botón "Confirmar Check-Out"

### Flujo de check-out

```dart
Future<void> _performCheckOut() async {
  // Verificar balance == 0 (segunda verificación en cliente)
  if (account.balance > 0) {
    // Mostrar snackbar de error
    return;
  }
  
  final confirmed = await showDialog<bool>(...);
  if (confirmed != true) return;
  
  // Loading overlay
  // WriteBatch: update room.status='dirty' + update booking.status='checked-out'
  // Éxito: pop + snackbar
  // Error: mensaje específico
}
```

## Criterios de aceptación

- [ ] Lista muestra solo salidas del día actual
- [ ] Indicador de saldo visible en la lista (verde $0, naranja >$0)
- [ ] DepartureDetailScreen muestra resumen de cuenta
- [ ] Advertencia de saldo pendiente visible y clara
- [ ] Enlace "Ver cuenta" navega a GuestAccountScreen
- [ ] Botón check-out deshabilitado si balance > 0
- [ ] Dialog de confirmación muestra resumen
- [ ] Check-out exitoso: pop a lista + snackbar
- [ ] Check-out cambia habitación a dirty
- [ ] Errores muestran mensajes específicos
- [ ] Widget test: botón deshabilitado si balance > 0

## Notas

- Para mostrar el saldo en la lista, necesita cargar la guestAccount de cada booking. Usar `Future.wait` para cargar en paralelo.
- Si no existe guestAccount para un booking (caso edge), mostrar saldo como "N/A" y deshabilitar el check-out con mensaje "No se encontró la cuenta del huésped"
