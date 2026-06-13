import 'package:equatable/equatable.dart';

/// A single tool/activity card.
class ToolItem extends Equatable {
  final String iconAsset;
  final String title;
  final String subtitle;

  const ToolItem({
    required this.iconAsset,
    required this.title,
    required this.subtitle,
  });

  @override
  List<Object?> get props => [iconAsset, title, subtitle];
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
  static const sections = [
    ToolSection(
      emoji: '🌿',
      title: 'Wellness',
      items: [
        ToolItem(
          iconAsset: 'assets/activities/breathing_icon.png',
          title: 'Breathing',
          subtitle: 'Calm your breath',
        ),
        ToolItem(
          iconAsset: 'assets/activities/meditation.png',
          title: 'Meditation',
          subtitle: 'Guided quiet time',
        ),
        ToolItem(
          iconAsset: 'assets/activities/mindfulness_icon.png',
          title: 'Mindfulness',
          subtitle: 'Be present now',
        ),
        ToolItem(
          iconAsset: 'assets/activities/stretch_icon.png',
          title: 'Stretching',
          subtitle: 'Gentle body reset',
        ),
        ToolItem(
          iconAsset: 'assets/activities/gratefulness_icon.png',
          title: 'Gratefulness',
          subtitle: 'Notice the good',
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
        ),
        ToolItem(
          iconAsset: 'assets/activities/mantra_icon.png',
          title: 'Mantra / Affirmation',
          subtitle: 'Repeat kind thoughts',
        ),
      ],
    ),
    ToolSection(
      emoji: '📔',
      title: 'Journaling',
      items: [
        ToolItem(
          iconAsset: 'assets/home/message.png',
          title: 'AI Chat',
          subtitle: 'Talk things through',
        ),
        ToolItem(
          iconAsset: 'assets/activities/journaling_icon.png',
          title: 'Free journaling',
          subtitle: 'Write what you feel',
        ),
      ],
    ),
    ToolSection(
      emoji: '🟣',
      title: 'Therapy',
      items: [
        ToolItem(
          iconAsset: 'assets/activities/emotionalsupport_icon.png',
          title: 'Emotional support',
          subtitle: 'Feel heard',
        ),
        ToolItem(
          iconAsset: 'assets/activities/CBT_icon.png',
          title: 'CBT',
          subtitle: 'Reframe thoughts',
        ),
        ToolItem(
          iconAsset: 'assets/activities/ACT_icon.png',
          title: 'ACT',
          subtitle: 'Accept and commit',
        ),
        ToolItem(
          iconAsset: 'assets/activities/shema_icon.png',
          title: 'Schema',
          subtitle: 'Understand patterns',
        ),
        ToolItem(
          iconAsset: 'assets/activities/trauma_icon.png',
          title: 'Trauma',
          subtitle: 'Gentle healing support',
        ),
      ],
    ),
  ];
}
