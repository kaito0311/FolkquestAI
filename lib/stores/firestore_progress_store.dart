import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:fqa/models/game_snapshot.dart';
import 'package:fqa/stores/progress_store.dart';

class FirestoreProgressStore implements ProgressStore {
  FirestoreProgressStore({required this.uid, FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final String uid;
  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> get _document {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('progress')
        .doc('game');
  }

  @override
  Future<GameSnapshot?> load() async {
    final snapshot = await _document.get();
    final data = snapshot.data();
    if (data == null) return null;
    return GameSnapshot.fromJson(Map<String, Object?>.from(data));
  }

  @override
  Future<void> save(GameSnapshot snapshot) {
    return _document.set({
      ...snapshot.toJson(),
      'schemaVersion': 1,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
