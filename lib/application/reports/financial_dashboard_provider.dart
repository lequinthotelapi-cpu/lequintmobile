import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/booking.dart';
import '../../domain/models/guest_account.dart';
import '../../domain/models/room.dart';
import '../../domain/models/sale.dart';
import '../../domain/repositories/sale_repository.dart';
import '../../domain/services/financial_calculator.dart';
import '../../domain/services/report_period.dart';
import '../../infrastructure/firebase/sale_firebase_repository.dart';
import '../bookings/bookings_provider.dart';
import '../guest_accounts/guest_account_provider.dart';
import '../rooms/rooms_provider.dart';

final saleRepositoryProvider = Provider<SaleRepository>((ref) {
  return SaleFirebaseRepository();
});

/// Período seleccionado en ReportsScreen — mes actual por defecto
/// (DECISION-015).
final selectedPeriodProvider = StateProvider<ReportPeriod>(
  (ref) => ReportPeriod.month,
);

class _ReportData {
  const _ReportData({
    required this.activeRooms,
    required this.bookings,
    required this.guestAccounts,
    required this.sales,
    required this.range,
  });

  final List<Room> activeRooms;
  final List<Booking> bookings;
  final List<GuestAccount> guestAccounts;
  final List<Sale> sales;
  final DateRange range;
}

/// Trae los datos crudos que necesitan tanto [financialMetricsProvider]
/// como [revenueBySourceProvider] para [period] — evita duplicar las 4
/// queries entre ambos.
Future<_ReportData> _loadReportData(Ref ref, ReportPeriod period) async {
  final range = dateRangeForPeriod(period, DateTime.now());

  final rooms = await ref.watch(roomRepositoryProvider).getAll().first;
  final bookings = await ref.watch(bookingRepositoryProvider).getAll().first;
  final guestAccounts = await ref
      .watch(guestAccountRepositoryProvider)
      .getAll();
  final sales = await ref
      .watch(saleRepositoryProvider)
      .getByDateRange(range.start, range.end);

  return _ReportData(
    activeRooms: rooms.where((room) => room.isActive).toList(),
    bookings: bookings,
    guestAccounts: guestAccounts,
    sales: sales,
    range: range,
  );
}

/// KPIs financieros de [period] — ver SPEC-010. `FutureProvider.family`
/// para cachear por período (TASK-013 "Consideraciones técnicas").
final financialMetricsProvider = FutureProvider.autoDispose
    .family<FinancialKpis, ReportPeriod>((ref, period) async {
      final data = await _loadReportData(ref, period);
      return calculateFinancialKpis(
        activeRooms: data.activeRooms,
        bookings: data.bookings,
        guestAccounts: data.guestAccounts,
        sales: data.sales,
        periodStart: data.range.start,
        periodEnd: data.range.end,
      );
    });

/// Ingresos por fuente de [period] — ver SPEC-010 sección 4.
final revenueBySourceProvider = FutureProvider.autoDispose
    .family<List<RevenueBySource>, ReportPeriod>((ref, period) async {
      final data = await _loadReportData(ref, period);
      return calculateRevenueBySource(
        data.guestAccounts,
        data.sales,
        data.range.start,
        data.range.end,
      );
    });
