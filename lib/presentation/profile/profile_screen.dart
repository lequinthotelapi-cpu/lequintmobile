import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/auth/auth_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/models/user.dart';
import '../shared/widgets/confirm_dialog.dart';
import '../shared/widgets/empty_state_widget.dart';
import '../shared/widgets/user_avatar.dart';
import 'profile_labels.dart';

/// Perfil del usuario y cierre de sesión — ver SPEC-012.
///
/// No incluye la sección "SESIÓN" (dispositivo, fecha de inicio): el
/// modelo `User`/`SessionData` no tiene nombre de dispositivo, y SPEC-012
/// marca esa sección como FLEXIBLE ("puede omitirse si no agrega valor")
/// — se omite en vez de fabricar un dato que no existe en Firestore.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    await ConfirmDialog.show(
      context: context,
      title: '¿Cerrar sesión?',
      message: 'Se cerrará tu sesión en este dispositivo.',
      confirmLabel: 'Cerrar Sesión',
      confirmColor: AppColors.error,
      onConfirm: () => ref.read(authNotifierProvider.notifier).signOut(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.backgroundGradientTop,
            AppColors.backgroundGradientBottom,
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            'Mi Perfil',
            style: TextStyle(color: AppColors.textPrimary),
          ),
        ),
        body: SafeArea(
          child: user == null
              ? const EmptyState(
                  icon: Icons.person_off_outlined,
                  title: 'No se pudieron cargar tus datos',
                )
              : _ProfileBody(user: user, onLogout: () => _logout(context, ref)),
        ),
      ),
    );
  }
}

class _ProfileBody extends StatelessWidget {
  const _ProfileBody({required this.user, required this.onLogout});

  final User user;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final info = <(String, String)>[
      ('Email', user.email),
      ('Documento', user.document),
      if (user.phone != null && user.phone!.isNotEmpty)
        ('Teléfono', user.phone!),
      if (user.position != null && user.position!.isNotEmpty)
        ('Cargo', user.position!),
      if (user.department != null && user.department!.isNotEmpty)
        ('Departamento', user.department!),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      children: [
        Center(
          child: Column(
            children: [
              UserAvatar(user: user, size: 64),
              const SizedBox(height: 12),
              Text(
                user.fullName,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                translateRole(user.role),
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        const _SectionTitle('INFORMACIÓN'),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.glassPrimary,
            border: Border.all(color: AppColors.glassPrimaryBorder),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              for (final (label, value) in info) _InfoRow(label, value),
            ],
          ),
        ),
        const SizedBox(height: 28),
        SizedBox(
          height: 52,
          child: ElevatedButton.icon(
            onPressed: onLogout,
            icon: const Icon(Icons.logout),
            label: const Text('Cerrar Sesión'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorBg,
              foregroundColor: AppColors.error,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: AppColors.error.withValues(alpha: 0.5)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: AppColors.textTertiary,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.textTertiary, fontSize: 13),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
