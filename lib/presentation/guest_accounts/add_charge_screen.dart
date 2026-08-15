import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/auth/auth_provider.dart';
import '../../application/guest_accounts/cart_provider.dart';
import '../../application/guest_accounts/guest_account_provider.dart';
import '../../application/products/product_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/errors/app_exception.dart';
import '../../core/extensions/number_extensions.dart';
import '../../domain/models/product.dart';
import '../shared/widgets/empty_state_widget.dart';
import '../shared/widgets/error_widget.dart';
import '../shared/widgets/loading_widget.dart';
import 'confirm_charge_dialog.dart';
import 'widgets/product_catalog_item.dart';

/// Agregar cargo desde el catálogo — ver SPEC-011.
class AddChargeScreen extends ConsumerStatefulWidget {
  const AddChargeScreen({required this.accountId, super.key});

  final String accountId;

  @override
  ConsumerState<AddChargeScreen> createState() => _AddChargeScreenState();
}

class _AddChargeScreenState extends ConsumerState<AddChargeScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  bool _isSubmitting = false;

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

  List<Product> _filtered(List<Product> products) {
    if (_query.isEmpty) return products;
    return products
        .where(
          (p) =>
              p.name.toLowerCase().contains(_query) ||
              p.code.toLowerCase().contains(_query),
        )
        .toList();
  }

  Map<String, List<Product>> _groupByCategory(List<Product> products) {
    final groups = <String, List<Product>>{};
    for (final product in products) {
      groups.putIfAbsent(product.category, () => []).add(product);
    }
    return groups;
  }

  Future<void> _confirmCharge(String guestName, String roomNumber) async {
    final cart = ref.read(cartProvider);
    final userId = ref.read(currentUserProvider)?.uid;
    if (cart.isEmpty || userId == null) return;

    await ConfirmChargeDialog.show(
      context: context,
      items: cart,
      guestName: guestName,
      roomNumber: roomNumber,
      onConfirm: () => _submitCharge(userId),
    );
  }

  Future<void> _submitCharge(String userId) async {
    setState(() => _isSubmitting = true);
    try {
      await ref
          .read(guestAccountRepositoryProvider)
          .addCharge(
            accountId: widget.accountId,
            items: ref.read(cartProvider),
            userId: userId,
          );
      ref
        ..invalidate(guestAccountProvider(widget.accountId))
        ..read(cartProvider.notifier).clear();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Cargo agregado')));
      Navigator.of(context).pop();
    } on AppException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(activeProductsProvider);
    final accountAsync = ref.watch(guestAccountProvider(widget.accountId));
    final cart = ref.watch(cartProvider);

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
            'Agregar Cargo',
            style: TextStyle(color: AppColors.textPrimary),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              accountAsync.maybeWhen(
                data: (account) => account == null
                    ? const SizedBox.shrink()
                    : Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                        child: Text(
                          '${account.guestName} · Hab. ${account.roomNumber}',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ),
                orElse: () => const SizedBox.shrink(),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Buscar producto...',
                    hintStyle: const TextStyle(color: AppColors.textTertiary),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: AppColors.textTertiary,
                    ),
                    filled: true,
                    fillColor: AppColors.glassPrimary,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.glassPrimaryBorder,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: productsAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: SkeletonList(count: 5, itemHeight: 72),
                  ),
                  error: (error, stackTrace) => ErrorState(
                    message: 'No se pudo cargar el catálogo',
                    onRetry: () => ref.invalidate(activeProductsProvider),
                  ),
                  data: (products) {
                    final filtered = _filtered(products);
                    if (products.isEmpty) {
                      return const EmptyState(
                        icon: Icons.inventory_2_outlined,
                        title: 'No hay productos disponibles',
                      );
                    }
                    if (filtered.isEmpty) {
                      return const EmptyState(
                        icon: Icons.search_off,
                        title: 'No se encontraron productos',
                      );
                    }

                    final grouped = _groupByCategory(filtered);
                    final categories = grouped.keys.toList()..sort();

                    return ListView(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                      children: [
                        for (final category in categories) ...[
                          Text(
                            category.toUpperCase(),
                            style: const TextStyle(
                              color: AppColors.textTertiary,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 8),
                          for (final product in grouped[category]!) ...[
                            ProductCatalogItem(
                              product: product,
                              quantity:
                                  cart
                                      .where((i) => i.productId == product.id)
                                      .firstOrNull
                                      ?.quantity ??
                                  0,
                              onIncrement: () => ref
                                  .read(cartProvider.notifier)
                                  .addItem(product),
                              onDecrement: () => ref
                                  .read(cartProvider.notifier)
                                  .updateQuantity(
                                    product.id,
                                    (cart
                                                .where(
                                                  (i) =>
                                                      i.productId == product.id,
                                                )
                                                .firstOrNull
                                                ?.quantity ??
                                            0) -
                                        1,
                                  ),
                            ),
                            const SizedBox(height: 8),
                          ],
                          const SizedBox(height: 12),
                        ],
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: cart.isEmpty
            ? null
            : SafeArea(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: AppColors.glassElevated,
                    border: Border(
                      top: BorderSide(color: AppColors.glassElevatedBorder),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${cart.length} '
                          '${cart.length == 1 ? 'producto' : 'productos'} · '
                          'Total: '
                          '${ref.read(cartProvider.notifier).total.toCurrency()}',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _isSubmitting
                            ? null
                            : () {
                                final account = accountAsync.valueOrNull;
                                if (account == null) return;
                                _confirmCharge(
                                  account.guestName,
                                  account.roomNumber,
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentPrimary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('CONFIRMAR CARGO'),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
