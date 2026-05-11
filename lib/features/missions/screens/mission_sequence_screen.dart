import 'package:flutter/material.dart';

import '../models/mission.dart';
import '../models/mission_config.dart';
import '../widgets/mission_complete_screen.dart';
import 'math_mission_screen.dart';
import 'mission_start_screen.dart';
import 'photo_mission_screen.dart';
import 'pushup_mission_screen.dart';
import 'shake_mission_screen.dart';
import 'speech_mission_screen.dart';
import 'squat_mission_screen.dart';

/// Orchestrates a sequence of up to 3 standalone missions.
///
/// Shows [MissionStartScreen] before each mission, advances through the list,
/// and pushes [MissionCompleteScreen] after the final one.
class MissionSequenceScreen extends StatefulWidget {
  final List<MissionConfig> missions;

  const MissionSequenceScreen({super.key, required this.missions});

  @override
  State<MissionSequenceScreen> createState() => _MissionSequenceScreenState();
}

class _MissionSequenceScreenState extends State<MissionSequenceScreen> {
  int _currentIndex = 0;
  late final List<MissionConfig> _resolvedMissions;
  /// Caches photo-roulette picks so remounts don't reroll.
  final Map<int, String> _photoTargets = {};

  @override
  void initState() {
    super.initState();
    _resolvedMissions = widget.missions.map(_resolveRandom).toList();
  }

  MissionConfig _resolveRandom(MissionConfig config) {
    if (config.type != MissionType.random) return config;
    final pool = (config.randomPool != null && config.randomPool!.isNotEmpty)
        ? config.randomPool!
        : MissionType.values.where((t) => t != MissionType.none && t != MissionType.random).toList();
    final picked = (List<MissionType>.from(pool)..shuffle()).first;
    return config.copyWith(type: picked);
  }

  void _startMission() {
    var config = _resolvedMissions[_currentIndex];
    final cachedTarget = _photoTargets[_currentIndex];
    if (cachedTarget != null) config = config.copyWith(selectedItems: [cachedTarget]);

    final missionIndex = _currentIndex;
    final screen = buildMissionScreen(
      config: config,
      onComplete: _onMissionComplete,
      onPhotoTargetChosen: (target) => _photoTargets[missionIndex] = target,
    );

    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  void _onMissionComplete() {
    if (_currentIndex + 1 < _resolvedMissions.length) {
      Navigator.of(context).pop();
      setState(() => _currentIndex++);
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MissionCompleteScreen()),
        (route) => route.isFirst,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MissionStartScreen(
      currentIndex: _currentIndex,
      totalMissions: _resolvedMissions.length,
      missionType: _resolvedMissions[_currentIndex].type,
      onStart: _startMission,
    );
  }
}

/// Routes a [MissionConfig] to the appropriate standalone mission screen.
/// Public so the picker can launch individual missions in preview mode.
Widget buildMissionScreen({
  required MissionConfig config,
  VoidCallback? onComplete,
  ValueChanged<String>? onPhotoTargetChosen,
  bool isPreview = false,
}) {
  final type = config.type;
  switch (type) {
    case MissionType.pushUps:
      return PushUpMissionScreen(
        repCount: config.repCount ?? 5,
        onComplete: onComplete,
        isPreview: isPreview,
      );
    case MissionType.squats:
      return SquatMissionScreen(
        repCount: config.repCount ?? 10,
        onComplete: onComplete,
        isPreview: isPreview,
      );
    case MissionType.shakePhone:
      return ShakeMissionScreen(
        target: config.repCount ?? 15,
        onComplete: onComplete,
        isPreview: isPreview,
      );
    case MissionType.math:
      return MathMissionScreen(
        difficulty: config.mathDifficulty ?? MathDifficulty.easy,
        problemCount: config.mathProblemCount ?? 3,
        onComplete: onComplete,
        isPreview: isPreview,
      );
    case MissionType.affirmation:
      return SpeechMissionScreen(
        selectedAffirmations: config.selectedAffirmations,
        affirmationCount: config.affirmationCount ?? 1,
        onComplete: onComplete,
        isPreview: isPreview,
      );
    case MissionType.skyPhoto:
    case MissionType.makeBed:
    case MissionType.touchGrass:
    case MissionType.objectHunt:
    case MissionType.petHunt:
    case MissionType.natureHunt:
      return PhotoMissionScreen(
        missionType: type,
        selectedItems: config.selectedItems,
        onComplete: onComplete,
        onTargetChosen: onPhotoTargetChosen,
        isPreview: isPreview,
      );
    case MissionType.none:
    case MissionType.random:
      onComplete?.call();
      return const SizedBox.shrink();
  }
}
