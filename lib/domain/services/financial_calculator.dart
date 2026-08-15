import '../models/booking.dart';
import '../models/guest_account.dart';
import '../models/room.dart';
import '../models/sale.dart';

const _dayMs = Duration.millisecondsPerDay;

/// Réplica de `FinancialReportsService` (sistema web) — ver SPEC-010,
/// TASK-007. Todas las funciones son puras para poder probarlas sin
/// Firebase; los providers en `dashboard_provider.dart` les pasan los
/// datos ya cargados.

/// `checkIn <= periodEnd && checkOut >= periodStart` — igual que
/// `isBookingInPeriod` del sistema web.
bool isBookingInPeriod(
  Booking booking,
  DateTime periodStart,
  DateTime periodEnd,
) {
  return !booking.checkInDate.isAfter(periodEnd) &&
      !booking.checkOutDate.isBefore(periodStart);
}

/// Noches de la reserva que caen dentro de `[periodStart, periodEnd]`,
/// recortadas a los límites del período y redondeadas hacia arriba — igual
/// que `calculateNights` del sistema web.
int calculateNights(
  DateTime checkIn,
  DateTime checkOut,
  DateTime periodStart,
  DateTime periodEnd,
) {
  final start = checkIn.isAfter(periodStart) ? checkIn : periodStart;
  final end = checkOut.isBefore(periodEnd) ? checkOut : periodEnd;
  if (!start.isBefore(end)) return 0;
  return (end.difference(start).inMilliseconds / _dayMs).ceil();
}

/// Días entre `start` y `end`, ambos inclusive — igual que
/// `getDaysBetween` del sistema web.
int getDaysBetween(DateTime start, DateTime end) {
  return (end.difference(start).abs().inMilliseconds / _dayMs).ceil() + 1;
}

/// Noches vendidas en el período: suma de [calculateNights] sobre las
/// reservas `checked-in`/`checked-out` que intersectan el período.
int nightsSoldInPeriod(
  List<Booking> bookings,
  DateTime periodStart,
  DateTime periodEnd,
) {
  var total = 0;
  for (final booking in bookings) {
    if (booking.status != BookingStatus.checkedIn &&
        booking.status != BookingStatus.checkedOut) {
      continue;
    }
    if (!isBookingInPeriod(booking, periodStart, periodEnd)) continue;
    total += calculateNights(
      booking.checkInDate,
      booking.checkOutDate,
      periodStart,
      periodEnd,
    );
  }
  return total;
}

/// `(nochesVendidas / nochesDisponibles) * 100`. `activeRooms` son las
/// habitaciones con `isActive == true` (sin filtrar por status).
double calculateOccupancyRate(
  List<Room> activeRooms,
  List<Booking> bookings,
  DateTime periodStart,
  DateTime periodEnd,
) {
  if (activeRooms.isEmpty) return 0;
  final nightsAvailable =
      activeRooms.length * getDaysBetween(periodStart, periodEnd);
  if (nightsAvailable == 0) return 0;
  return (nightsSoldInPeriod(bookings, periodStart, periodEnd) /
          nightsAvailable) *
      100;
}

/// `Σ guestAccounts.total (status=closed, closedAt en el período) +
/// Σ sales.total`. [sales] ya debe venir filtrado al período (la query de
/// Firestore lo hace — ver `SaleRepository.getByDateRange`).
double calculateTotalRevenue(
  List<GuestAccount> guestAccounts,
  List<Sale> sales,
  DateTime periodStart,
  DateTime periodEnd,
) {
  var accountsRevenue = 0.0;
  for (final account in guestAccounts) {
    final closedAt = account.closedAt;
    if (account.status != GuestAccountStatus.closed || closedAt == null) {
      continue;
    }
    if (closedAt.isBefore(periodStart) || closedAt.isAfter(periodEnd)) {
      continue;
    }
    accountsRevenue += account.total;
  }
  final salesRevenue = sales.fold<double>(0, (sum, sale) => sum + sale.total);
  return accountsRevenue + salesRevenue;
}

/// `ingresos / (habitacionesActivas * díasDelPeríodo)`.
double calculateRevPAR(
  double revenue,
  List<Room> activeRooms,
  DateTime periodStart,
  DateTime periodEnd,
) {
  final days = getDaysBetween(periodStart, periodEnd);
  if (activeRooms.isEmpty || days == 0) return 0;
  return revenue / (activeRooms.length * days);
}

/// `ingresos / nochesVendidas`.
double calculateADR(
  double revenue,
  List<Booking> bookings,
  DateTime periodStart,
  DateTime periodEnd,
) {
  final nightsSold = nightsSoldInPeriod(bookings, periodStart, periodEnd);
  return nightsSold > 0 ? revenue / nightsSold : 0;
}

/// `Σ guestAccounts.balance WHERE status = 'open'` — no depende del
/// período (siempre es el valor actual).
double calculateAccountsReceivable(List<GuestAccount> guestAccounts) {
  var total = 0.0;
  for (final account in guestAccounts) {
    if (account.status == GuestAccountStatus.open) total += account.balance;
  }
  return total;
}

/// KPIs financieros de un período — ver SPEC-003/SPEC-010. Empaqueta el
/// resultado de las funciones de arriba para exponerlo como un solo valor
/// desde `financialKpisProvider`.
class FinancialKpis {
  const FinancialKpis({
    required this.revenue,
    required this.occupancyRate,
    required this.revPAR,
    required this.adr,
    required this.accountsReceivable,
  });

  final double revenue;
  final double occupancyRate;
  final double revPAR;
  final double adr;
  final double accountsReceivable;
}

/// Un rubro de "Ingresos por fuente" — ver SPEC-010 sección 4.
class RevenueBySource {
  const RevenueBySource({required this.label, required this.amount});

  final String label;
  final double amount;
}

/// Desglosa los ingresos del período por fuente — réplica de
/// `getRevenueBySource` (sistema web). Usa la misma población de cuentas
/// que [calculateTotalRevenue] (cerradas, `closedAt` en el período) y
/// agrupa sus `charges` por tipo; las ventas de [sales] son "POS Directo"
/// (una fuente aparte de los cargos `pos` dentro de una cuenta, que caen en
/// "Otros" — así los clasifica también el sistema web).
List<RevenueBySource> calculateRevenueBySource(
  List<GuestAccount> guestAccounts,
  List<Sale> sales,
  DateTime periodStart,
  DateTime periodEnd,
) {
  var accommodation = 0.0;
  var services = 0.0;
  var other = 0.0;

  for (final account in guestAccounts) {
    final closedAt = account.closedAt;
    if (account.status != GuestAccountStatus.closed || closedAt == null) {
      continue;
    }
    if (closedAt.isBefore(periodStart) || closedAt.isAfter(periodEnd)) {
      continue;
    }
    for (final charge in account.charges) {
      switch (charge.type) {
        case ChargeType.accommodation:
          accommodation += charge.total;
        case ChargeType.service:
          services += charge.total;
        case ChargeType.pos:
        case ChargeType.minibar:
        case ChargeType.laundry:
        case ChargeType.spa:
        case ChargeType.restaurant:
        case ChargeType.other:
          other += charge.total;
      }
    }
  }

  final posDirect = sales.fold<double>(0, (sum, sale) => sum + sale.total);

  return [
    RevenueBySource(label: 'Alojamiento', amount: accommodation),
    RevenueBySource(label: 'POS Directo', amount: posDirect),
    RevenueBySource(label: 'Servicios', amount: services),
    RevenueBySource(label: 'Otros', amount: other),
  ];
}

FinancialKpis calculateFinancialKpis({
  required List<Room> activeRooms,
  required List<Booking> bookings,
  required List<GuestAccount> guestAccounts,
  required List<Sale> sales,
  required DateTime periodStart,
  required DateTime periodEnd,
}) {
  final revenue = calculateTotalRevenue(
    guestAccounts,
    sales,
    periodStart,
    periodEnd,
  );
  return FinancialKpis(
    revenue: revenue,
    occupancyRate: calculateOccupancyRate(
      activeRooms,
      bookings,
      periodStart,
      periodEnd,
    ),
    revPAR: calculateRevPAR(revenue, activeRooms, periodStart, periodEnd),
    adr: calculateADR(revenue, bookings, periodStart, periodEnd),
    accountsReceivable: calculateAccountsReceivable(guestAccounts),
  );
}
