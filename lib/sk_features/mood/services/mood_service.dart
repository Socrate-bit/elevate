import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../auth/auth_service.dart';
import '../models/mood_entry.dart';

class MoodService {
  static CollectionReference<Map<String, dynamic>> _moods() =>
      FirebaseFirestore.instance
          .collection('users')
          .doc(AuthService.uid)
          .collection('moods');

  /// Persists a new mood entry. The document id is the timestamp in ms.
  static Future<void> saveMood(MoodValue mood) async {
    final now = DateTime.now();
    final id = now.millisecondsSinceEpoch.toString();
    final entry = MoodEntry(id: id, mood: mood, recordedAt: now);
    try {
      await _moods().doc(id).set(entry.toFirestore());
      debugPrint('[MoodService] mood saved: ${mood.name}');
    } catch (e) {
      debugPrint('[MoodService] saveMood failed: $e');
      rethrow;
    }
  }

  /// Streams a map from weekday index (0=Sun) → averaged MoodValue for the
  /// current calendar week (Sunday through Saturday).
  static Stream<Map<int, MoodValue>> watchWeekMoods() {
    final now = DateTime.now();
    final daysFromSunday = now.weekday % 7;
    final startOfWeek = DateTime(now.year, now.month, now.day - daysFromSunday);
    final startMs = startOfWeek.millisecondsSinceEpoch;

    return _moods()
        .where('recordedAt', isGreaterThanOrEqualTo: startMs)
        .snapshots()
        .map((snap) => _groupByDay(snap.docs));
  }

  /// Streams a map from normalized day (DateTime(y,m,d)) → averaged MoodValue
  /// for entries between [start] and [end] (inclusive).
  static Stream<Map<DateTime, MoodValue>> watchMoodsInRange(
    DateTime start,
    DateTime end,
  ) {
    final startMs = start.millisecondsSinceEpoch;
    final endMs = end.millisecondsSinceEpoch;

    return _moods()
        .where('recordedAt', isGreaterThanOrEqualTo: startMs)
        .where('recordedAt', isLessThanOrEqualTo: endMs)
        .snapshots()
        .map((snap) {
      final byDay = <DateTime, List<MoodValue>>{};
      for (final doc in snap.docs) {
        final entry = MoodEntry.fromFirestore(doc.id, doc.data());
        final day = DateTime(
          entry.recordedAt.year,
          entry.recordedAt.month,
          entry.recordedAt.day,
        );
        byDay.putIfAbsent(day, () => []).add(entry.mood);
      }
      return byDay.map((day, moods) => MapEntry(day, averageMood(moods)));
    });
  }

  static Map<int, MoodValue> _groupByDay(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    final byWeekday = <int, List<MoodValue>>{};
    for (final doc in docs) {
      final entry = MoodEntry.fromFirestore(doc.id, doc.data());
      final weekdayIndex = entry.recordedAt.weekday % 7; // 0=Sun
      byWeekday.putIfAbsent(weekdayIndex, () => []).add(entry.mood);
    }
    return byWeekday.map((day, moods) => MapEntry(day, averageMood(moods)));
  }
}
