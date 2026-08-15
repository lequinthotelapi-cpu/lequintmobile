import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../domain/models/room.dart';
import '../room_status_display.dart';

/// Tile para la vista lista de RoomsScreen — ver SPEC-008.
class RoomListTile extends StatelessWidget {
  const RoomListTile({required this.room, required this.onTap, super.key});

  final RoomWithStatus room;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final visuals = roomStatusVisuals(room.displayStatus);
    final guestName = room.displayStatus == 'occupied'
        ? room.activeBooking?.guestName
        : null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.glassSecondary,
            border: Border.all(color: AppColors.glassSecondaryBorder),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${room.roomNumber} · Piso ${room.floor}',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${room.roomType} · ${room.capacity} personas',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: visuals.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          guestName != null
                              ? '${visuals.label} — $guestName'
                              : visuals.label,
                          style: TextStyle(
                            color: visuals.color,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textTertiary),
            ],
          ),
        ),
      ),
    );
  }
}
