import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/bookings/bookings_provider.dart';
import '../../application/guest_accounts/guest_account_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../domain/models/booking.dart';
import '../shared/widgets/empty_state_widget.dart';
import '../shared/widgets/error_widget.dart';
import '../shared/widgets/loading_widget.dart';
import '../shared/widgets/offline_banner.dart';
import 'widgets/booking_card.dart';

/// Huéspedes en casa — ver SPEC-011 "Acceso" (una de las 4 entradas a
/// GuestAccountScreen). Reutilizada como pantalla propia (ruta `/in-house`,
/// menú "Más") y embebida como tab "En Casa" dentro de FrontDeskScreen
/// (admin/superadmin) — [embedded] omite el Scaffold/AppBar/gradiente
/// propios cuando ya los provee el contenedor.
class InHouseScreen extends ConsumerStatefulWidget {
  const InHouseScreen({this.embedded = false, super.key});

  final bool embedded;

  @override
  ConsumerState<InHouseScreen> createState() => _InHouseScreenState();
}

class _InHouseScreenState extends ConsumerState<InHouseScreen> {
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

  Future<void> _openAccount(Booking booking) async {
    final account = await ref.read(
      guestAccountByBookingProvider(booking.id).future,
    );
    if (!mounted) return;
    if (account == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se encontró la cuenta de este huésped'),
        ),
      );
      return;
    }
    context.push(AppRoutes.accountDetailPath(account.id));
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
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            'Huéspedes en casa',
            style: TextStyle(color: AppColors.textPrimary),
          ),
        ),
        body: SafeArea(child: _buildContent(context)),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final inHouseAsync = ref.watch(inHouseProvider);

    return Column(
      children: [
        const OfflineBanner(),
        inHouseAsync.maybeWhen(
          data: (bookings) => Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${bookings.length} huéspedes en casa',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          orElse: () => const SizedBox.shrink(),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: TextField(
            controller: _searchController,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Buscar por nombre o habitación',
              hintStyle: const TextStyle(color: AppColors.textTertiary),
              prefixIcon: const Icon(
                Icons.search,
                color: AppColors.textTertiary,
              ),
              filled: true,
              fillColor: AppColors.glassPrimary,
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(999),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        Expanded(
          child: inHouseAsync.when(
            loading: () => const SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: SkeletonList(count: 4, itemHeight: 90),
            ),
            error: (error, stackTrace) => ErrorState(
              message: 'No se pudieron cargar los huéspedes',
              onRetry: () => ref.invalidate(inHouseProvider),
            ),
            data: (bookings) {
              if (bookings.isEmpty) {
                return const EmptyState(
                  icon: Icons.people_outline,
                  title: 'No hay huéspedes en casa',
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
                onRefresh: () async => ref.invalidate(inHouseProvider),
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  itemCount: filtered.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final booking = filtered[index];
                    return BookingCard(
                      booking: booking,
                      onTap: () => _openAccount(booking),
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
