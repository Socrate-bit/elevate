import 'package:cloud_firestore/cloud_firestore.dart';

import '../../auth/auth_service.dart';
import '../../subscription/services/analytics_service.dart';
import '../models/activity.dart';

class ActivityService {
  static FirebaseFirestore get _db => FirebaseFirestore.instance;

  static CollectionReference<Map<String, dynamic>> get _activities =>
      _db.collection('users').doc(AuthService.uid).collection('activities');

  static DocumentReference<Map<String, dynamic>> get _profile =>
      _db.collection('users').doc(AuthService.uid).collection('meta').doc('profile');

  /// Creates a pending (not yet completed) activity (e.g. when an alarm fires).
  /// Returns the new activity document ID.
  static Future<String> createPendingActivity({
    required String sourceId,
    String type = 'default',
  }) async {
    final now = DateTime.now();
    final activity = Activity(
      id: '',
      sourceId: sourceId,
      timestamp: now,
      durationSeconds: 0,
      type: type,
      completed: false,
    );
    final docId = now.millisecondsSinceEpoch.toString();
    await _activities.doc(docId).set(activity.toFirestore());
    AnalyticsService.capture(AnalyticsService.alarmRingStarted, {
      'source_id': sourceId,
      'type': type,
    });
    return docId;
  }

  /// Marks a pending activity as completed and records its duration.
  static Future<void> completeActivity(
    String activityId, {
    required int durationSeconds,
  }) async {
    await _activities.doc(activityId).update({
      'completed': true,
      'durationSeconds': durationSeconds,
    });
    await _profile.set(
      {'totalActivities': FieldValue.increment(1)},
      SetOptions(merge: true),
    );
    final props = <String, Object>{
      'duration_seconds': durationSeconds,
      'completed': true,
    };
    AnalyticsService.capture(AnalyticsService.alarmRingDismissed, props);
    AnalyticsService.capture(AnalyticsService.activitySaved, props);
  }

  /// Creates a missed activity (completed: false) for an event that was never resolved.
  static Future<String> createMissedActivity({
    required String sourceId,
    String type = 'default',
    required DateTime timestamp,
  }) async {
    final activity = Activity(
      id: '',
      sourceId: sourceId,
      timestamp: timestamp,
      durationSeconds: 0,
      type: type,
      completed: false,
    );
    final docId = timestamp.millisecondsSinceEpoch.toString();
    await _activities.doc(docId).set(activity.toFirestore());
    AnalyticsService.capture(AnalyticsService.activitySaved, {
      'source_id': sourceId,
      'type': type,
      'completed': false,
    });
    return docId;
  }

  /// Returns up to [limit] activities ordered newest-first.
  /// By default only returns completed activities. Pass [includeIncomplete: true]
  /// to include pending/missed activities.
  static Future<List<Activity>> getActivities({
    int limit = 50,
    DateTime? since,
    bool includeIncomplete = false,
  }) async {
    var query =
        _activities.orderBy('timestamp', descending: true).limit(limit);

    if (since != null) {
      query = query.where(
        'timestamp',
        isGreaterThanOrEqualTo: since.millisecondsSinceEpoch,
      );
    }

    final snap = await query.get();
    final activities = snap.docs
        .map((d) => Activity.fromFirestore(d.id, d.data()))
        .toList();

    if (!includeIncomplete) {
      return activities.where((a) => a.completed).toList();
    }
    return activities;
  }

  /// Returns activities in the current week (Mon–Sun).
  static Future<List<Activity>> getActivitiesThisWeek() async {
    final now = DateTime.now();
    final daysFromMonday = now.weekday - 1;
    final startOfWeek = DateTime(now.year, now.month, now.day - daysFromMonday);
    return getActivities(limit: 100, since: startOfWeek, includeIncomplete: true);
  }

  static Future<List<Activity>> getActivitiesThisMonth() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    return getActivities(limit: 200, since: startOfMonth, includeIncomplete: true);
  }

  static Future<int> getTotalActivities() async {
    final doc = await _profile.get();
    if (!doc.exists) return 0;
    return (doc.data()?['totalActivities'] as int?) ?? 0;
  }

  static Future<Activity?> getLastActivity() async {
    final activities = await getActivities(limit: 1);
    return activities.isEmpty ? null : activities.first;
  }

  /// Returns the most recent pending (incomplete) activity for the given source.
  static Future<Activity?> getPendingActivity(String sourceId) async {
    final snap = await _activities
        .where('sourceId', isEqualTo: sourceId)
        .where('completed', isEqualTo: false)
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    final doc = snap.docs.first;
    return Activity.fromFirestore(doc.id, doc.data());
  }

  /// Real-time stream of completed activities, newest-first.
  static Stream<List<Activity>> watchActivities({int limit = 500}) {
    return _activities
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => Activity.fromFirestore(d.id, d.data()))
            .toList());
  }
}
