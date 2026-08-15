import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lequintmobile/application/guest_accounts/guest_account_provider.dart';
import 'package:lequintmobile/application/reports/financial_dashboard_provider.dart';
import 'package:lequintmobile/domain/models/guest_account.dart';
import 'package:lequintmobile/domain/services/financial_calculator.dart';
import 'package:lequintmobile/domain/services/report_period.dart';
import 'package:lequintmobile/presentation/reports/reports_screen.dart';

const _monthKpis = FinancialKpis(
  revenue: 1000,
  occupancyRate: 50,
  revPAR: 20,
  adr: 40,
  accountsReceivable: 300,
);

const _todayKpis = FinancialKpis(
  revenue: 75,
  occupancyRate: 10,
  revPAR: 5,
  adr: 15,
  accountsReceivable: 300,
);

Future<void> _pump(WidgetTester tester) async {
  tester.view.physicalSize = const Size(800, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        financialMetricsProvider(
          ReportPeriod.month,
        ).overrideWith((ref) async => _monthKpis),
        financialMetricsProvider(
          ReportPeriod.today,
        ).overrideWith((ref) async => _todayKpis),
        revenueBySourceProvider.overrideWith(
          (ref, period) async => const [
            RevenueBySource(label: 'Alojamiento', amount: 700),
            RevenueBySource(label: 'POS Directo', amount: 200),
            RevenueBySource(label: 'Servicios', amount: 80),
            RevenueBySource(label: 'Otros', amount: 20),
          ],
        ),
        openGuestAccountsProvider.overrideWith(
          (ref) => Stream.value(const <GuestAccount>[]),
        ),
      ],
      child: const MaterialApp(home: ReportsScreen()),
    ),
  );
  await tester.pump();
  await tester.pump();
}

void main() {
  testWidgets(
    'muestra ingresos, KPIs secundarios y fuentes del mes (período por defecto)',
    (tester) async {
      await _pump(tester);

      expect(find.text('Mes'), findsOneWidget);
      expect(find.text(r'$1,000.00'), findsOneWidget);
      expect(find.text('50.0%'), findsOneWidget);
      expect(find.text('No hay cuentas abiertas'), findsOneWidget);
    },
  );

  testWidgets('cambiar el período recalcula los KPIs mostrados', (
    tester,
  ) async {
    await _pump(tester);

    expect(find.text(r'$1,000.00'), findsOneWidget);

    await tester.tap(find.text('Hoy'));
    await tester.pump();
    await tester.pump();

    expect(find.text(r'$75.00'), findsOneWidget);
    expect(find.text(r'$1,000.00'), findsNothing);
  });
}
