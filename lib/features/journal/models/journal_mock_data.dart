import 'dart:ui';

import 'package:equatable/equatable.dart';

import '../../../shared/theme/app_theme.dart';

/// Category of a journal entry — drives the colored chip on each card.
enum JournalCategory { conversation, reflection, win, pattern }

extension JournalCategoryStyle on JournalCategory {
  /// Chip label shown on the entry card.
  String get label => switch (this) {
    JournalCategory.conversation => 'Conversation',
    JournalCategory.reflection => 'Reflection',
    JournalCategory.win => 'Win',
    JournalCategory.pattern => 'Pattern',
  };

  /// Chip background color.
  Color get chipBg => switch (this) {
    JournalCategory.conversation => JournalPalette.chipConversationBg,
    JournalCategory.reflection => JournalPalette.chipReflectionBg,
    JournalCategory.win => JournalPalette.chipWinBg,
    JournalCategory.pattern => JournalPalette.chipPatternBg,
  };

  /// Chip text color.
  Color get chipText => switch (this) {
    JournalCategory.conversation => JournalPalette.chipConversationText,
    JournalCategory.reflection => JournalPalette.chipReflectionText,
    JournalCategory.win => JournalPalette.chipWinText,
    JournalCategory.pattern => JournalPalette.chipPatternText,
  };
}

/// A single journal entry card.
class JournalEntry extends Equatable {
  final String emoji;
  final Color tileColor;
  final String title;
  final String subtitle;
  final String dateLabel;
  final JournalCategory category;

  const JournalEntry({
    required this.emoji,
    required this.tileColor,
    required this.title,
    required this.subtitle,
    required this.dateLabel,
    required this.category,
  });

  @override
  List<Object?> get props => [
    emoji,
    tileColor,
    title,
    subtitle,
    dateLabel,
    category,
  ];
}

/// A small theme tag on the Monthly Insight card.
class JournalInsightTag extends Equatable {
  final String emoji;
  final String label;

  const JournalInsightTag({required this.emoji, required this.label});

  @override
  List<Object?> get props => [emoji, label];
}

/// Hardcoded mock content for the Journal page — simulates backend data.
class JournalMockData {
  // Monthly Insight card.
  static const insightBody =
      'This month, stress and self-pressure showed up often, especially '
      'around work and expectations. You\'re learning to slow down, ask for '
      'help, and protect your energy. Rest is a reward — it\'s part of the '
      'journey.';
  static const insightTags = [
    JournalInsightTag(emoji: '🌧️', label: 'Stress'),
    JournalInsightTag(emoji: '🌀', label: 'Self-pressure'),
    JournalInsightTag(emoji: '❤️', label: 'Rest'),
    JournalInsightTag(emoji: '✨', label: 'Progress'),
  ];

  // Journal entries (most recent first).
  static const entries = [
    JournalEntry(
      emoji: '💬',
      tileColor: HomePalette.tileBlue,
      title: 'Chat summary: finding balance',
      subtitle:
          'You talked about feeling overwhelmed by work and needing more '
          'breathing room.',
      dateLabel: 'Jun 14, 4:21 PM',
      category: JournalCategory.conversation,
    ),
    JournalEntry(
      emoji: '😔',
      tileColor: JournalPalette.tilePink,
      title: 'Reflection: a heavy day',
      subtitle:
          'It was hard to stay motivated, but you reached out and didn\'t '
          'give up.',
      dateLabel: 'Jun 12, 9:05 PM',
      category: JournalCategory.reflection,
    ),
    JournalEntry(
      emoji: '🏆',
      tileColor: JournalPalette.tileAmber,
      title: 'Win: you took a step',
      subtitle:
          'You went for a walk, drank water, and chose to rest. That matters.',
      dateLabel: 'Jun 10, 7:30 PM',
      category: JournalCategory.win,
    ),
    JournalEntry(
      emoji: '🌱',
      tileColor: HomePalette.tileGreen,
      title: 'Pattern: pressure builds up',
      subtitle:
          'Sundays and Mondays tend to feel heavier. Planning ahead might '
          'help.',
      dateLabel: 'Jun 9',
      category: JournalCategory.pattern,
    ),
    JournalEntry(
      emoji: '🌸',
      tileColor: JournalPalette.tilePink,
      title: 'Win: small moments count',
      subtitle:
          'You paused, breathed, and reset. Tiny things make a big difference.',
      dateLabel: 'Jun 8, 6:12 PM',
      category: JournalCategory.win,
    ),
  ];
}
