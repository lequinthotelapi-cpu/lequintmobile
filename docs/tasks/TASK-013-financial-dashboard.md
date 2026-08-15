# TASK-013 — Dashboard financiero

**ID**: TASK-013
**SPEC**: SPEC-010
**Dependencias**: TASK-005, TASK-006, TASK-003
**Estado**: DONE

---

## Objetivo

Implementar el dashboard financiero con KPIs calculados (ingresos, ocupación, RevPAR, ADR, por cobrar) y selector de período.

## Alcance

### Provider

```dart
// financial_dashboard_provider.dart

enum ReportPeriod { today, week, month, year }

final selectedPeriodProvider = StateProvider<ReportPeriod>((ref) => ReportPeriod.month);

final financialMetricsProvider = FutureProvider.autoDispose.family<FinancialMetrics, DateRange>(
  (ref, dateRange) async {
    // Calcular: totalRevenue, occupancyRate, revPAR, adr, accountsReceivable
    // Misma lógica que FinancialReportsService del sistema web
  }
);

final revenueBySourceProvider = FutureProvider.autoDispose.family<List<RevenueBySource>, DateRange>(...);

final openAccountsProvider = StreamProvider.autoDispose<List<GuestAccount>>((ref) {
  return ref.read(guestAccountRepositoryProvider).getOpenAccounts();
});
```

### Pantalla: ReportsScreen (lib/presentation/reports/)

**Secciones**:
1. Selector de período (chips: Hoy / Semana / Mes / Año)
2. KPI principal: Ingresos totales (número grande)
3. Grid 2x2: Ocupación, RevPAR, ADR, Por cobrar
4. Ingresos por fuente (barras horizontales simples — sin librería de gráficos)
5. Lista de cuentas abiertas (máximo 5, ordenadas por saldo DESC)

**Barras de ingresos por fuente** (implementación simple):
```dart
// Container con width proporcional al porcentaje
// No usar fl_chart ni ninguna librería de gráficos para el MVP
Widget _buildRevenueBar(String label, double amount, double maxAmount) {
  final percentage = maxAmount > 0 ? amount / maxAmount : 0.0;
  return Row(children: [
    Text(label),
    Expanded(child: LinearProgressIndicator(value: percentage)),
    Text(formatCurrency(amount)),
  ]);
}
```

### Lógica de cálculo (replicar FinancialReportsService)

```dart
// totalRevenue
// = guestAccounts.where(status='closed' && closedAt IN period).sum(total)
// + sales.where(createdAt IN period).sum(total)

// occupancyRate
// = (nightsSold / nightsAvailable) * 100

// revPAR = totalRevenue / (activeRooms * daysInPeriod)

// adr = totalRevenue / nightsSold

// accountsReceivable = guestAccounts.where(status='open').sum(balance)
```

## Criterios de aceptación

- [ ] KPIs se calculan correctamente para cada período
- [ ] Período por defecto es el mes actual
- [ ] Cambiar período recalcula todos los KPIs
- [ ] "Por cobrar" siempre muestra valor actual (no filtrado por período)
- [ ] Barras de ingresos por fuente son proporcionales
- [ ] Lista de cuentas abiertas ordenada por saldo DESC
- [ ] Tap en cuenta abierta navega a GuestAccountScreen
- [ ] Pull-to-refresh recalcula los datos
- [ ] Skeleton visible durante carga
- [ ] Receptionist y housekeeper no pueden acceder (protección en router)
- [ ] Widget test: selector de período cambia los datos mostrados

## Notas

- Los cálculos son costosos. Usar `FutureProvider.family` con `DateRange` como parámetro para cachear por período.
- No usar librerías de gráficos para el MVP — barras simples con widgets Flutter nativos
- El cálculo de noches que intersectan un período es el algoritmo más complejo. Replicar exactamente `FinancialReportsService.calculateNights()` del sistema web.
- Formatear moneda con `intl` package: `NumberFormat.currency(symbol: '\$', decimalDigits: 2)`
