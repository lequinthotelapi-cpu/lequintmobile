import 'package:flutter/material.dart';

import '../../../application/rooms/rooms_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/models/room.dart';
import '../../rooms/room_status_display.dart';
import '../../shared/widgets/glass_card.dart';

/// Resumen visual de habitaciones por estado — ver SPEC-003 "Estado de
/// habitaciones".
class RoomStatusSummary extends StatelessWidget {
  const RoomStatusSummary({required this.rooms, super.key});

  final List<RoomWithStatus> rooms;

  @override
  Widget build(BuildContext context) {
    final counts = countRoomsByDisplayStatus(rooms);

    return GlassCard.subtle(
      child: Wrap(
        spacing: 16,
        runSpacing: 12,
        children: [
          for (final entry in counts.entries)
            _StatusCount(status: entry.key, count: entry.value),
        ],
      ),
    );
  }
}

class _StatusCount extends StatelessWidget {
  const _StatusCount({required this.status, required this.count});

  final String status;
  final int count;

  @override
  Widget build(BuildContext context) {
    final visuals = roomStatusVisuals(status);
    return SizedBox(
      width: 84,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: visuals.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '$count',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            visuals.label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
