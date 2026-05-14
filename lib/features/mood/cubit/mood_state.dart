import 'package:equatable/equatable.dart';

import '../models/mood_entry.dart';

class MoodState extends Equatable {
  /// Mood per weekday index (0=Sun … 6=Sat) for the current week.
  final Map<int, MoodValue> weekMoods;
  final bool isSaving;

  const MoodState({
    this.weekMoods = const {},
    this.isSaving = false,
  });

  MoodState copyWith({
    Map<int, MoodValue>? weekMoods,
    bool? isSaving,
  }) =>
      MoodState(
        weekMoods: weekMoods ?? this.weekMoods,
        isSaving: isSaving ?? this.isSaving,
      );

  @override
  List<Object?> get props => [weekMoods, isSaving];
}
