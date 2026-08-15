import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../infrastructure/services/connectivity_service.dart';

/// Banner persistente cuando no hay conexión (DECISION-006) — ver
/// docs/ux/components.md "OfflineBanner". Se anima entrando/saliendo desde
/// arriba según [connectivityProvider].
class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(connectivityProvider).valueOrNull;
    final isOffline = status == ConnectivityStatus.offline;

    return ClipRect(
      child: AnimatedAlign(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        alignment: Alignment.topCenter,
        heightFactor: isOffline ? 1 : 0,
        child: Container(
          height: 36,
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.warningBg,
            border: Border(
              bottom: BorderSide(
                color: AppColors.warning.withValues(alpha: 0.5),
              ),
            ),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.wifi_off, size: 16, color: AppColors.warning),
              SizedBox(width: 8),
              Text(
                'Sin conexión — mostrando datos en caché',
                style: TextStyle(
                  color: AppColors.warning,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
