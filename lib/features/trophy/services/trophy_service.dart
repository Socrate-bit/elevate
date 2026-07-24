import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../auth/auth_service.dart';
import '../models/trophy.dart';

/// Firestore-backed store for earned trophies. Static; lives at
/// `users/{uid}/trophies`.
class TrophyService {
  static FirebaseFirestore get _db => FirebaseFirestore.instance;

  static CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('users').doc(AuthService.uid).collection('trophies');

  static CollectionReference<Map<String, dynamic>> get _conversations =>
      _db.collection('users').doc(AuthService.uid).collection('conversations');

  /// Real-time stream of the user's trophies, newest first.
  static Stream<List<Trophy>> watchTrophies() {
    return _col
        .orderBy('createdAtMs', descending: true)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((d) => Trophy.fromMap(d.id, d.data())).toList(),
        );
  }

  /// One-shot read of all trophies — used to build the de-dup avoid list.
  static Future<List<Trophy>> getTrophies() async {
    try {
      final snap = await _col.orderBy('createdAtMs', descending: true).get();
      return snap.docs.map((d) => Trophy.fromMap(d.id, d.data())).toList();
    } catch (e) {
      debugPrint('[TrophyService] getTrophies failed: $e');
      return const [];
    }
  }

  /// Allocates a fresh document id (so the trophy can be persisted and its id
  /// recorded on the game profile in one flow).
  static String newId() => _col.doc().id;

  /// Persists an earned trophy.
  static Future<void> add(Trophy trophy) async {
    try {
      await _col.doc(trophy.id).set(trophy.toMap());
      debugPrint('[TrophyService] trophy saved: ${trophy.id}');
    } catch (e) {
      debugPrint('[TrophyService] add failed: $e');
      rethrow;
    }
  }

  /// Builds a themes blob from the user's most recent conversation summaries so
  /// the citation can be personalized. Empty when there's no history.
  static Future<String> recentContext({int limit = 5}) async {
    try {
      final snap = await _conversations
          .orderBy('lastMessageAtMs', descending: true)
          .limit(limit)
          .get();
      final summaries = snap.docs
          .map((d) => (d.data()['summary'] as String?)?.trim() ?? '')
          .where((s) => s.isNotEmpty)
          .toList();
      return summaries.join('\n');
    } catch (e) {
      debugPrint('[TrophyService] recentContext failed: $e');
      return '';
    }
  }
}
