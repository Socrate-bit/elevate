import 'package:cloud_firestore/cloud_firestore.dart';

import '../../auth/auth_service.dart';
import '../models/gratitude_entry.dart';

/// Firestore-backed persistence for gratitude entries.
/// Path: `users/{uid}/gratitude/{entryId}`.
class GratitudeFirestoreService {
  static CollectionReference<Map<String, dynamic>> _col() =>
      FirebaseFirestore.instance
          .collection('users')
          .doc(AuthService.uid)
          .collection('gratitude');

  static Future<void> saveEntry(GratitudeEntry entry) =>
      _col().doc(entry.id).set(entry.toMap());

  /// Streams the user's entries, newest first. No screen consumes this yet;
  /// it exists so a future "past gratitude" view can read them.
  static Stream<List<GratitudeEntry>> watchEntries() {
    return _col()
        .orderBy('createdAtMs', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => GratitudeEntry.fromMap(d.id, d.data())).toList());
  }
}
