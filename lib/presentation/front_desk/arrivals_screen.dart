import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/bookings/bookings_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../core/extensions/date_extensions.dart';
import '../../domain/models/booking.dart';
import '../shared/widgets/empty_state_widget.dart';
import '../shared/widgets/error_widget.dart';
import '../shared/widgets/loading_widget.dart';
import '../shared/widgets/offline_banner.dart';
import 'widgets/booking_card.dart';

/// Llegadas del día — ver SPEC-006. [embedded] omite el Scaffold/SafeArea/
/// gradiente propios cuando ya los provee el contenedor (tab "Llegadas" de
/// FrontDeskScreen) — anidar el Scaffold completo ahí reduce el alto
/// disponible y desborda el skeleton de carga.
class ArrivalsScreen extends ConsumerStatefulWidget {
  const ArrivalsScreen({this.embedded = false, super.key});

  final bool embedded;

  @override
  ConsumerState<ArrivalsScreen> createState() => _ArrivalsScreenState();
}

class _ArrivalsScreenState extends ConsumerState<ArrivalsScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _query = _searchController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Booking> _filtered(List<Booking> bookings) {
    if (_query.isEmpty) return bookings;
    return bookings
        .where(
          (b) =>
              b.guestName.toLowerCase().contains(_query) ||
              b.roomNumber.toLowerCase().contains(_query),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.embedded) return _buildContent(context);

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
        body: SafeArea(child: _buildContent(context)),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final arrivalsAsync = ref.watch(arrivalsProvider);

    return Column(
      children: [
        const OfflineBanner(),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Llegadas de hoy — ${DateTime.now().toShortDateEs()}',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      arrivalsAsync.maybeWhen(
                        data: (bookings) =>
                            '${bookings.length} llegadas pendientes',
                        orElse: () => ' ',
                      ),
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: _SearchField(controller: _searchController),
        ),
        Expanded(
          child: arrivalsAsync.when(
            loading: () => const SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: SkeletonList(count: 4, itemHeight: 90),
            ),
            error: (error, stackTrace) => ErrorState(
              message: 'No se pudieron cargar las llegadas',
              onRetry: () => ref.invalidate(arrivalsProvider),
            ),
            data: (bookings) {
              if (bookings.isEmpty) {
                return const EmptyState(
                  icon: Icons.event_busy,
                  title: 'No hay llegadas programadas para hoy',
                );
              }
              final filtered = _filtered(bookings);
              if (filtered.isEmpty) {
                return const EmptyState(
                  icon: Icons.search_off,
                  title: 'Sin resultados para tu búsqueda',
                );
              }
              return RefreshIndicator(
                onRefresh: () async => ref.invalidate(arrivalsProvider),
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  itemCount: filtered.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final booking = filtered[index];
                    return BookingCard(
                      booking: booking,
                      onTap: () =>
                          context.push(AppRoutes.arrivalDetailPath(booking.id)),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        hintText: 'Buscar por nombre o habitación',
        hintStyle: const TextStyle(color: AppColors.textTertiary),
        prefixIcon: const Icon(Icons.search, color: AppColors.textTertiary),
        filled: true,
        fillColor: AppColors.glassPrimary,
        contentPadding: const EdgeInsets.symmetric(vertical: 0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
