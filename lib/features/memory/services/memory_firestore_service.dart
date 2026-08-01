import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../../auth/auth_service.dart';
import '../../chat/services/gemini_service.dart' show EventOp, SummaryOp;
import '../models/life_event.dart';
import '../models/life_rating.dart';
import '../models/memory_builder_state.dart';
import '../models/memory_profile.dart';
import '../models/memory_summary.dart';

/// Repository surface for memory persistence. Cubits/services depend on this so
/// tests can substitute an in-memory implementation.
abstract interface class MemoryRepository {
  // Facts.
  Stream<MemoryProfile> watchProfile();
  Future<MemoryProfile> getProfile();
  Future<void> upsertFacts(Map<String, String> facts);
  Future<void> deleteFacts(List<String> keys);

  // Life events.
  Stream<List<LifeEvent>> watchEvents();
  Future<List<LifeEvent>> getEvents();
  Future<void> applyEventOps(List<EventOp> ops);

  // Rolling summaries.
  Stream<List<MemorySummary>> watchSummaries({int limit});
  Future<List<MemorySummary>> getRecentSummaries({int limit});
  Future<void> applySummaryOps(List<SummaryOp> ops);

  // Life rating.
  Stream<LifeRating> watchLifeRating();
  Future<LifeRating> getLifeRating();
  Future<void> seedLifeRating(Map<String, int> ratings);
  Future<void> updateLifeRating(Map<String, int> ratings);

  // Builder state / watermark.
  Stream<MemoryBuilderState> watchBuilderState();
  Future<MemoryBuilderState> getBuilderState();
  Future<void> writeWatermark(int analyzedUpToMs, double? insightProgress);
  Future<void> writeInsightBoundary(int boundaryMs);

  /// Reads the wheel-of-life ratings captured during onboarding (the seed
  /// source), from `users/{uid}/meta/onboarding.lifeRatings`.
  Future<Map<String, int>> getOnboardingLifeRatings();
}

/// Firestore-backed [MemoryRepository]. Layout, all under `users/{uid}/memory/`:
///   memory/profile         — facts (single doc)
///   memory/events/{id}     — one doc per life event
///   memory/summaries/{id}  — rolling conversation summaries
///   memory/liferating      — life rating (single doc)
///   memory/state           — builder watermark + insight progress (single doc)
class MemoryFirestoreService implements MemoryRepository {
  const MemoryFirestoreService();

  static const MemoryRepository instance = MemoryFirestoreService();

  static const _uuid = Uuid();

  CollectionReference<Map<String, dynamic>> _memory() => FirebaseFirestore
      .instance
      .collection('users')
      .doc(AuthService.uid)
      .collection('memory');

  DocumentReference<Map<String, dynamic>> _profileDoc() =>
      _memory().doc('profile');
  CollectionReference<Map<String, dynamic>> _events() =>
      _memory().doc('events').collection('items');
  CollectionReference<Map<String, dynamic>> _summaries() =>
      _memory().doc('summaries').collection('items');
  DocumentReference<Map<String, dynamic>> _lifeRatingDoc() =>
      _memory().doc('liferating');
  DocumentReference<Map<String, dynamic>> _stateDoc() => _memory().doc('state');

  // --- Facts -----------------------------------------------------------------

  @override
  Stream<MemoryProfile> watchProfile() => _profileDoc().snapshots().map((snap) {
    final data = snap.data();
    return data == null ? MemoryProfile.empty() : MemoryProfile.fromMap(data);
  });

  @override
  Future<MemoryProfile> getProfile() async {
    final snap = await _profileDoc().get();
    final data = snap.data();
    return data == null ? MemoryProfile.empty() : MemoryProfile.fromMap(data);
  }

  @override
  Future<void> upsertFacts(Map<String, String> facts) async {
    if (facts.isEmpty) return;
    await _profileDoc().set({
      'facts': facts,
      'updatedAtMs': DateTime.now().millisecondsSinceEpoch,
    }, SetOptions(merge: true));
  }

  @override
  Future<void> deleteFacts(List<String> keys) async {
    if (keys.isEmpty) return;
    final patch = <String, dynamic>{
      'updatedAtMs': DateTime.now().millisecondsSinceEpoch,
    };
    for (final k in keys) {
      patch['facts.$k'] = FieldValue.delete();
    }
    await _profileDoc().set(patch, SetOptions(merge: true));
  }

  // --- Life events -----------------------------------------------------------

  @override
  Stream<List<LifeEvent>> watchEvents() => _events()
      .orderBy('createdAtMs', descending: true)
      .snapshots()
      .map(
        (snap) =>
            snap.docs.map((d) => LifeEvent.fromMap(d.id, d.data())).toList(),
      );

  @override
  Future<List<LifeEvent>> getEvents() async {
    final snap = await _events().orderBy('createdAtMs', descending: true).get();
    return snap.docs.map((d) => LifeEvent.fromMap(d.id, d.data())).toList();
  }

  @override
  Future<void> applyEventOps(List<EventOp> ops) async {
    if (ops.isEmpty) return;
    final now = DateTime.now();
    final batch = FirebaseFirestore.instance.batch();
    for (final op in ops) {
      switch (op.op) {
        case 'create':
          if (op.title.isEmpty) continue;
          final event = LifeEvent(
            id: _uuid.v4(),
            title: op.title,
            description: op.description,
            occurredAt: op.occurredAt,
            createdAt: now,
            updatedAt: now,
          );
          batch.set(_events().doc(event.id), event.toMap());
        case 'update':
          if (op.id == null) continue;
          final patch = <String, dynamic>{
            'updatedAtMs': now.millisecondsSinceEpoch,
          };
          if (op.title.isNotEmpty) patch['title'] = op.title;
          if (op.description.isNotEmpty) patch['description'] = op.description;
          if (op.occurredAt != null) {
            patch['occurredAtMs'] = op.occurredAt!.millisecondsSinceEpoch;
          }
          batch.set(_events().doc(op.id!), patch, SetOptions(merge: true));
        case 'delete':
          if (op.id == null) continue;
          batch.delete(_events().doc(op.id!));
      }
    }
    await batch.commit();
  }

  // --- Summaries -------------------------------------------------------------

  @override
  Stream<List<MemorySummary>> watchSummaries({int limit = 20}) => _summaries()
      .orderBy('createdAtMs', descending: true)
      .limit(limit)
      .snapshots()
      .map(
        (snap) => snap.docs
            .map((d) => MemorySummary.fromMap(d.id, d.data()))
            .toList(),
      );

  @override
  Future<List<MemorySummary>> getRecentSummaries({int limit = 20}) async {
    final snap = await _summaries()
        .orderBy('createdAtMs', descending: true)
        .limit(limit)
        .get();
    return snap.docs.map((d) => MemorySummary.fromMap(d.id, d.data())).toList();
  }

  @override
  Future<void> applySummaryOps(List<SummaryOp> ops) async {
    if (ops.isEmpty) return;
    final now = DateTime.now();
    final batch = FirebaseFirestore.instance.batch();
    for (final op in ops) {
      switch (op.op) {
        case 'create':
          if (op.text.isEmpty) continue;
          final summary = MemorySummary(
            id: _uuid.v4(),
            text: op.text,
            topic: op.topic,
            startedAt: now,
            createdAt: now,
            updatedAt: now,
          );
          batch.set(_summaries().doc(summary.id), summary.toMap());
        case 'update':
          if (op.id == null) continue;
          final patch = <String, dynamic>{
            'text': op.text,
            'updatedAtMs': now.millisecondsSinceEpoch,
          };
          if (op.topic.isNotEmpty) patch['topic'] = op.topic;
          batch.set(_summaries().doc(op.id!), patch, SetOptions(merge: true));
      }
    }
    await batch.commit();
  }

  // --- Life rating -----------------------------------------------------------

  @override
  Stream<LifeRating> watchLifeRating() => _lifeRatingDoc().snapshots().map((s) {
    final data = s.data();
    return data == null ? LifeRating.empty() : LifeRating.fromMap(data);
  });

  @override
  Future<LifeRating> getLifeRating() async {
    final snap = await _lifeRatingDoc().get();
    final data = snap.data();
    return data == null ? LifeRating.empty() : LifeRating.fromMap(data);
  }

  @override
  Future<void> seedLifeRating(Map<String, int> ratings) async {
    await _lifeRatingDoc().set({
      'ratings': ratings,
      'seeded': true,
      'updatedAtMs': DateTime.now().millisecondsSinceEpoch,
    }, SetOptions(merge: true));
  }

  @override
  Future<void> updateLifeRating(Map<String, int> ratings) async {
    if (ratings.isEmpty) return;
    await _lifeRatingDoc().set({
      'ratings': ratings,
      'seeded': true,
      'updatedAtMs': DateTime.now().millisecondsSinceEpoch,
    }, SetOptions(merge: true));
  }

  // --- Builder state ---------------------------------------------------------

  @override
  Stream<MemoryBuilderState> watchBuilderState() =>
      _stateDoc().snapshots().map((s) {
        final data = s.data();
        return data == null
            ? MemoryBuilderState.initial()
            : MemoryBuilderState.fromMap(data);
      });

  @override
  Future<MemoryBuilderState> getBuilderState() async {
    final snap = await _stateDoc().get();
    final data = snap.data();
    return data == null
        ? MemoryBuilderState.initial()
        : MemoryBuilderState.fromMap(data);
  }

  @override
  Future<void> writeWatermark(int analyzedUpToMs, double? insightProgress) async {
    final patch = <String, dynamic>{
      'analyzedUpToMs': analyzedUpToMs,
      'updatedAtMs': DateTime.now().millisecondsSinceEpoch,
    };
    if (insightProgress != null) patch['insightProgress'] = insightProgress;
    await _stateDoc().set(patch, SetOptions(merge: true));
  }

  @override
  Future<void> writeInsightBoundary(int boundaryMs) async {
    await _stateDoc().set({
      'insightBoundaryMs': boundaryMs,
      'insightProgress': 0.0,
      'updatedAtMs': DateTime.now().millisecondsSinceEpoch,
    }, SetOptions(merge: true));
  }

  @override
  Future<Map<String, int>> getOnboardingLifeRatings() async {
    final snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(AuthService.uid)
        .collection('meta')
        .doc('onboarding')
        .get();
    final raw = snap.data()?['lifeRatings'];
    final out = <String, int>{};
    if (raw is Map) {
      for (final e in raw.entries) {
        final v = e.value;
        if (v is int) {
          out[e.key.toString()] = v;
        } else if (v is num) {
          out[e.key.toString()] = v.toInt();
        }
      }
    }
    return out;
  }
}
