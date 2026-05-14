import 'package:cloud_firestore/cloud_firestore.dart';

import '../../auth/auth_service.dart';
import '../models/life_event.dart';
import '../models/memory_profile.dart';

/// Repository surface for memory persistence. Cubits depend on this so tests
/// can substitute an in-memory implementation.
abstract interface class MemoryRepository {
  Stream<MemoryProfile> watchProfile();
  Stream<List<LifeEvent>> watchLifeEvents();
  Future<MemoryProfile> getProfile();
  Future<List<LifeEvent>> getLifeEventsForConversation(String conversationId);
  Future<void> mergeProfileFacts(Map<String, String> newFacts);
  Future<void> appendLifeEvents(List<LifeEvent> events);
}

/// Firestore-backed [MemoryRepository].
/// Layout:
///   users/{uid}/memory/profile       — accumulating facts (single doc)
///   users/{uid}/lifeEvents/{eventId} — one doc per extracted life event
class MemoryFirestoreService implements MemoryRepository {
  const MemoryFirestoreService();

  static const MemoryRepository instance = MemoryFirestoreService();

  DocumentReference<Map<String, dynamic>> _profileDoc() => FirebaseFirestore
      .instance
      .collection('users')
      .doc(AuthService.uid)
      .collection('memory')
      .doc('profile');

  CollectionReference<Map<String, dynamic>> _lifeEvents() => FirebaseFirestore
      .instance
      .collection('users')
      .doc(AuthService.uid)
      .collection('lifeEvents');

  @override
  Stream<MemoryProfile> watchProfile() {
    return _profileDoc().snapshots().map((snap) {
      final data = snap.data();
      if (data == null) return MemoryProfile.empty();
      return MemoryProfile.fromMap(data);
    });
  }

  @override
  Stream<List<LifeEvent>> watchLifeEvents() {
    return _lifeEvents()
        .orderBy('createdAtMs', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => LifeEvent.fromMap(d.id, d.data()))
              .toList(),
        );
  }

  @override
  Future<MemoryProfile> getProfile() async {
    final snap = await _profileDoc().get();
    final data = snap.data();
    if (data == null) return MemoryProfile.empty();
    return MemoryProfile.fromMap(data);
  }

  @override
  Future<List<LifeEvent>> getLifeEventsForConversation(
    String conversationId,
  ) async {
    final snap = await _lifeEvents()
        .where('sourceConversationId', isEqualTo: conversationId)
        .get();
    return snap.docs.map((d) => LifeEvent.fromMap(d.id, d.data())).toList();
  }

  /// Merges new facts into the profile. Uses Firestore dotted-path updates so
  /// only the touched keys are written; existing keys remain untouched.
  @override
  Future<void> mergeProfileFacts(Map<String, String> newFacts) async {
    if (newFacts.isEmpty) return;
    final patch = <String, dynamic>{
      'updatedAtMs': DateTime.now().millisecondsSinceEpoch,
    };
    for (final entry in newFacts.entries) {
      patch['facts.${entry.key}'] = entry.value;
    }
    await _profileDoc().set(
      {'facts': <String, dynamic>{}, 'updatedAtMs': 0},
      SetOptions(merge: true),
    );
    await _profileDoc().update(patch);
  }

  @override
  Future<void> appendLifeEvents(List<LifeEvent> events) async {
    if (events.isEmpty) return;
    final batch = FirebaseFirestore.instance.batch();
    for (final ev in events) {
      batch.set(_lifeEvents().doc(ev.id), ev.toMap());
    }
    await batch.commit();
  }
}
