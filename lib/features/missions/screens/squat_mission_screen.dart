import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../levio/missions/models/mission.dart';
import '../cubit/squat_cubit.dart';
import '../widgets/rep_exercise_view.dart';

/// Squat mission screen: do N squats tracked by camera and ML Kit.
class SquatMissionScreen extends StatelessWidget {
  final int repCount;
  final VoidCallback? onComplete;
  final bool isPreview;

  const SquatMissionScreen({
    super.key,
    this.repCount = 10,
    this.onComplete,
    this.isPreview = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SquatCubit(targetReps: repCount)..startSession(),
      child: RepExerciseView<SquatCubit>(
        target: repCount,
        missionType: MissionType.squats,
        onComplete: onComplete,
        isPreview: isPreview,
      ),
    );
  }
}
