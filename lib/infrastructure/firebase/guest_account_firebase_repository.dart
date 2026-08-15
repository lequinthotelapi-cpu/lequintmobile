import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/errors/app_exception.dart';
import '../../domain/models/guest_account.dart';
import '../../domain/models/product.dart';
import '../../domain/repositories/guest_account_repository.dart';
import 'firestore_error_mapper.dart';

/// Implementación Firebase de [GuestAccountRepository] — ver SPEC-011.
class GuestAccountFirebaseRepository implements GuestAccountRepository {
  GuestAccountFirebaseRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Future<GuestAccount?> getById(String accountId) async {
    try {
      final doc = await _firestore
          .collection('guestAccounts')
          .doc(accountId)
          .get();
      if (!doc.exists) return null;
      return GuestAccount.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw mapFirestoreException(e);
    }
  }

  @override
  Future<GuestAccount?> getByBooking(String bookingId) async {
    try {
      final query = await _firestore
          .collection('guestAccounts')
          .where('bookingId', isEqualTo: bookingId)
          .limit(1)
          .get();
      if (query.docs.isEmpty) return null;
      return GuestAccount.fromFirestore(query.docs.first);
    } on FirebaseException catch (e) {
      throw mapFirestoreException(e);
    }
  }

  @override
  Stream<List<GuestAccount>> getOpenAccounts() {
    final stream = _firestore
        .collection('guestAccounts')
        .where('status', isEqualTo: GuestAccountStatus.open.value)
        .snapshots()
        .map((snap) => snap.docs.map(GuestAccount.fromFirestore).toList());
    return mapFirestoreStreamErrors(stream);
  }

  @override
  Future<void> addCharge({
    required String accountId,
    required List<AddChargeItem> items,
    required String userId,
  }) async {
    try {
      if (items.isEmpty) {
        throw const InvalidInputException('Selecciona al menos un producto');
      }

      final accountRef = _firestore.collection('guestAccounts').doc(accountId);
      final accountSnap = await accountRef.get();
      if (!accountSnap.exists) throw const GuestAccountNotFoundException();
      final account = GuestAccount.fromFirestore(accountSnap);
      if (account.status != GuestAccountStatus.open) {
        throw const GuestAccountClosedException();
      }

      final productRefs = {
        for (final item in items)
          item.productId: _firestore.collection('products').doc(item.productId),
      };
      final productSnaps = await Future.wait(
        productRefs.values.map((ref) => ref.get()),
      );
      final productsById = {
        for (final snap in productSnaps)
          if (snap.exists) snap.id: Product.fromFirestore(snap),
      };

      for (final item in items) {
        final product = productsById[item.productId];
        if (product == null || product.currentStock < item.quantity) {
          throw InsufficientStockException(
            'Stock insuficiente para ${item.productName}',
          );
        }
      }

      final now = DateTime.now();
      final chargeAmount = items.fold<double>(
        0,
        (acc, item) => acc + item.subtotal,
      );
      final description =
          'POS: ${items.map((i) => '${i.productName} x${i.quantity}').join(', ')}';

      final newCharge = Charge(
        accountId: accountId,
        type: ChargeType.pos,
        description: description,
        amount: chargeAmount,
        quantity: 1,
        total: chargeAmount,
        date: now,
        createdBy: userId,
        createdAt: now,
      );

      final updatedCharges = [...account.charges, newCharge];
      final subtotal = updatedCharges.fold<double>(
        0,
        (acc, charge) => acc + charge.total,
      );
      // DECISION-005: la app móvil no calcula IVA en el MVP.
      // TODO(mobile): leer el IVA desde el parámetro del sistema cuando
      // se implemente en el sistema web.
      const tax = 0.0;
      final total = subtotal + tax;
      final balance = total - account.paid;

      final batch = _firestore.batch();
      batch.update(accountRef, {
        'charges': updatedCharges.map((c) => c.toMap()).toList(),
        'subtotal': subtotal,
        'tax': tax,
        'total': total,
        'balance': balance,
        'updatedBy': userId,
        'updatedAt': Timestamp.fromDate(now),
      });

      for (final item in items) {
        batch.update(productRefs[item.productId]!, {
          'currentStock': FieldValue.increment(-item.quantity),
          'updatedBy': userId,
          'updatedAt': Timestamp.fromDate(now),
        });
      }

      await batch.commit();
    } on AppException {
      rethrow;
    } on FirebaseException catch (e) {
      throw mapFirestoreException(e);
    }
  }
}
