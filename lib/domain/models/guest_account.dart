import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/utils/firestore_converters.dart';

enum GuestAccountStatus {
  open('open'),
  closed('closed');

  const GuestAccountStatus(this.value);

  final String value;

  static GuestAccountStatus fromValue(String? value) =>
      GuestAccountStatus.values.firstWhere(
        (status) => status.value == value,
        orElse: () => GuestAccountStatus.closed,
      );
}

enum ChargeType {
  accommodation('accommodation'),
  pos('pos'),
  service('service'),
  minibar('minibar'),
  laundry('laundry'),
  spa('spa'),
  restaurant('restaurant'),
  other('other');

  const ChargeType(this.value);

  final String value;

  static ChargeType fromValue(String? value) => ChargeType.values.firstWhere(
    (type) => type.value == value,
    orElse: () => ChargeType.other,
  );
}

enum PaymentMethod {
  cash('cash'),
  card('card'),
  transfer('transfer'),
  deposit('deposit');

  const PaymentMethod(this.value);

  final String value;

  static PaymentMethod fromValue(String? value) =>
      PaymentMethod.values.firstWhere(
        (method) => method.value == value,
        orElse: () => PaymentMethod.cash,
      );
}

class Charge {
  const Charge({
    this.id,
    required this.accountId,
    required this.type,
    required this.description,
    required this.amount,
    required this.quantity,
    required this.total,
    required this.date,
    required this.createdBy,
    required this.createdAt,
    this.reference,
  });

  factory Charge.fromMap(Map<String, dynamic> map, {String? id}) => Charge(
    id: id ?? map['id'] as String?,
    accountId: map['accountId'] as String? ?? '',
    type: ChargeType.fromValue(map['type'] as String?),
    description: map['description'] as String? ?? '',
    amount: (map['amount'] as num?)?.toDouble() ?? 0,
    quantity: (map['quantity'] as num?)?.toInt() ?? 1,
    total: (map['total'] as num?)?.toDouble() ?? 0,
    date: parseTimestamp(map['date']),
    createdBy: map['createdBy'] as String? ?? '',
    createdAt: parseTimestamp(map['createdAt']),
    reference: map['reference'] as String?,
  );

  final String? id;
  final String accountId;
  final ChargeType type;
  final String description;
  final double amount;
  final int quantity;
  final double total;
  final DateTime date;
  final String? reference;
  final String createdBy;
  final DateTime createdAt;

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'accountId': accountId,
    'type': type.value,
    'description': description,
    'amount': amount,
    'quantity': quantity,
    'total': total,
    'date': Timestamp.fromDate(date),
    if (reference != null) 'reference': reference,
    'createdBy': createdBy,
    'createdAt': Timestamp.fromDate(createdAt),
  };
}

class Payment {
  const Payment({
    this.id,
    required this.accountId,
    required this.method,
    required this.amount,
    required this.date,
    required this.createdBy,
    required this.createdAt,
    this.reference,
    this.notes,
  });

  factory Payment.fromMap(Map<String, dynamic> map, {String? id}) => Payment(
    id: id ?? map['id'] as String?,
    accountId: map['accountId'] as String? ?? '',
    method: PaymentMethod.fromValue(map['method'] as String?),
    amount: (map['amount'] as num?)?.toDouble() ?? 0,
    date: parseTimestamp(map['date']),
    createdBy: map['createdBy'] as String? ?? '',
    createdAt: parseTimestamp(map['createdAt']),
    reference: map['reference'] as String?,
    notes: map['notes'] as String?,
  );

  final String? id;
  final String accountId;
  final PaymentMethod method;
  final double amount;
  final String? reference;
  final String? notes;
  final DateTime date;
  final String createdBy;
  final DateTime createdAt;

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'accountId': accountId,
    'method': method.value,
    'amount': amount,
    if (reference != null) 'reference': reference,
    if (notes != null) 'notes': notes,
    'date': Timestamp.fromDate(date),
    'createdBy': createdBy,
    'createdAt': Timestamp.fromDate(createdAt),
  };
}

/// Cuenta de huésped: cargos, pagos y saldo.
///
/// El IVA se ignora en el MVP móvil (DECISION-005): la app no calcula
/// impuestos en el cliente, solo transporta el valor de `tax` que ya viene
/// de Firestore. El sistema web sí calcula `tax = subtotal * 0.13`; esa
/// lógica pertenece a un servicio (fuera de este modelo), no se replica aquí.
class GuestAccount {
  const GuestAccount({
    required this.id,
    required this.bookingId,
    required this.bookingNumber,
    required this.guestId,
    required this.guestName,
    required this.roomId,
    required this.roomNumber,
    required this.status,
    required this.checkInDate,
    required this.charges,
    required this.payments,
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.paid,
    required this.balance,
    required this.createdAt,
    required this.createdBy,
    this.checkOutDate,
    this.updatedAt,
    this.updatedBy,
    this.closedAt,
    this.closedBy,
  });

  factory GuestAccount.fromFirestore(DocumentSnapshot doc) =>
      GuestAccount.fromMap((doc.data() as Map<String, dynamic>?) ?? {}, doc.id);

  factory GuestAccount.fromMap(Map<String, dynamic> map, String id) =>
      GuestAccount(
        id: id,
        bookingId: map['bookingId'] as String? ?? '',
        bookingNumber: map['bookingNumber'] as String? ?? '',
        guestId: map['guestId'] as String? ?? '',
        guestName: map['guestName'] as String? ?? '',
        roomId: map['roomId'] as String? ?? '',
        roomNumber: map['roomNumber'] as String? ?? '',
        status: GuestAccountStatus.fromValue(map['status'] as String?),
        checkInDate: parseTimestamp(map['checkInDate']),
        charges:
            (map['charges'] as List<dynamic>?)
                ?.map((e) => Charge.fromMap((e as Map<String, dynamic>?) ?? {}))
                .toList() ??
            const [],
        payments:
            (map['payments'] as List<dynamic>?)
                ?.map(
                  (e) => Payment.fromMap((e as Map<String, dynamic>?) ?? {}),
                )
                .toList() ??
            const [],
        subtotal: (map['subtotal'] as num?)?.toDouble() ?? 0,
        tax: (map['tax'] as num?)?.toDouble() ?? 0,
        total: (map['total'] as num?)?.toDouble() ?? 0,
        paid: (map['paid'] as num?)?.toDouble() ?? 0,
        balance: (map['balance'] as num?)?.toDouble() ?? 0,
        createdAt: parseTimestamp(map['createdAt']),
        createdBy: map['createdBy'] as String? ?? '',
        checkOutDate: tryParseTimestamp(map['checkOutDate']),
        updatedAt: tryParseTimestamp(map['updatedAt']),
        updatedBy: map['updatedBy'] as String?,
        closedAt: tryParseTimestamp(map['closedAt']),
        closedBy: map['closedBy'] as String?,
      );

  final String id;
  final String bookingId;
  final String bookingNumber;
  final String guestId;
  final String guestName;
  final String roomId;
  final String roomNumber;
  final GuestAccountStatus status;
  final DateTime checkInDate;
  final DateTime? checkOutDate;
  final List<Charge> charges;
  final List<Payment> payments;
  final double subtotal;
  final double tax;
  final double total;
  final double paid;
  final double balance;
  final DateTime createdAt;
  final String createdBy;
  final DateTime? updatedAt;
  final String? updatedBy;
  final DateTime? closedAt;
  final String? closedBy;

  Map<String, dynamic> toFirestore() => {
    'bookingId': bookingId,
    'bookingNumber': bookingNumber,
    'guestId': guestId,
    'guestName': guestName,
    'roomId': roomId,
    'roomNumber': roomNumber,
    'status': status.value,
    'checkInDate': Timestamp.fromDate(checkInDate),
    if (checkOutDate != null) 'checkOutDate': Timestamp.fromDate(checkOutDate!),
    'charges': charges.map((c) => c.toMap()).toList(),
    'payments': payments.map((p) => p.toMap()).toList(),
    'subtotal': subtotal,
    'tax': tax,
    'total': total,
    'paid': paid,
    'balance': balance,
    'createdAt': Timestamp.fromDate(createdAt),
    'createdBy': createdBy,
    if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
    if (updatedBy != null) 'updatedBy': updatedBy,
    if (closedAt != null) 'closedAt': Timestamp.fromDate(closedAt!),
    if (closedBy != null) 'closedBy': closedBy,
  };
}
