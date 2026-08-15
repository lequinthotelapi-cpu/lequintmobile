import 'package:flutter/material.dart';

/// Design tokens de color — ver docs/ux/design-tokens.md.
/// Los colores de estado de habitación y prioridad son idénticos
/// al sistema web (verificados en rooms-grid, room-map-actions-dialog,
/// housekeeping-tasks-list y housekeeping-dashboard).
abstract final class AppColors {
  // Backgrounds
  static const backgroundGradientTop = Color(0xFF0A0F1E);
  static const backgroundGradientBottom = Color(0xFF141B2D);
  static const backgroundSolid = Color(0xFF0D1117);

  // Glass surfaces
  static const glassPrimary = Color(0x1AFFFFFF);
  static const glassPrimaryBorder = Color(0x33FFFFFF);
  static const glassSecondary = Color(0x0DFFFFFF);
  static const glassSecondaryBorder = Color(0x1AFFFFFF);
  static const glassElevated = Color(0x26FFFFFF);
  static const glassElevatedBorder = Color(0x40FFFFFF);

  // Blur
  static const double blurPrimary = 12.0;
  static const double blurElevated = 20.0;
  static const double blurOverlay = 16.0;

  // Texto
  static const textPrimary = Color(0xF2FFFFFF);
  static const textSecondary = Color(0x99FFFFFF);
  static const textTertiary = Color(0x66FFFFFF);
  static const textDisabled = Color(0x33FFFFFF);

  // Acento / Brand
  static const accentPrimary = Color(0xFF3B82F6);
  static const accentPrimaryLight = Color(0xFF60A5FA);
  static const accentSecondary = Color(0xFF06B6D4);

  // Estados de habitación (idénticos al sistema web)
  static const roomAvailable = Color(0xFF10B981);
  static const roomReserved = Color(0xFF8B5CF6);
  static const roomOccupied = Color(0xFFEF4444);
  static const roomDirty = Color(0xFFF59E0B);
  static const roomCleaning = Color(0xFF3B82F6);
  static const roomMaintenance = Color(0xFF6366F1);

  static const roomAvailableBg = Color(0x1A10B981);
  static const roomReservedBg = Color(0x1A8B5CF6);
  static const roomOccupiedBg = Color(0x1AEF4444);
  static const roomDirtyBg = Color(0x1AF59E0B);
  static const roomCleaningBg = Color(0x1A3B82F6);
  static const roomMaintenanceBg = Color(0x1A6366F1);

  // Prioridades de tarea (idénticas al sistema web)
  static const priorityUrgent = Color(0xFFEF4444);
  static const priorityHigh = Color(0xFFF59E0B);
  static const priorityNormal = Color(0xFF3B82F6);
  static const priorityLow = Color(0xFF10B981);

  // Semánticos
  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFEF4444);
  static const info = Color(0xFF3B82F6);

  static const successBg = Color(0x1A10B981);
  static const warningBg = Color(0x1AF59E0B);
  static const errorBg = Color(0x1AEF4444);
  static const infoBg = Color(0x1A3B82F6);
}
