import 'package:equatable/equatable.dart';

import 'reflection_spec.dart';

/// What a tool card opens when tapped.
enum ToolAction { none, breathing, video, reflection }

/// A single tool/activity card.
class ToolItem extends Equatable {
  /// Stable identifier persisted on a tool-task routine (`Routine.toolKey`) so
  /// the plan can resolve back to this item and re-open its guided session.
  final String key;
  final String iconAsset;
  final String title;
  final String subtitle;

  /// Session opened on tap. [ToolAction.none] (the default) is selection-only.
  final ToolAction action;

  /// Remote video URL — required when [action] is [ToolAction.video].
  final String? videoUrl;

  /// Reflection mission to run — required when [action] is
  /// [ToolAction.reflection].
  final ReflectionSpec? reflectionSpec;

  const ToolItem({
    required this.key,
    required this.iconAsset,
    required this.title,
    required this.subtitle,
    this.action = ToolAction.none,
    this.videoUrl,
    this.reflectionSpec,
  });

  /// True when tapping this tool opens a guided session (vs. plain check-off).
  bool get hasSession => action != ToolAction.none;

  @override
  List<Object?> get props =>
      [key, iconAsset, title, subtitle, action, videoUrl, reflectionSpec];
}

/// A titled group of tool cards (e.g. Wellness).
class ToolSection extends Equatable {
  final String emoji;
  final String title;
  final List<ToolItem> items;

  const ToolSection({
    required this.emoji,
    required this.title,
    required this.items,
  });

  @override
  List<Object?> get props => [emoji, title, items];
}

/// Hardcoded mock content for the tools page — simulates backend data.
class ToolsMockData {
  // Guided-session videos (Firebase Storage download URLs).
  static const _workoutUrl =
      'https://firebasestorage.googleapis.com/v0/b/elevate-2710.firebasestorage.app/o/fullbody_test.mp4?alt=media&token=94b4302a-6067-4162-bcd8-c63d539c9615';
  static const _meditationUrl =
      'https://firebasestorage.googleapis.com/v0/b/elevate-2710.firebasestorage.app/o/meditation_test.mp4?alt=media&token=d9a23deb-cf7b-483b-b2a3-1e68a12e4223';
  static const _stretchUrl =
      'https://firebasestorage.googleapis.com/v0/b/elevate-2710.firebasestorage.app/o/stretch_test.mp4?alt=media&token=cb094d34-cb0d-4962-889f-53286c6e25c5';
  static const _wimHofUrl =
      'https://firebasestorage.googleapis.com/v0/b/elevate-2710.firebasestorage.app/o/wimhoff_test.mp4?alt=media&token=b024b524-7444-4069-a557-6983448d232b';

  static const sections = [
    ToolSection(
      emoji: '🌿',
      title: 'Wellness',
      items: [
        ToolItem(
          key: 'breathing',
          iconAsset: 'assets/activities/breathing_icon.png',
          title: 'Breathing',
          subtitle: 'Calm your breath',
          action: ToolAction.breathing,
        ),
        ToolItem(
          key: 'wimHof',
          iconAsset: 'assets/activities/breathing_icon.png',
          title: 'Wim Hof',
          subtitle: 'Power breathing',
          action: ToolAction.video,
          videoUrl: _wimHofUrl,
        ),
        ToolItem(
          key: 'meditation',
          iconAsset: 'assets/activities/meditation.png',
          title: 'Meditation',
          subtitle: 'Guided quiet time',
          action: ToolAction.video,
          videoUrl: _meditationUrl,
        ),
        ToolItem(
          key: 'stretching',
          iconAsset: 'assets/activities/stretch_icon.png',
          title: 'Stretching',
          subtitle: 'Gentle body reset',
          action: ToolAction.video,
          videoUrl: _stretchUrl,
        ),
        ToolItem(
          key: 'walking',
          iconAsset: 'assets/activities/walking_icon.png',
          title: 'Walking out',
          subtitle: 'Step outside mindfully',
        ),
        ToolItem(
          key: 'sport',
          iconAsset: 'assets/activities/sport_icon.png',
          title: 'Sport',
          subtitle: 'Move with energy',
          action: ToolAction.video,
          videoUrl: _workoutUrl,
        ),
        ToolItem(
          key: 'gratitude',
          iconAsset: 'assets/activities/gratefulness_icon.png',
          title: 'Gratitude',
          subtitle: 'Notice the good',
          action: ToolAction.reflection,
          reflectionSpec: ReflectionSpec.gratitude,
        ),
        ToolItem(
          key: 'selfLove',
          iconAsset: 'assets/activities/emotionalsupport_icon.png',
          title: 'Self-love',
          subtitle: 'Be kind to yourself',
          action: ToolAction.reflection,
          reflectionSpec: ReflectionSpec.selfLove,
        ),
        ToolItem(
          key: 'mindfulness',
          iconAsset: 'assets/activities/mindfulness_icon.png',
          title: 'Mindfulness',
          subtitle: 'Come back to now',
          action: ToolAction.reflection,
          reflectionSpec: ReflectionSpec.mindfulness,
        ),
        ToolItem(
          key: 'running',
          iconAsset: 'assets/activities/walking_icon.png',
          title: 'Running',
          subtitle: 'Go for a run',
        ),
        ToolItem(
          key: 'otherSport',
          iconAsset: 'assets/activities/sport_icon.png',
          title: 'Other sport',
          subtitle: 'Any movement counts',
        ),
      ],
    ),
  ];

  /// Every tool across all sections, flattened.
  static List<ToolItem> get allItems =>
      [for (final s in sections) ...s.items];

  /// Resolves a tool by its stable [ToolItem.key]. Null when unknown.
  static ToolItem? byKey(String key) {
    for (final item in allItems) {
      if (item.key == key) return item;
    }
    return null;
  }
}
