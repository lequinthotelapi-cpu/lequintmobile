import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/models/product.dart';
import '../../domain/repositories/product_repository.dart';
import 'firestore_error_mapper.dart';

class ProductFirebaseRepository implements ProductRepository {
  ProductFirebaseRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Stream<List<Product>> getActiveWithStock() {
    final stream = _firestore
        .collection('products')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map(Product.fromFirestore)
              .where((product) => product.currentStock > 0)
              .toList(),
        );
    return mapFirestoreStreamErrors(stream);
  }
}
