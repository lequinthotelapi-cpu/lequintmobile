import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class RoomStatusVisuals {
  const RoomStatusVisuals({
    required this.color,
    required this.background,
    required this.label,
  });

  final Color color;
  final Color background;
  final String label;
}

/// Mapea el `displayStatus` (string — incluye `reserved`, que no es un
/// valor de [RoomStatus]) a color y label — ver SPEC-008 "Colores de
/// estado", IDÉNTICOS al sistema web.
RoomStatusVisuals roomStatusVisuals(String displayStatus) {
  switch (displayStatus) {
    case 'available':
      return const RoomStatusVisuals(
        color: AppColors.roomAvailable,
        background: AppColors.roomAvailableBg,
        label: 'Disponible',
      );
    case 'reserved':
      return const RoomStatusVisuals(
        color: AppColors.roomReserved,
        background: AppColors.roomReservedBg,
        label: 'Reservada',
      );
    case 'occupied':
      return const RoomStatusVisuals(
        color: AppColors.roomOccupied,
        background: AppColors.roomOccupiedBg,
        label: 'Ocupada',
      );
    case 'dirty':
      return const RoomStatusVisuals(
        color: AppColors.roomDirty,
        background: AppColors.roomDirtyBg,
        label: 'Sucia',
      );
    case 'cleaning':
      return const RoomStatusVisuals(
        color: AppColors.roomCleaning,
        background: AppColors.roomCleaningBg,
        label: 'En limpieza',
      );
    case 'maintenance':
      return const RoomStatusVisuals(
        color: AppColors.roomMaintenance,
        background: AppColors.roomMaintenanceBg,
        label: 'Mantenimiento',
      );
    case 'blocked':
      return const RoomStatusVisuals(
        color: AppColors.error,
        background: AppColors.errorBg,
        label: 'Bloqueada',
      );
    default:
      return RoomStatusVisuals(
        color: AppColors.textTertiary,
        background: AppColors.glassSecondary,
        label: displayStatus,
      );
  }
}

/// Filtros disponibles en RoomsScreen — ver SPEC-008.
const roomStatusFilters = [
  'available',
  'occupied',
  'dirty',
  'cleaning',
  'maintenance',
  'reserved',
];
