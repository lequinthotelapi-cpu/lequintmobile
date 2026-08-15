# SPEC-011 — Cuenta de Huésped y Agregar Cargo

**ID**: SPEC-011
**Nombre**: Consultar cuenta de huésped y agregar cargo desde catálogo
**Estado**: READY_FOR_DEVELOPMENT
**Prioridad**: Should Have
**Release**: MVP
**Personas afectadas**: Receptionist, Manager

---

## Objetivo

Permitir al recepcionista consultar el detalle de la cuenta de un huésped (cargos, pagos, saldo) y agregar cargos desde el catálogo de productos, similar al flujo de "cargar a habitación" del POS web.

## Contexto

El recepcionista necesita poder registrar consumos (minibar, servicios, etc.) desde el móvil sin abrir el POS completo. El flujo es: seleccionar cuenta → seleccionar productos del catálogo → confirmar cargo (DECISION-014).

## Actores

- Receptionist (lectura + escritura)
- Manager (solo lectura)

## Precondiciones

- Usuario autenticado con rol receptionist/manager/admin/superadmin
- Cuenta de huésped con `status == 'open'`

---

## Pantalla: GuestAccountScreen

### Acceso
- Desde DepartureDetailScreen (enlace "Ver cuenta")
- Desde RoomDetailScreen (habitación ocupada)
- Desde InHouseScreen (lista de huéspedes en casa)
- Desde Dashboard (cuentas abiertas)

### Layout

```
┌─────────────────────────────────────┐
│  ← Atrás                            │
│                                     │
│  Juan García                        │
│  Hab. 205 · Check-in: 12 ene        │
│  ● Cuenta abierta                   │
│                                     │
│  RESUMEN                            │
│  Subtotal:    $400.00               │
│  IVA:          $52.00               │
│  Total:       $452.00               │
│  Pagado:      $200.00               │
│  Saldo:       $252.00               │
│                                     │
│  CARGOS                             │
│  ┌─────────────────────────────┐    │
│  │ Alojamiento · 3 noches      │    │
│  │ $150.00 x 3 = $450.00       │    │
│  │ 12 ene 2025                 │    │
│  └─────────────────────────────┘    │
│  ┌─────────────────────────────┐    │
│  │ POS: Agua mineral x2        │    │
│  │ $1.00 x 2 = $2.00           │    │
│  │ 13 ene 2025                 │    │
│  └─────────────────────────────┘    │
│                                     │
│  PAGOS                              │
│  ┌─────────────────────────────┐    │
│  │ Efectivo · $200.00          │    │
│  │ 12 ene 2025                 │    │
│  └─────────────────────────────┘    │
│                                     │
│  [+ Agregar Cargo]                  │  ← solo receptionist/admin
└─────────────────────────────────────┘
```

### Secciones
1. **Header**: nombre del huésped, habitación, fecha check-in, estado de cuenta
2. **Resumen financiero**: subtotal, IVA, total, pagado, saldo (destacado)
3. **Lista de cargos**: ordenados por fecha DESC
4. **Lista de pagos**: ordenados por fecha DESC
5. **Botón "Agregar Cargo"**: visible solo para receptionist/admin/superadmin

---

## Flujo — Agregar Cargo desde Catálogo

### Paso 1: Seleccionar productos (AddChargeScreen)

```
┌─────────────────────────────────────┐
│  ← Agregar Cargo                    │
│  Juan García · Hab. 205             │
│                                     │
│  🔍 Buscar producto...              │
│                                     │
│  BEBIDAS                            │
│  ┌─────────────────────────────┐    │
│  │ Agua mineral 500ml          │    │
│  │ $1.50 · Stock: 24           │    │
│  │                    [+] 0 [-]│    │
│  └─────────────────────────────┘    │
│  ┌─────────────────────────────┐    │
│  │ Coca-Cola 350ml             │    │
│  │ $2.00 · Stock: 18           │    │
│  │                    [+] 2 [-]│    │
│  └─────────────────────────────┘    │
│                                     │
│  SNACKS                             │
│  ┌─────────────────────────────┐    │
│  │ Papas fritas                │    │
│  │ $3.00 · Stock: 10           │    │
│  │                    [+] 0 [-]│    │
│  └─────────────────────────────┘    │
│                                     │
│  ─────────────────────────────      │
│  2 productos · Total: $4.00         │
│  [CONFIRMAR CARGO]                  │
└─────────────────────────────────────┘
```

### Paso 2: Confirmar cargo

```
┌─────────────────────────────────────┐
│  Confirmar Cargo                    │
│                                     │
│  Coca-Cola 350ml x2    $4.00        │
│                                     │
│  Total a cargar: $4.00              │
│  Cuenta: Juan García · Hab. 205     │
│                                     │
│  [Cancelar]  [Confirmar Cargo]      │
└─────────────────────────────────────┘
```

### Paso 3: Ejecución

1. App crea cargo en `guestAccount.charges`:
   ```
   type: 'pos'
   description: 'POS: Coca-Cola 350ml x2'
   amount: total de los productos
   quantity: 1
   ```
2. App actualiza stock de cada producto: `product.currentStock -= quantity`
3. App recalcula totales de la cuenta
4. Éxito: pop a GuestAccountScreen + snackbar "Cargo agregado"

---

## Reglas de negocio

1. Solo cuentas con `status == 'open'` pueden recibir cargos
2. Solo productos con `isActive == true` y `currentStock > 0` aparecen en el catálogo
3. La cantidad seleccionada no puede exceder el `currentStock` del producto
4. El cargo se registra como tipo `'pos'` en la cuenta
5. El stock del producto se reduce al confirmar el cargo
6. El total del cargo es la suma de `product.price * quantity` para cada producto seleccionado
7. Los totales de la cuenta (subtotal, IVA, total, balance) se recalculan automáticamente

## Excepciones

| Condición | Mensaje |
|---|---|
| Cuenta cerrada | "Esta cuenta ya está cerrada" |
| Sin productos en carrito | "Selecciona al menos un producto" |
| Stock insuficiente | "Stock insuficiente para [producto]" |
| Error de red | "Error de conexión. Intenta nuevamente." |

## Datos

**Productos para catálogo**:
```
products
  WHERE isActive == true
  AND currentStock > 0
  ORDER BY category, name
```

**WriteBatch al confirmar cargo**:
- Update: `guestAccounts/{accountId}` → agregar cargo, recalcular totales
- Update: `products/{productId}` → decrementar currentStock (por cada producto)

## UI/UX

- Catálogo agrupado por categoría
- Búsqueda en tiempo real por nombre o código
- Controles +/- para cantidad por producto
- Resumen flotante en la parte inferior con total y botón confirmar
- Botón confirmar deshabilitado si carrito vacío
- GuestAccountScreen: saldo destacado (rojo si > 0, verde si = 0)

## Estados de pantalla

| Estado | Comportamiento |
|---|---|
| Loading (cuenta) | Skeleton |
| Loading (catálogo) | Skeleton de lista |
| Success | Datos de la cuenta / catálogo |
| Empty (catálogo) | "No hay productos disponibles" |
| Error | Mensaje + reintentar |

## Permisos

| Rol | Acceso |
|---|---|
| receptionist | Lectura + agregar cargo |
| admin / superadmin | Lectura + agregar cargo |
| manager | Solo lectura (sin botón agregar cargo) |
| housekeeper | Sin acceso |

## Criterios de aceptación

- [ ] GuestAccountScreen muestra cargos, pagos y saldo correctamente
- [ ] Saldo destacado en rojo si > 0, verde si = 0
- [ ] Botón "Agregar Cargo" visible solo para receptionist/admin
- [ ] Catálogo muestra solo productos activos con stock > 0
- [ ] Búsqueda filtra productos en tiempo real
- [ ] Controles +/- respetan el stock máximo
- [ ] Resumen del carrito actualiza el total en tiempo real
- [ ] Confirmación muestra resumen antes de ejecutar
- [ ] Cargo exitoso actualiza la cuenta y reduce el stock
- [ ] Manager ve la cuenta pero no puede agregar cargos

## Consideraciones técnicas

- Usar `WriteBatch` para actualizar cuenta + stock de productos en una sola operación atómica
- El catálogo de productos puede ser grande. Implementar búsqueda en cliente (no query por cada keystroke)
- Agrupar productos por categoría usando `groupBy` en el cliente

---

## UX / DESIGN REQUIREMENTS

**Design System**: `docs/ux/design-system.md`
**Tokens**: `docs/ux/design-tokens.md`
**Componentes**: `docs/ux/components.md` — `GlassCard`, `SearchBar`, `PrimaryButton`, `ConfirmDialog`, `SkeletonLoader`
**Referencias**: `docs/design-references/general.jpg`, `docs/design-references/controls.jpg`

### Elementos REQUIRED
- `GuestAccountScreen`: saldo destacado — rojo si >0, verde si =0 (`displayMedium`)
- Secciones RESUMEN / CARGOS / PAGOS en `GlassCard`s separadas
- Botón "Agregar Cargo": visible solo para receptionist/admin/superadmin
- `AddChargeScreen`: catálogo agrupado por categoría, controles +/- por producto
- Resumen flotante en la parte inferior con total + botón confirmar
- Botón confirmar deshabilitado si carrito vacío
- `ConfirmDialog` con lista de productos y total antes de ejecutar

### Elementos FLEXIBLE
- Estilo de los controles +/- (pueden ser botones circulares o rectangulares)
- Posición del resumen flotante (bottom bar fija vs sticky footer)
- Agrupación visual de categorías (headers de sección vs chips de filtro)
