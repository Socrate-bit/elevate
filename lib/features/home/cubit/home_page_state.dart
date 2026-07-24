import 'package:equatable/equatable.dart';

import '../../routines/models/routine.dart';

/// State of the new illustrated home page's "Today's Plan".
class HomePageState extends Equatable {
  /// Routines relevant today (today's habits + due/undated actions),
  /// ordered by creation time.
  final List<Routine> todayRoutines;

  /// Ids of routines completed today (matched against `Routine.id`).
  final Set<String> completedTodayIds;

  final bool loading;

  const HomePageState({
    this.todayRoutines = const [],
    this.completedTodayIds = const {},
    this.loading = true,
  });

  HomePageState copyWith({
    List<Routine>? todayRoutines,
    Set<String>? completedTodayIds,
    bool? loading,
  }) => HomePageState(
    todayRoutines: todayRoutines ?? this.todayRoutines,
    completedTodayIds: completedTodayIds ?? this.completedTodayIds,
    loading: loading ?? this.loading,
  );

  @override
  List<Object?> get props => [
    todayRoutines,
    completedTodayIds,
    loading,
  ];
}
