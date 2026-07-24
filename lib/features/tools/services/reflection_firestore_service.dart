import 'package:cloud_firestore/cloud_firestore.dart';

import '../../auth/auth_service.dart';
import '../models/reflection_entry.dart';

/// Firestore-backed persistence for reflection entries. Each reflection mission
/// gets its own subcollection under the user, chosen by the [ReflectionSpec].
/// Path: `users/{uid}/{collection}/{entryId}`.
class ReflectionFirestoreService {
  final String collection;

  const ReflectionFirestoreService(this.collection);

  CollectionReference<Map<String, dynamic>> _col() => FirebaseFirestore.instance
      .collection('users')
      .doc(AuthService.uid)
      .collection(collection);

  Future<void> saveEntry(ReflectionEntry entry) =>
      _col().doc(entry.id).set(entry.toMap());

  /// Streams the user's entries, newest first. No screen consumes this yet;
  /// it exists so a future "past reflections" view can read them.
  Stream<List<ReflectionEntry>> watchEntries() {
    return _col().orderBy('createdAtMs', descending: true).snapshots().map(
        (snap) => snap.docs
            .map((d) => ReflectionEntry.fromMap(d.id, d.data()))
            .toList());
  }
}
