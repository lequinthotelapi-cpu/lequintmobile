import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/utils/firestore_converters.dart';

enum BookingStatus {
  pending('pending'),
  confirmed('confirmed'),
  checkedIn('checked-in'),
  checkedOut('checked-out'),
  cancelled('cancelled'),
  noShow('no-show');

  const BookingStatus(this.value);

  final String value;

  static BookingStatus fromValue(String? value) =>
      BookingStatus.values.firstWhere(
        (status) => status.value == value,
        orElse: () => BookingStatus.pending,
      );
}

class Booking {
  const Booking({
    required this.id,
    required this.bookingNumber,
    required this.guestId,
    required this.guestName,
    required this.guestEmail,
    required this.guestPhone,
    required this.roomId,
    required this.roomNumber,
    required this.roomType,
    required this.checkInDate,
    required this.checkOutDate,
    required this.nights,
    required this.adults,
    required this.children,
    required this.basePrice,
    required this.totalPrice,
    required this.status,
    required this.source,
    required this.createdAt,
    required this.createdBy,
    this.specialRequests,
    this.notes,
    this.updatedAt,
    this.updatedBy,
  });

  factory Booking.fromFirestore(DocumentSnapshot doc) =>
      Booking.fromMap((doc.data() as Map<String, dynamic>?) ?? {}, doc.id);

  factory Booking.fromMap(Map<String, dynamic> map, String id) => Booking(
    id: id,
    bookingNumber: map['bookingNumber'] as String? ?? '',
    guestId: map['guestId'] as String? ?? '',
    guestName: map['guestName'] as String? ?? '',
    guestEmail: map['guestEmail'] as String? ?? '',
    guestPhone: map['guestPhone'] as String? ?? '',
    roomId: map['roomId'] as String? ?? '',
    roomNumber: map['roomNumber'] as String? ?? '',
    roomType: map['roomType'] as String? ?? '',
    checkInDate: parseTimestamp(map['checkInDate']),
    checkOutDate: parseTimestamp(map['checkOutDate']),
    nights: (map['nights'] as num?)?.toInt() ?? 0,
    adults: (map['adults'] as num?)?.toInt() ?? 0,
    children: (map['children'] as num?)?.toInt() ?? 0,
    basePrice: (map['basePrice'] as num?)?.toDouble() ?? 0,
    totalPrice: (map['totalPrice'] as num?)?.toDouble() ?? 0,
    status: BookingStatus.fromValue(map['status'] as String?),
    source: map['source'] as String? ?? '',
    createdAt: parseTimestamp(map['createdAt']),
    createdBy: map['createdBy'] as String? ?? '',
    specialRequests: map['specialRequests'] as String?,
    notes: map['notes'] as String?,
    updatedAt: tryParseTimestamp(map['updatedAt']),
    updatedBy: map['updatedBy'] as String?,
  );

  final String id;
  final String bookingNumber;
  final String guestId;
  final String guestName;
  final String guestEmail;
  final String guestPhone;
  final String roomId;
  final String roomNumber;
  final String roomType;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final int nights;
  final int adults;
  final int children;
  final double basePrice;
  final double totalPrice;
  final BookingStatus status;
  final String source;
  final String? specialRequests;
  final String? notes;
  final DateTime createdAt;
  final String createdBy;
  final DateTime? updatedAt;
  final String? updatedBy;

  Map<String, dynamic> toFirestore() => {
    'bookingNumber': bookingNumber,
    'guestId': guestId,
    'guestName': guestName,
    'guestEmail': guestEmail,
    'guestPhone': guestPhone,
    'roomId': roomId,
    'roomNumber': roomNumber,
    'roomType': roomType,
    'checkInDate': Timestamp.fromDate(checkInDate),
    'checkOutDate': Timestamp.fromDate(checkOutDate),
    'nights': nights,
    'adults': adults,
    'children': children,
    'basePrice': basePrice,
    'totalPrice': totalPrice,
    'status': status.value,
    'source': source,
    if (specialRequests != null) 'specialRequests': specialRequests,
    if (notes != null) 'notes': notes,
    'createdAt': Timestamp.fromDate(createdAt),
    'createdBy': createdBy,
    if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
    if (updatedBy != null) 'updatedBy': updatedBy,
  };
}
