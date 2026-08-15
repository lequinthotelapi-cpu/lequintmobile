import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../shared/widgets/kpi_card.dart';

/// Fila de KPIs operacionales — ver SPEC-003. `occupancy` ya viene
/// formateado (ej. "12/20") porque su origen varía entre pantallas
/// (dashboard usa el conteo en vivo, no un cálculo de período).
class OperationalKpisCard extends StatelessWidget {
  const OperationalKpisCard({
    required this.arrivalsToday,
    required this.departuresToday,
    required this.occupancyLabel,
    required this.openAccountsCount,
    super.key,
  });

  final int arrivalsToday;
  final int departuresToday;
  final String occupancyLabel;
  final int openAccountsCount;

  @override
  Widget build(BuildContext context) {
    return KPIGrid(
      children: [
        KPICard(
          value: '$arrivalsToday',
          label: 'Llegadas hoy',
          icon: Icons.login_outlined,
          color: AppColors.accentPrimary,
        ),
        KPICard(
          value: '$departuresToday',
          label: 'Salidas hoy',
          icon: Icons.logout_outlined,
          color: AppColors.accentPrimary,
        ),
        KPICard(
          value: occupancyLabel,
          label: 'Habitaciones ocupadas',
          icon: Icons.bed_outlined,
          color: AppColors.roomOccupied,
        ),
        KPICard(
          value: '$openAccountsCount',
          label: 'Cuentas abiertas',
          icon: Icons.receipt_long_outlined,
          color: AppColors.warning,
        ),
      ],
    );
  }
}
