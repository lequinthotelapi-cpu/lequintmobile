import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../domain/models/user.dart';

/// Paleta usada para derivar el color de fondo de las iniciales — reutiliza
/// tokens de acento/estado ya existentes (no inventa colores nuevos).
const _avatarPalette = [
  AppColors.accentPrimary,
  AppColors.accentSecondary,
  AppColors.roomReserved,
  AppColors.success,
  AppColors.priorityHigh,
];

/// Avatar de usuario — ver docs/ux/components.md "UserAvatar". Muestra la
/// foto si existe; si no, las iniciales sobre un color derivado del nombre.
class UserAvatar extends StatelessWidget {
  const UserAvatar({required this.user, this.size = 40, super.key});

  final User user;
  final double size;

  String get _initials {
    final first = user.firstName.isNotEmpty ? user.firstName[0] : '';
    final last = user.lastName.isNotEmpty ? user.lastName[0] : '';
    final initials = '$first$last'.toUpperCase();
    return initials.isEmpty ? '?' : initials;
  }

  Color get _backgroundColor {
    final hash = user.fullName.hashCode.abs();
    return _avatarPalette[hash % _avatarPalette.length];
  }

  @override
  Widget build(BuildContext context) {
    final avatarUrl = user.avatarUrl;
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      return ClipOval(
        child: CachedNetworkImage(
          imageUrl: avatarUrl,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorWidget: (context, url, error) => _InitialsAvatar(
            initials: _initials,
            size: size,
            color: _backgroundColor,
          ),
        ),
      );
    }
    return _InitialsAvatar(
      initials: _initials,
      size: size,
      color: _backgroundColor,
    );
  }
}

class _InitialsAvatar extends StatelessWidget {
  const _InitialsAvatar({
    required this.initials,
    required this.size,
    required this.color,
  });

  final String initials;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Text(
        initials,
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.4,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
