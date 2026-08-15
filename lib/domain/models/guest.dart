import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/utils/firestore_converters.dart';

class Companion {
  const Companion({
    required this.firstName,
    required this.lastName,
    this.relationship,
    this.age,
  });

  factory Companion.fromMap(Map<String, dynamic> map) => Companion(
    firstName: map['firstName'] as String? ?? '',
    lastName: map['lastName'] as String? ?? '',
    relationship: map['relationship'] as String?,
    age: (map['age'] as num?)?.toInt(),
  );

  final String firstName;
  final String lastName;
  final String? relationship;
  final int? age;

  Map<String, dynamic> toMap() => {
    'firstName': firstName,
    'lastName': lastName,
    if (relationship != null) 'relationship': relationship,
    if (age != null) 'age': age,
  };
}

/// Campos básicos del huésped necesarios para el MVP (llegadas, check-in,
/// cuenta de huésped). `documentType`, `guestType` y `status` se mantienen
/// como `String` libre — igual que en el sistema web — porque sus valores
/// permitidos vienen de la colección dinámica `parameters`, no de un enum
/// cerrado.
class Guest {
  const Guest({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.documentType,
    required this.documentNumber,
    required this.guestType,
    required this.status,
    required this.vip,
    required this.createdAt,
    required this.createdBy,
    this.dateOfBirth,
    this.countryOfOrigin,
    this.gender,
    this.alternativePhone,
    this.photoUrl,
    this.address,
    this.city,
    this.country,
    this.companions = const [],
    this.notes,
    this.updatedAt,
    this.updatedBy,
  });

  factory Guest.fromFirestore(DocumentSnapshot doc) =>
      Guest.fromMap((doc.data() as Map<String, dynamic>?) ?? {}, doc.id);

  factory Guest.fromMap(Map<String, dynamic> map, String id) => Guest(
    id: id,
    firstName: map['firstName'] as String? ?? '',
    lastName: map['lastName'] as String? ?? '',
    email: map['email'] as String? ?? '',
    phone: map['phone'] as String? ?? '',
    documentType: map['documentType'] as String? ?? '',
    documentNumber: map['documentNumber'] as String? ?? '',
    guestType: map['guestType'] as String? ?? '',
    status: map['status'] as String? ?? '',
    vip: map['vip'] as bool? ?? false,
    createdAt: parseTimestamp(map['createdAt']),
    createdBy: map['createdBy'] as String? ?? '',
    dateOfBirth: tryParseTimestamp(map['dateOfBirth']),
    countryOfOrigin: map['countryOfOrigin'] as String?,
    gender: map['gender'] as String?,
    alternativePhone: map['alternativePhone'] as String?,
    photoUrl: map['photoUrl'] as String?,
    address: map['address'] as String?,
    city: map['city'] as String?,
    country: map['country'] as String?,
    companions:
        (map['companions'] as List<dynamic>?)
            ?.map((e) => Companion.fromMap((e as Map<String, dynamic>?) ?? {}))
            .toList() ??
        const [],
    notes: map['notes'] as String?,
    updatedAt: tryParseTimestamp(map['updatedAt']),
    updatedBy: map['updatedBy'] as String?,
  );

  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String documentType;
  final String documentNumber;
  final String guestType;
  final String status;
  final bool vip;
  final DateTime? dateOfBirth;
  final String? countryOfOrigin;
  final String? gender;
  final String? alternativePhone;
  final String? photoUrl;
  final String? address;
  final String? city;
  final String? country;
  final List<Companion> companions;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String createdBy;
  final String? updatedBy;

  String get fullName => '$firstName $lastName';

  Map<String, dynamic> toFirestore() => {
    'firstName': firstName,
    'lastName': lastName,
    'email': email,
    'phone': phone,
    'documentType': documentType,
    'documentNumber': documentNumber,
    'guestType': guestType,
    'status': status,
    'vip': vip,
    if (dateOfBirth != null) 'dateOfBirth': Timestamp.fromDate(dateOfBirth!),
    if (countryOfOrigin != null) 'countryOfOrigin': countryOfOrigin,
    if (gender != null) 'gender': gender,
    if (alternativePhone != null) 'alternativePhone': alternativePhone,
    if (photoUrl != null) 'photoUrl': photoUrl,
    if (address != null) 'address': address,
    if (city != null) 'city': city,
    if (country != null) 'country': country,
    if (companions.isNotEmpty)
      'companions': companions.map((c) => c.toMap()).toList(),
    if (notes != null) 'notes': notes,
    'createdAt': Timestamp.fromDate(createdAt),
    'createdBy': createdBy,
    if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
    if (updatedBy != null) 'updatedBy': updatedBy,
  };
}
