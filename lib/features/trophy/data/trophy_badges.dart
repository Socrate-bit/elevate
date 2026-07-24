import 'package:flutter/material.dart';

import '../../routines/models/routine_palette.dart';
import '../models/trophy.dart';

/// Allowed Material icons for a trophy badge, keyed by short strings. The AI
/// picks one key that fits the citation's mood; unknown keys fall back to a
/// safe default so a stray value never crashes the badge.
const Map<String, IconData> kTrophyIcons = {
  'self_improvement': Icons.self_improvement,
  'favorite': Icons.favorite,
  'local_fire_department': Icons.local_fire_department,
  'spa': Icons.spa,
  'wb_sunny': Icons.wb_sunny,
  'nightlight': Icons.nightlight_round,
  'psychology': Icons.psychology,
  'auto_awesome': Icons.auto_awesome,
  'emoji_nature': Icons.emoji_nature,
  'anchor': Icons.anchor,
  'explore': Icons.explore,
  'bolt': Icons.bolt,
  'water_drop': Icons.water_drop,
  'park': Icons.park,
  'menu_book': Icons.menu_book,
  'lightbulb': Icons.lightbulb,
  'star': Icons.star,
  'shield': Icons.shield,
  'healing': Icons.healing,
  'visibility': Icons.visibility,
};

const String kDefaultTrophyIconKey = 'auto_awesome';

/// The set of allowed icon keys, shared with the AI prompt.
final List<String> kTrophyIconKeys = kTrophyIcons.keys.toList();

/// Resolves an icon key to its glyph, defaulting when unknown/empty.
IconData trophyIcon(String key) =>
    kTrophyIcons[key] ?? kTrophyIcons[kDefaultTrophyIconKey]!;

/// Trophy badges reuse the 8 named routine colors (routine_palette.dart).
Color trophyColor(String key) => routineColor(key);

/// Whether a key is a known icon key (for validating AI output).
bool isTrophyIconKey(String key) => kTrophyIcons.containsKey(key);

/// Whether a key is a known color key (for validating AI output).
bool isTrophyColorKey(String key) => kRoutineColors.containsKey(key);

/// Real, correctly-attributed citations used when AI generation fails or the
/// device is offline — guarantees an adventure always yields a trophy. Ids are
/// filled in by [TrophyService] at save time; these are content seeds only.
const List<Trophy> kFallbackCitations = [
  Trophy(
    id: '',
    title: 'Beginning',
    quote: 'The journey of a thousand miles begins with a single step.',
    author: 'Lao Tzu',
    source: 'Tao Te Ching',
    iconKey: 'explore',
    colorKey: 'teal',
    createdAtMs: 0,
  ),
  Trophy(
    id: '',
    title: 'Discipline',
    quote:
        'We are what we repeatedly do. Excellence, then, is not an act, but a habit.',
    author: 'Will Durant',
    source: 'The Story of Philosophy',
    iconKey: 'local_fire_department',
    colorKey: 'orange',
    createdAtMs: 0,
  ),
  Trophy(
    id: '',
    title: 'Perseverance',
    quote: 'The only way out is through.',
    author: 'Robert Frost',
    source: 'A Servant to Servants',
    iconKey: 'bolt',
    colorKey: 'yellow',
    createdAtMs: 0,
  ),
  Trophy(
    id: '',
    title: 'Contentment',
    quote: 'Very little is needed to make a happy life; it is all within yourself.',
    author: 'Marcus Aurelius',
    source: 'Meditations',
    iconKey: 'self_improvement',
    colorKey: 'purple',
    createdAtMs: 0,
  ),
  Trophy(
    id: '',
    title: 'Strength',
    quote: 'What lies behind us and what lies before us are tiny matters compared to what lies within us.',
    author: 'Ralph Waldo Emerson',
    source: '',
    iconKey: 'psychology',
    colorKey: 'blue',
    createdAtMs: 0,
  ),
  Trophy(
    id: '',
    title: 'Opportunity',
    quote: 'In the middle of difficulty lies opportunity.',
    author: 'Albert Einstein',
    source: '',
    iconKey: 'lightbulb',
    colorKey: 'green',
    createdAtMs: 0,
  ),
  Trophy(
    id: '',
    title: 'Purpose',
    quote: 'He who has a why to live can bear almost any how.',
    author: 'Friedrich Nietzsche',
    source: 'Twilight of the Idols',
    iconKey: 'anchor',
    colorKey: 'red',
    createdAtMs: 0,
  ),
  Trophy(
    id: '',
    title: 'Healing',
    quote: 'The wound is the place where the Light enters you.',
    author: 'Rumi',
    source: '',
    iconKey: 'healing',
    colorKey: 'pink',
    createdAtMs: 0,
  ),
];

/// Picks a fallback citation whose "quote — author" isn't in [earned]; falls
/// back to the first when everything has been earned already.
Trophy pickFallbackCitation(Set<String> earned) {
  for (final c in kFallbackCitations) {
    if (!earned.contains('${c.quote} — ${c.author}')) return c;
  }
  return kFallbackCitations.first;
}
