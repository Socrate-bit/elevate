import 'package:equatable/equatable.dart';

/// What a tool card opens when tapped.
enum ToolAction { none, breathing, video }

/// A single tool/activity card.
class ToolItem extends Equatable {
  final String iconAsset;
  final String title;
  final String subtitle;

  /// Session opened on tap. [ToolAction.none] (the default) is selection-only.
  final ToolAction action;

  /// Remote video URL — required when [action] is [ToolAction.video].
  final String? videoUrl;

  const ToolItem({
    required this.iconAsset,
    required this.title,
    required this.subtitle,
    this.action = ToolAction.none,
    this.videoUrl,
  });

  @override
  List<Object?> get props => [iconAsset, title, subtitle, action, videoUrl];
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
          iconAsset: 'assets/activities/breathing_icon.png',
          title: 'Breathing',
          subtitle: 'Calm your breath',
          action: ToolAction.breathing,
        ),
        ToolItem(
          iconAsset: 'assets/activities/breathing_icon.png',
          title: 'Wim Hof',
          subtitle: 'Power breathing',
          action: ToolAction.video,
          videoUrl: _wimHofUrl,
        ),
        ToolItem(
          iconAsset: 'assets/activities/meditation.png',
          title: 'Meditation',
          subtitle: 'Guided quiet time',
          action: ToolAction.video,
          videoUrl: _meditationUrl,
        ),
        ToolItem(
          iconAsset: 'assets/activities/stretch_icon.png',
          title: 'Stretching',
          subtitle: 'Gentle body reset',
          action: ToolAction.video,
          videoUrl: _stretchUrl,
        ),
        ToolItem(
          iconAsset: 'assets/activities/walking_icon.png',
          title: 'Walking out',
          subtitle: 'Step outside mindfully',
        ),
        ToolItem(
          iconAsset: 'assets/activities/sport_icon.png',
          title: 'Sport',
          subtitle: 'Move with energy',
          action: ToolAction.video,
          videoUrl: _workoutUrl,
        ),
      ],
    ),
  ];
}
