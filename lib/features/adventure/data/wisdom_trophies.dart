import 'dart:math';

/// A trophy earned from a completed adventure: a wise sentence paired with a
/// trophy icon (emoji — no dedicated artwork exists yet).
class WisdomTrophy {
  final String id;
  final String emoji;
  final String sentence;

  const WisdomTrophy({
    required this.id,
    required this.emoji,
    required this.sentence,
  });
}

/// Ten hardcoded wisdom trophies discovered on adventures. (Hardcoded for now;
/// sentences can be localized later.)
const kWisdomTrophies = <WisdomTrophy>[
  WisdomTrophy(
    id: 'w1',
    emoji: '🏆',
    sentence: 'A small step taken every day builds a path no giant leap can.',
  ),
  WisdomTrophy(
    id: 'w2',
    emoji: '🦉',
    sentence: 'Patience is not waiting — it is the strength to keep going quietly.',
  ),
  WisdomTrophy(
    id: 'w3',
    emoji: '🌟',
    sentence: 'You are not behind. You are exactly where your effort has brought you.',
  ),
  WisdomTrophy(
    id: 'w4',
    emoji: '📜',
    sentence: 'The mountain is climbed by those who never stopped moving their feet.',
  ),
  WisdomTrophy(
    id: 'w5',
    emoji: '🥇',
    sentence: 'Consistency turns ordinary days into extraordinary lives.',
  ),
  WisdomTrophy(
    id: 'w6',
    emoji: '🌱',
    sentence: 'Every seed you plant today is shade you will rest in tomorrow.',
  ),
  WisdomTrophy(
    id: 'w7',
    emoji: '🔥',
    sentence: 'Discipline is choosing what you want most over what you want now.',
  ),
  WisdomTrophy(
    id: 'w8',
    emoji: '💎',
    sentence: 'Pressure is what turns coal into diamonds — and effort into character.',
  ),
  WisdomTrophy(
    id: 'w9',
    emoji: '🧭',
    sentence: 'Progress loves direction more than speed. Keep pointing forward.',
  ),
  WisdomTrophy(
    id: 'w10',
    emoji: '🌿',
    sentence: 'Rest is not the opposite of progress — it is part of it.',
  ),
];

final _rng = Random();

/// Picks a random wisdom trophy to award for a completed adventure.
WisdomTrophy pickRandomWisdom() =>
    kWisdomTrophies[_rng.nextInt(kWisdomTrophies.length)];

/// Looks a trophy up by id (falls back to the first).
WisdomTrophy wisdomById(String id) => kWisdomTrophies.firstWhere(
      (w) => w.id == id,
      orElse: () => kWisdomTrophies.first,
    );
