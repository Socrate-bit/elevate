import 'package:cloud_firestore/cloud_firestore.dart';

import '../../auth/auth_service.dart';
import '../models/routine.dart';

/// Firestore-backed persistence for routines.
/// Path: `users/{uid}/routines/{routineId}`.
class RoutineFirestoreService {
  static CollectionReference<Map<String, dynamic>> _col() =>
      FirebaseFirestore.instance
          .collection('users')
          .doc(AuthService.uid)
          .collection('routines');

  static Future<void> saveRoutine(Routine r) => _col().doc(r.id).set({
        'type': r.type.name,
        'name': r.name,
        'description': r.description,
        'iconKey': r.iconKey,
        'colorKey': r.colorKey,
        'objectCheck': r.objectCheck,
        'scheduledDateMs': r.scheduledDate?.millisecondsSinceEpoch,
        'scheduledDays': r.scheduledDays,
        'scheduledMinute': r.scheduledMinute,
        'hasAlarm': r.hasAlarm,
        'nativeAlarmId': r.nativeAlarmId,
        'createdAtMs': r.createdAt.millisecondsSinceEpoch,
      });

  static Future<void> deleteRoutine(String id) => _col().doc(id).delete();

  static Future<List<Routine>> getRoutines() async {
    final snap = await _col().get();
    return snap.docs.map(_fromDoc).toList();
  }

  static Stream<List<Routine>> watchRoutines() {
    return _col()
        .orderBy('createdAtMs')
        .snapshots()
        .map((snap) => snap.docs.map(_fromDoc).toList());
  }

  static Routine _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    final typeStr = d['type'] as String? ?? 'action';
    return Routine(
      id: doc.id,
      type: typeStr == 'habit' ? RoutineType.habit : RoutineType.action,
      name: d['name'] as String? ?? '',
      description: d['description'] as String?,
      iconKey: d['iconKey'] as String? ?? 'star',
      colorKey: d['colorKey'] as String? ?? 'blue',
      objectCheck: d['objectCheck'] as String?,
      scheduledDate: d['scheduledDateMs'] != null
          ? DateTime.fromMillisecondsSinceEpoch(d['scheduledDateMs'] as int)
          : null,
      scheduledDays: List<bool>.from(
        d['scheduledDays'] as List? ??
            const [false, false, false, false, false, false, false],
      ),
      scheduledMinute: d['scheduledMinute'] as int?,
      hasAlarm: d['hasAlarm'] as bool? ?? false,
      nativeAlarmId: d['nativeAlarmId'] as String?,
      createdAt: d['createdAtMs'] != null
          ? DateTime.fromMillisecondsSinceEpoch(d['createdAtMs'] as int)
          : null,
    );
  }
}
