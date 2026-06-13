import 'dart:ui';

import 'package:equatable/equatable.dart';

import '../../../shared/theme/app_theme.dart';

/// A single task row of the "Today's Plan" card.
class HomePlanItem extends Equatable {
  final String emoji;
  final Color tileColor;
  final String title;
  final String subtitle;
  final int xp;
  final bool done;

  const HomePlanItem({
    required this.emoji,
    required this.tileColor,
    required this.title,
    required this.subtitle,
    required this.xp,
    required this.done,
  });

  HomePlanItem copyWith({bool? done}) => HomePlanItem(
    emoji: emoji,
    tileColor: tileColor,
    title: title,
    subtitle: subtitle,
    xp: xp,
    done: done ?? this.done,
  );

  @override
  List<Object?> get props => [emoji, tileColor, title, subtitle, xp, done];
}

/// Hardcoded mock content for the home page — simulates backend data.
class HomeMockData {
  static const userName = 'Lucas';

  // Top bar notification badges.
  static const questsBadge = '!';
  static const shopBadge = '2';
  static const messageBadge = '2';

  // Active quest banner.
  static const questTitle = 'Forest Adventure';
  static const questDone = 0;
  static const questTotal = 15;

  // Today's plan tasks.
  static const planItems = [
    HomePlanItem(
      emoji: '🐹',
      tileColor: HomePalette.tileYellow,
      title: 'Morning Breath',
      subtitle: '5 min mindful breathing',
      xp: 20,
      done: true,
    ),
    HomePlanItem(
      emoji: '💧',
      tileColor: HomePalette.tileBlue,
      title: 'Drink Water',
      subtitle: 'Hydrate your body',
      xp: 15,
      done: true,
    ),
    HomePlanItem(
      emoji: '🌳',
      tileColor: HomePalette.tileGreen,
      title: 'Step Outside',
      subtitle: 'Get fresh air for 10 min',
      xp: 25,
      done: false,
    ),
  ];
}
