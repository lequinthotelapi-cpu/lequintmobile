import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/models/sale.dart';
import '../../domain/repositories/sale_repository.dart';
import 'firestore_error_mapper.dart';

/// Implementación Firebase de [SaleRepository] — ver SPEC-010.
class SaleFirebaseRepository implements SaleRepository {
  SaleFirebaseRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Future<List<Sale>> getByDateRange(DateTime start, DateTime end) async {
    try {
      final query = await _firestore
          .collection('sales')
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(end))
          .get();
      return query.docs.map(Sale.fromFirestore).toList();
    } on FirebaseException catch (e) {
      throw mapFirestoreException(e);
    }
  }
}
