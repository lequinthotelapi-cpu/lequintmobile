import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../domain/models/room.dart';
import '../room_status_display.dart';

/// Tarjeta cuadrada para la vista grid de RoomsScreen — ver SPEC-008,
/// docs/ux/components.md "RoomCard".
class RoomGridCard extends StatelessWidget {
  const RoomGridCard({required this.room, required this.onTap, super.key});

  final RoomWithStatus room;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final visuals = roomStatusVisuals(room.displayStatus);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: visuals.background,
          border: Border.all(color: visuals.color.withValues(alpha: 0.4)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 6,
              right: 8,
              child: Text(
                'P${room.floor}',
                style: const TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 10,
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    room.roomNumber,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    visuals.label,
                    style: TextStyle(
                      color: visuals.color,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
