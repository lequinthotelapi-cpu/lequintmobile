import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../domain/models/notification.dart';
import 'notification_labels.dart';

/// Banner in-app para mensajes FCM recibidos en foreground — ver SPEC-009
/// ("App en foreground" → banner superior, 4 segundos, tap navega).
///
/// Se implementa con un [OverlayEntry] insertado directamente en el
/// [OverlayState] del `Navigator` raíz (no requiere un widget persistente
/// en el árbol) — ver docs/ux/components.md, sección "Elementos FLEXIBLE"
/// de SPEC-009 (implementación exacta del banner es libre).
void showNotificationBanner(
  OverlayState overlay,
  AppNotification notification, {
  required VoidCallback onTap,
}) {
  late final OverlayEntry entry;
  var removed = false;
  void removeOnce() {
    if (removed) return;
    removed = true;
    entry.remove();
  }

  entry = OverlayEntry(
    builder: (context) => Positioned(
      top: MediaQuery.of(context).padding.top + 8,
      left: 16,
      right: 16,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            removeOnce();
            onTap();
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.glassPrimary,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.glassPrimaryBorder),
              boxShadow: const [
                BoxShadow(color: Colors.black45, blurRadius: 16),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  notification.type.icon,
                  color: AppColors.accentPrimary,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.title,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        notification.message,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );

  overlay.insert(entry);
  Future.delayed(const Duration(seconds: 4), removeOnce);
}
