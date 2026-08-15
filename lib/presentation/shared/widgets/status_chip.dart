import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../domain/models/room.dart';

/// Chip de estado de habitación — ver docs/ux/components.md "StatusChip".
/// Los colores son IDÉNTICOS al sistema web (design-tokens.md).
class StatusChip extends StatelessWidget {
  const StatusChip({required this.status, super.key});

  final RoomStatus status;

  static Color colorFor(RoomStatus status) => switch (status) {
    RoomStatus.available => AppColors.roomAvailable,
    RoomStatus.occupied => AppColors.roomOccupied,
    RoomStatus.dirty => AppColors.roomDirty,
    RoomStatus.cleaning => AppColors.roomCleaning,
    RoomStatus.maintenance => AppColors.roomMaintenance,
    RoomStatus.blocked => AppColors.error,
  };

  static Color backgroundFor(RoomStatus status) => switch (status) {
    RoomStatus.available => AppColors.roomAvailableBg,
    RoomStatus.occupied => AppColors.roomOccupiedBg,
    RoomStatus.dirty => AppColors.roomDirtyBg,
    RoomStatus.cleaning => AppColors.roomCleaningBg,
    RoomStatus.maintenance => AppColors.roomMaintenanceBg,
    RoomStatus.blocked => AppColors.errorBg,
  };

  static String labelFor(RoomStatus status) => switch (status) {
    RoomStatus.available => 'Disponible',
    RoomStatus.occupied => 'Ocupada',
    RoomStatus.dirty => 'Sucia',
    RoomStatus.cleaning => 'En limpieza',
    RoomStatus.maintenance => 'Mantenimiento',
    RoomStatus.blocked => 'Bloqueada',
  };

  @override
  Widget build(BuildContext context) {
    final color = colorFor(status);

    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: backgroundFor(status),
        border: Border.all(color: color.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            labelFor(status),
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
