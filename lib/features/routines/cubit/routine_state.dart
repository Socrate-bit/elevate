import 'package:equatable/equatable.dart';

import '../models/routine.dart';

class RoutineState extends Equatable {
  final List<Routine> routines;
  final bool isLoading;

  const RoutineState({this.routines = const [], this.isLoading = false});

  List<Routine> get actions =>
      routines.where((r) => r.type == RoutineType.action).toList();

  List<Routine> get habits =>
      routines.where((r) => r.type == RoutineType.habit).toList();

  RoutineState copyWith({List<Routine>? routines, bool? isLoading}) =>
      RoutineState(
        routines: routines ?? this.routines,
        isLoading: isLoading ?? this.isLoading,
      );

  @override
  List<Object?> get props => [routines, isLoading];
}
