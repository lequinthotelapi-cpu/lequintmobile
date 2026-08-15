import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/utils/firestore_converters.dart';

class SaleItem {
  const SaleItem({
    required this.productId,
    required this.productCode,
    required this.productName,
    required this.quantity,
    required this.price,
    required this.subtotal,
  });

  factory SaleItem.fromMap(Map<String, dynamic> map) => SaleItem(
    productId: map['productId'] as String? ?? '',
    productCode: map['productCode'] as String? ?? '',
    productName: map['productName'] as String? ?? '',
    quantity: (map['quantity'] as num?)?.toInt() ?? 0,
    price: (map['price'] as num?)?.toDouble() ?? 0,
    subtotal: (map['subtotal'] as num?)?.toDouble() ?? 0,
  );

  final String productId;
  final String productCode;
  final String productName;
  final int quantity;
  final double price;
  final double subtotal;

  Map<String, dynamic> toMap() => {
    'productId': productId,
    'productCode': productCode,
    'productName': productName,
    'quantity': quantity,
    'price': price,
    'subtotal': subtotal,
  };
}

/// Venta / transacción de POS. Fuera del alcance del MVP móvil (el POS
/// completo no se porta — ver claude-development-guide.md); este modelo se
/// incluye por completitud del dominio compartido con el sistema web.
/// `paymentMethod` se mantiene como `String` libre, igual que en el TS
/// original (no usa el enum `PaymentMethod` estricto de `GuestAccount`).
class Sale {
  const Sale({
    required this.id,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.paymentMethod,
    required this.createdAt,
    required this.createdBy,
    required this.createdByName,
    this.guestId,
    this.guestName,
    this.roomNumber,
    this.cashRegisterId,
  });

  factory Sale.fromFirestore(DocumentSnapshot doc) =>
      Sale.fromMap((doc.data() as Map<String, dynamic>?) ?? {}, doc.id);

  factory Sale.fromMap(Map<String, dynamic> map, String id) => Sale(
    id: id,
    items:
        (map['items'] as List<dynamic>?)
            ?.map((e) => SaleItem.fromMap((e as Map<String, dynamic>?) ?? {}))
            .toList() ??
        const [],
    subtotal: (map['subtotal'] as num?)?.toDouble() ?? 0,
    tax: (map['tax'] as num?)?.toDouble() ?? 0,
    total: (map['total'] as num?)?.toDouble() ?? 0,
    paymentMethod: map['paymentMethod'] as String? ?? '',
    createdAt: parseTimestamp(map['createdAt']),
    createdBy: map['createdBy'] as String? ?? '',
    createdByName: map['createdByName'] as String? ?? '',
    guestId: map['guestId'] as String?,
    guestName: map['guestName'] as String?,
    roomNumber: map['roomNumber'] as String?,
    cashRegisterId: map['cashRegisterId'] as String?,
  );

  final String id;
  final List<SaleItem> items;
  final double subtotal;
  final double tax;
  final double total;
  final String paymentMethod;
  final String? guestId;
  final String? guestName;
  final String? roomNumber;
  final String? cashRegisterId;
  final DateTime createdAt;
  final String createdBy;
  final String createdByName;

  Map<String, dynamic> toFirestore() => {
    'items': items.map((i) => i.toMap()).toList(),
    'subtotal': subtotal,
    'tax': tax,
    'total': total,
    'paymentMethod': paymentMethod,
    if (guestId != null) 'guestId': guestId,
    if (guestName != null) 'guestName': guestName,
    if (roomNumber != null) 'roomNumber': roomNumber,
    if (cashRegisterId != null) 'cashRegisterId': cashRegisterId,
    'createdAt': Timestamp.fromDate(createdAt),
    'createdBy': createdBy,
    'createdByName': createdByName,
  };
}
