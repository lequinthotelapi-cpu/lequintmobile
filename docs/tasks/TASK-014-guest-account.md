# TASK-014 — Cuenta de huésped y agregar cargo

**ID**: TASK-014
**SPEC**: SPEC-011
**Dependencias**: TASK-005, TASK-006, TASK-003
**Estado**: PENDING

---

## Objetivo

Implementar la pantalla de detalle de cuenta de huésped (cargos, pagos, saldo) y el flujo de agregar cargo desde el catálogo de productos.

## Alcance

### Provider

```dart
// guest_accounts_provider.dart

final guestAccountProvider = StreamProvider.autoDispose.family<GuestAccount?, String>(
  (ref, accountId) => ref.read(guestAccountRepositoryProvider).getById(accountId),
);

final activeProductsProvider = StreamProvider.autoDispose<List<Product>>((ref) {
  return ref.read(productRepositoryProvider).getActiveWithStock();
});

// Estado del carrito (local, no persiste)
final cartProvider = StateNotifierProvider.autoDispose<CartNotifier, List<CartItem>>(...);
```

### Pantallas

1. **guest_account_screen.dart** (lib/presentation/guest_accounts/)
   - Header: nombre del huésped, habitación, estado de cuenta
   - Resumen financiero: subtotal, IVA, total, pagado, saldo (destacado)
   - Lista de cargos (fecha, tipo, descripción, total)
   - Lista de pagos (fecha, método, monto)
   - Botón "Agregar Cargo" (solo receptionist/admin/superadmin)
   - Saldo en rojo si > 0, verde si = 0

2. **add_charge_screen.dart**
   - Barra de búsqueda de productos
   - Lista de productos agrupados por categoría
   - Controles +/- por producto
   - Resumen flotante en la parte inferior (total + botón confirmar)
   - Botón confirmar deshabilitado si carrito vacío

3. **confirm_charge_dialog.dart**
   - Lista de productos seleccionados con cantidades y subtotales
   - Total a cargar
   - Nombre del huésped y habitación
   - Botón "Confirmar Cargo"

### CartNotifier

```dart
class CartNotifier extends StateNotifier<List<CartItem>> {
  void addItem(Product product)
  void removeItem(String productId)
  void updateQuantity(String productId, int quantity)
  void clear()
  double get total
}
```

## Criterios de aceptación

- [ ] GuestAccountScreen muestra cargos, pagos y saldo correctamente
- [ ] Saldo en rojo si > 0, verde si = 0
- [ ] Botón "Agregar Cargo" visible solo para receptionist/admin
- [ ] Manager ve la cuenta pero sin botón de agregar cargo
- [ ] Catálogo muestra solo productos activos con stock > 0
- [ ] Búsqueda filtra productos en tiempo real
- [ ] Controles +/- respetan el stock máximo
- [ ] Total del carrito se actualiza en tiempo real
- [ ] Confirmación muestra resumen antes de ejecutar
- [ ] Cargo exitoso actualiza la cuenta y reduce el stock
- [ ] WriteBatch garantiza atomicidad (cuenta + stock)
- [ ] Widget test: botón agregar cargo no visible para manager

## Notas

- El catálogo de productos puede ser grande. Cargar todos al abrir AddChargeScreen y filtrar en cliente.
- Agrupar por categoría usando `groupBy` de `package:collection`
- El cargo se registra como tipo `'pos'` con descripción generada automáticamente: `'POS: [producto1] x[qty], [producto2] x[qty]'`
- Los totales de la cuenta se recalculan en el repositorio (TASK-003) replicando la lógica de `GuestAccountService.calculateTotals()`
