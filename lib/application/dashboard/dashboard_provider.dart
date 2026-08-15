import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/services/financial_calculator.dart';
import '../../domain/services/report_period.dart';
import '../reports/financial_dashboard_provider.dart';

/// KPIs financieros del mes actual para el dashboard admin/manager — ver
/// SPEC-003. Delegado a [financialMetricsProvider] (TASK-013/SPEC-010, el
/// motor de cálculo completo con selector de período) fijando el período
/// en "mes" (DECISION-015) — evita duplicar las queries/fórmulas entre el
/// dashboard de inicio y ReportsScreen.
final financialKpisProvider = FutureProvider.autoDispose<FinancialKpis>((ref) {
  return ref.watch(financialMetricsProvider(ReportPeriod.month).future);
});
