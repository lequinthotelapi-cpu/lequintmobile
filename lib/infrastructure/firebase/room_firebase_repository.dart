import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/models/room.dart';
import '../../domain/repositories/room_repository.dart';
import 'firestore_error_mapper.dart';

class RoomFirebaseRepository implements RoomRepository {
  RoomFirebaseRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Stream<List<Room>> getAll() {
    final stream = _firestore
        .collection('rooms')
        .snapshots()
        .map((snap) => snap.docs.map(Room.fromFirestore).toList());
    return mapFirestoreStreamErrors(stream);
  }
}
