import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/mission.dart';
import '../cubit/pushup_cubit.dart';
import '../widgets/rep_exercise_view.dart';

/// Push-up mission screen: do N push-ups tracked by camera and ML Kit.
class PushUpMissionScreen extends StatelessWidget {
  final int repCount;
  final VoidCallback? onComplete;
  final bool isPreview;

  const PushUpMissionScreen({
    super.key,
    this.repCount = 5,
    this.onComplete,
    this.isPreview = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PushUpCubit(targetReps: repCount)..startSession(),
      child: RepExerciseView<PushUpCubit>(
        target: repCount,
        missionType: MissionType.pushUps,
        onComplete: onComplete,
        isPreview: isPreview,
      ),
    );
  }
}
