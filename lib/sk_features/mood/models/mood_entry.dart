import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart' show Color;

/// The five mood options a user can select.
enum MoodValue { rad, good, meh, bad, awful }

extension MoodValueX on MoodValue {
  String get emoji => const ['😎', '🙂', '😐', '😠', '😢'][index];

  Color get color => [
        const Color(0xFF4ECDC4),
        const Color(0xFF95C261),
        const Color(0xFF7EB8D4),
        const Color(0xFFE8924B),
        const Color(0xFFE05B6E),
      ][index];

  static MoodValue? fromName(String? name) {
    if (name == null) return null;
    try {
      return MoodValue.values.firstWhere((m) => m.name == name);
    } catch (_) {
      return null;
    }
  }
}

/// Average a non-empty list of moods, rounding to the nearest value.
MoodValue averageMood(List<MoodValue> moods) {
  assert(moods.isNotEmpty);
  final sum = moods.fold(0, (acc, m) => acc + m.index);
  final rounded = (sum / moods.length).round().clamp(0, 4);
  return MoodValue.values[rounded];
}

/// A single mood log entry stored in Firestore.
class MoodEntry extends Equatable {
  final String id;
  final MoodValue mood;
  final DateTime recordedAt;

  const MoodEntry({
    required this.id,
    required this.mood,
    required this.recordedAt,
  });

  Map<String, dynamic> toFirestore() => {
        'mood': mood.name,
        'recordedAt': recordedAt.millisecondsSinceEpoch,
      };

  factory MoodEntry.fromFirestore(String id, Map<String, dynamic> data) {
    return MoodEntry(
      id: id,
      mood: MoodValueX.fromName(data['mood'] as String?) ?? MoodValue.meh,
      recordedAt: DateTime.fromMillisecondsSinceEpoch(
        (data['recordedAt'] as int?) ?? 0,
      ),
    );
  }

  @override
  List<Object?> get props => [id, mood, recordedAt];
}
