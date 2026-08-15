import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/guest_accounts/guest_account_provider.dart';
import '../../application/reports/financial_dashboard_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../core/extensions/number_extensions.dart';
import '../shared/async_utils.dart';
import '../shared/widgets/empty_state_widget.dart';
import '../shared/widgets/error_widget.dart';
import '../shared/widgets/loading_widget.dart';
import '../shared/widgets/offline_banner.dart';
import '../shared/widgets/kpi_card.dart';
import 'widgets/open_accounts_list.dart';
import 'widgets/period_selector_chips.dart';
import 'widgets/revenue_by_source_bars.dart';

/// Dashboard financiero — ver SPEC-010. Solo manager/admin/superadmin
/// (protegido en el router — ver app_router.dart).
class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(selectedPeriodProvider);
    final kpisAsync = ref.watch(financialMetricsProvider(period));
    final sourcesAsync = ref.watch(revenueBySourceProvider(period));
    final openAccountsAsync = ref.watch(openGuestAccountsProvider);

    final loading = anyLoading([kpisAsync, sourcesAsync, openAccountsAsync]);
    final error = firstError([kpisAsync, sourcesAsync, openAccountsAsync]);

    void refresh() {
      ref
        ..invalidate(financialMetricsProvider(period))
        ..invalidate(revenueBySourceProvider(period))
        ..invalidate(openGuestAccountsProvider);
    }

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.backgroundGradientTop,
            AppColors.backgroundGradientBottom,
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            'Reportes Financieros',
            style: TextStyle(color: AppColors.textPrimary),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              const OfflineBanner(),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: PeriodSelectorChips(
                  selected: period,
                  onChanged: (value) =>
                      ref.read(selectedPeriodProvider.notifier).state = value,
                ),
              ),
              Expanded(
                child: Builder(
                  builder: (context) {
                    if (loading) {
                      return const Padding(
                        padding: EdgeInsets.all(20),
                        child: SkeletonList(count: 3, itemHeight: 120),
                      );
                    }
                    if (error != null) {
                      return ErrorState(
                        message: 'No se pudieron calcular los reportes',
                        onRetry: refresh,
                      );
                    }

                    final kpis = kpisAsync.value!;
                    final sources = sourcesAsync.value!;
                    final openAccounts = topOpenAccountsByBalance(
                      openAccountsAsync.value!,
                    );

                    return RefreshIndicator(
                      onRefresh: () async => refresh(),
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                        children: [
                          const Text(
                            'INGRESOS',
                            style: TextStyle(
                              color: AppColors.textTertiary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            kpis.revenue.toCurrency(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 36,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 24),
                          KPIGrid(
                            children: [
                              KPICard(
                                value:
                                    '${kpis.occupancyRate.toStringAsFixed(1)}%',
                                label: 'Ocupación',
                              ),
                              KPICard(
                                value: kpis.revPAR.toCurrency(),
                                label: 'RevPAR',
                              ),
                              KPICard(
                                value: kpis.adr.toCurrency(),
                                label: 'ADR',
                              ),
                              KPICard(
                                value: kpis.accountsReceivable.toCurrency(),
                                label: 'Por cobrar',
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'INGRESOS POR FUENTE',
                            style: TextStyle(
                              color: AppColors.textTertiary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          RevenueBySourceBars(sources: sources),
                          const SizedBox(height: 24),
                          const Text(
                            'CUENTAS ABIERTAS (POR COBRAR)',
                            style: TextStyle(
                              color: AppColors.textTertiary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (openAccounts.isEmpty)
                            const EmptyState(
                              icon: Icons.check_circle_outline,
                              title: 'No hay cuentas abiertas',
                            )
                          else
                            OpenAccountsList(
                              accounts: openAccounts,
                              onTap: (account) => context.push(
                                AppRoutes.accountDetailPath(account.id),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
