import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/utils/firestore_converters.dart';

enum UserRole {
  superadmin('superadmin'),
  admin('admin'),
  manager('manager'),
  receptionist('receptionist'),
  housekeeper('housekeeper'),
  guest('guest');

  const UserRole(this.value);

  final String value;

  static UserRole fromValue(String? value) => UserRole.values.firstWhere(
    (role) => role.value == value,
    orElse: () => UserRole.guest,
  );
}

class EmergencyContact {
  const EmergencyContact({
    required this.name,
    required this.phone,
    required this.relationship,
  });

  factory EmergencyContact.fromMap(Map<String, dynamic> map) =>
      EmergencyContact(
        name: map['name'] as String? ?? '',
        phone: map['phone'] as String? ?? '',
        relationship: map['relationship'] as String? ?? '',
      );

  final String name;
  final String phone;
  final String relationship;

  Map<String, dynamic> toMap() => {
    'name': name,
    'phone': phone,
    'relationship': relationship,
  };
}

class SessionData {
  const SessionData({
    required this.createdAt,
    required this.lastHeartbeat,
    required this.role,
  });

  factory SessionData.fromMap(Map<String, dynamic> map) => SessionData(
    createdAt: parseTimestamp(map['createdAt']),
    lastHeartbeat: parseTimestamp(map['lastHeartbeat']),
    role: UserRole.fromValue(map['role'] as String?),
  );

  final DateTime createdAt;
  final DateTime lastHeartbeat;
  final UserRole role;

  Map<String, dynamic> toMap() => {
    'createdAt': Timestamp.fromDate(createdAt),
    'lastHeartbeat': Timestamp.fromDate(lastHeartbeat),
    'role': role.value,
  };
}

/// Modelo de usuario administrativo (recepción, housekeeping, gerencia,
/// propietario). Los huéspedes (rol `guest`) están fuera del alcance del MVP.
class User {
  const User({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.document,
    required this.gender,
    required this.role,
    required this.active,
    required this.createdAt,
    this.activeUntil,
    this.avatarUrl,
    this.updatedAt,
    this.maxSessions,
    this.activeSessionsCount,
    this.hasActiveSession,
    this.sessions = const {},
    this.position,
    this.department,
    this.salary,
    this.hireDate,
    this.phone,
    this.emergencyContact,
    this.fcmToken,
  });

  factory User.fromFirestore(DocumentSnapshot doc) =>
      User.fromMap((doc.data() as Map<String, dynamic>?) ?? {}, doc.id);

  factory User.fromMap(Map<String, dynamic> map, String uid) {
    final sessionsMap = map['sessions'] as Map<String, dynamic>?;
    return User(
      uid: uid,
      firstName: map['firstName'] as String? ?? '',
      lastName: map['lastName'] as String? ?? '',
      email: map['email'] as String? ?? '',
      document: map['document'] as String? ?? '',
      gender: map['gender'] as String? ?? '',
      role: UserRole.fromValue(map['role'] as String?),
      active: map['active'] as bool? ?? false,
      createdAt: parseTimestamp(map['createdAt']),
      activeUntil: tryParseTimestamp(map['activeUntil']),
      avatarUrl: map['avatarUrl'] as String?,
      updatedAt: tryParseTimestamp(map['updatedAt']),
      maxSessions: (map['maxSessions'] as num?)?.toInt(),
      activeSessionsCount: (map['activeSessionsCount'] as num?)?.toInt(),
      hasActiveSession: map['hasActiveSession'] as bool?,
      sessions: sessionsMap == null
          ? const {}
          : sessionsMap.map(
              (key, value) => MapEntry(
                key,
                SessionData.fromMap((value as Map<String, dynamic>?) ?? {}),
              ),
            ),
      position: map['position'] as String?,
      department: map['department'] as String?,
      salary: (map['salary'] as num?)?.toDouble(),
      hireDate: tryParseTimestamp(map['hireDate']),
      phone: map['phone'] as String?,
      emergencyContact: map['emergencyContact'] == null
          ? null
          : EmergencyContact.fromMap(
              map['emergencyContact'] as Map<String, dynamic>,
            ),
      fcmToken: map['fcmToken'] as String?,
    );
  }

  final String uid;
  final String firstName;
  final String lastName;
  final String email;
  final String document;
  final String gender;
  final UserRole role;
  final bool active;
  final DateTime createdAt;
  final DateTime? activeUntil;
  final String? avatarUrl;
  final DateTime? updatedAt;
  final int? maxSessions;
  final int? activeSessionsCount;
  final bool? hasActiveSession;
  final Map<String, SessionData> sessions;
  final String? position;
  final String? department;
  final double? salary;
  final DateTime? hireDate;
  final String? phone;
  final EmergencyContact? emergencyContact;
  final String? fcmToken;

  String get fullName => '$firstName $lastName';

  Map<String, dynamic> toFirestore() => {
    'firstName': firstName,
    'lastName': lastName,
    'email': email,
    'document': document,
    'gender': gender,
    'role': role.value,
    'active': active,
    'createdAt': Timestamp.fromDate(createdAt),
    if (activeUntil != null) 'activeUntil': Timestamp.fromDate(activeUntil!),
    if (avatarUrl != null) 'avatarUrl': avatarUrl,
    if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
    if (maxSessions != null) 'maxSessions': maxSessions,
    if (activeSessionsCount != null) 'activeSessionsCount': activeSessionsCount,
    if (hasActiveSession != null) 'hasActiveSession': hasActiveSession,
    if (sessions.isNotEmpty)
      'sessions': sessions.map((key, value) => MapEntry(key, value.toMap())),
    if (position != null) 'position': position,
    if (department != null) 'department': department,
    if (salary != null) 'salary': salary,
    if (hireDate != null) 'hireDate': Timestamp.fromDate(hireDate!),
    if (phone != null) 'phone': phone,
    if (emergencyContact != null) 'emergencyContact': emergencyContact!.toMap(),
    if (fcmToken != null) 'fcmToken': fcmToken,
  };
}
