import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/date_extensions.dart';

/// Encabezado del dashboard: saludo + fecha actual — ver SPEC-003.
///
/// SPEC-003 menciona un "turno" en el encabezado de receptionist, pero no
/// existe un campo `shift`/`turno` en el modelo `User` — se omite en vez
/// de inventar un dato que no está en Firestore.
class DashboardHeader extends StatelessWidget {
  const DashboardHeader({required this.greeting, super.key});

  final String greeting;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          DateTime.now().toShortDateEs(),
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
      ],
    );
  }
}
