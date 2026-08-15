import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/utils/firestore_converters.dart';
import 'booking.dart';

/// Estados físicos persistidos en `rooms.status`. El estado `reserved` NO es
/// un valor de este enum — es un estado calculado en pantalla (ver
/// [RoomWithStatus.displayStatus]), igual que en el sistema web.
enum RoomStatus {
  available('available'),
  occupied('occupied'),
  dirty('dirty'),
  cleaning('cleaning'),
  maintenance('maintenance'),
  blocked('blocked');

  const RoomStatus(this.value);

  final String value;

  static RoomStatus fromValue(String? value) => RoomStatus.values.firstWhere(
    (status) => status.value == value,
    orElse: () => RoomStatus.available,
  );
}

class Room {
  const Room({
    required this.id,
    required this.roomNumber,
    required this.floor,
    required this.roomType,
    required this.bedType,
    required this.capacity,
    required this.amenities,
    required this.status,
    required this.isActive,
    required this.basePrice,
    this.assignedHousekeeperId,
    this.currentGuestId,
    this.description,
    this.photoUrl,
    this.notes,
    this.createdAt,
    this.createdBy,
    this.updatedAt,
    this.updatedBy,
  });

  factory Room.fromFirestore(DocumentSnapshot doc) =>
      Room.fromMap((doc.data() as Map<String, dynamic>?) ?? {}, doc.id);

  factory Room.fromMap(Map<String, dynamic> map, String id) => Room(
    id: id,
    roomNumber: map['roomNumber'] as String? ?? '',
    floor: (map['floor'] as num?)?.toInt() ?? 0,
    roomType: map['roomType'] as String? ?? '',
    bedType: map['bedType'] as String? ?? '',
    capacity: (map['capacity'] as num?)?.toInt() ?? 0,
    amenities: (map['amenities'] as List<dynamic>?)?.cast<String>() ?? const [],
    status: RoomStatus.fromValue(map['status'] as String?),
    isActive: map['isActive'] as bool? ?? true,
    basePrice: (map['basePrice'] as num?)?.toDouble() ?? 0,
    assignedHousekeeperId: map['assignedHousekeeperId'] as String?,
    currentGuestId: map['currentGuestId'] as String?,
    description: map['description'] as String?,
    photoUrl: map['photoUrl'] as String?,
    notes: map['notes'] as String?,
    createdAt: tryParseTimestamp(map['createdAt']),
    createdBy: map['createdBy'] as String?,
    updatedAt: tryParseTimestamp(map['updatedAt']),
    updatedBy: map['updatedBy'] as String?,
  );

  final String id;
  final String roomNumber;
  final int floor;
  final String roomType;
  final String bedType;
  final int capacity;
  final List<String> amenities;
  final RoomStatus status;
  final bool isActive;
  final double basePrice;
  final String? assignedHousekeeperId;
  final String? currentGuestId;
  final String? description;
  final String? photoUrl;
  final String? notes;
  final DateTime? createdAt;
  final String? createdBy;
  final DateTime? updatedAt;
  final String? updatedBy;

  Map<String, dynamic> toFirestore() => {
    'roomNumber': roomNumber,
    'floor': floor,
    'roomType': roomType,
    'bedType': bedType,
    'capacity': capacity,
    'amenities': amenities,
    'status': status.value,
    'isActive': isActive,
    'basePrice': basePrice,
    if (assignedHousekeeperId != null)
      'assignedHousekeeperId': assignedHousekeeperId,
    if (currentGuestId != null) 'currentGuestId': currentGuestId,
    if (description != null) 'description': description,
    if (photoUrl != null) 'photoUrl': photoUrl,
    if (notes != null) 'notes': notes,
    if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
    if (createdBy != null) 'createdBy': createdBy,
    if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
    if (updatedBy != null) 'updatedBy': updatedBy,
  };
}

/// [Room] con el estado calculado para mostrar en pantalla: igual a
/// [Room.status] salvo cuando la habitación está `available` y tiene una
/// reserva activa con check-in hoy, en cuyo caso se muestra `reserved`.
/// El cálculo en sí vive en la capa de repositorio/aplicación (TASK-003),
/// no en este modelo.
class RoomWithStatus extends Room {
  const RoomWithStatus({
    required super.id,
    required super.roomNumber,
    required super.floor,
    required super.roomType,
    required super.bedType,
    required super.capacity,
    required super.amenities,
    required super.status,
    required super.isActive,
    required super.basePrice,
    required this.displayStatus,
    super.assignedHousekeeperId,
    super.currentGuestId,
    super.description,
    super.photoUrl,
    super.notes,
    super.createdAt,
    super.createdBy,
    super.updatedAt,
    super.updatedBy,
    this.activeBooking,
  });

  factory RoomWithStatus.fromRoom(
    Room room, {
    required String displayStatus,
    Booking? activeBooking,
  }) => RoomWithStatus(
    id: room.id,
    roomNumber: room.roomNumber,
    floor: room.floor,
    roomType: room.roomType,
    bedType: room.bedType,
    capacity: room.capacity,
    amenities: room.amenities,
    status: room.status,
    isActive: room.isActive,
    basePrice: room.basePrice,
    displayStatus: displayStatus,
    assignedHousekeeperId: room.assignedHousekeeperId,
    currentGuestId: room.currentGuestId,
    description: room.description,
    photoUrl: room.photoUrl,
    notes: room.notes,
    createdAt: room.createdAt,
    createdBy: room.createdBy,
    updatedAt: room.updatedAt,
    updatedBy: room.updatedBy,
    activeBooking: activeBooking,
  );

  final String displayStatus;
  final Booking? activeBooking;
}
