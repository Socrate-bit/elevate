import 'package:equatable/equatable.dart';

import '../models/mood_entry.dart';

class MoodState extends Equatable {
  /// Mood per weekday index (0=Sun … 6=Sat) for the current week.
  final Map<int, MoodValue> weekMoods;
  final bool isSaving;

  /// True after the first Firestore emission (even if the result is empty).
  final bool isLoaded;

  const MoodState({
    this.weekMoods = const {},
    this.isSaving = false,
    this.isLoaded = false,
  });

  bool get hasMoodToday {
    final todayIndex = DateTime.now().weekday % 7;
    return weekMoods.containsKey(todayIndex);
  }

  MoodState copyWith({
    Map<int, MoodValue>? weekMoods,
    bool? isSaving,
    bool? isLoaded,
  }) =>
      MoodState(
        weekMoods: weekMoods ?? this.weekMoods,
        isSaving: isSaving ?? this.isSaving,
        isLoaded: isLoaded ?? this.isLoaded,
      );

  @override
  List<Object?> get props => [weekMoods, isSaving, isLoaded];
}
