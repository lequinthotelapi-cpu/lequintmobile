import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../../infrastructure/firebase/product_firebase_repository.dart';

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductFirebaseRepository();
});

/// Catálogo para AddChargeScreen — ver SPEC-011.
final activeProductsProvider = StreamProvider.autoDispose<List<Product>>((ref) {
  return ref.watch(productRepositoryProvider).getActiveWithStock();
});
