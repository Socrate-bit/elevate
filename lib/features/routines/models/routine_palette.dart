import 'package:flutter/material.dart';

/// Curated emojis offered when picking a routine's tile. Free-form emojis are
/// also allowed (the AI or a future keyboard picker can supply any emoji); this
/// list only powers the built-in picker grid.
const List<String> kRoutineEmojis = [
  '⭐️', '🧘', '💧', '🌳', '🏃', '🚶', '🚴', '☕️',
  '🥗', '📚', '✏️', '🎓', '😴', '☀️', '🍃', '🏋️',
  '🤸', '🎨', '🎵', '🏠', '🧹', '🚿', '🦷', '💊',
  '❤️', '📱', '💼', '🌱', '🐾', '✅', '🙏', '🧠',
];

const String kDefaultRoutineEmoji = '⭐️';

/// 8 named color swatches. Saved by key on each routine; resolved at render
/// time so we can re-tune the palette without migrating data.
const Map<String, Color> kRoutineColors = {
  'orange': Color(0xFFE07B3A),
  'blue': Color(0xFF5B8DEF),
  'green': Color(0xFF3DAD6F),
  'purple': Color(0xFF7B61FF),
  'red': Color(0xFFE05C5C),
  'pink': Color(0xFFCC4DAA),
  'yellow': Color(0xFFE0B83A),
  'teal': Color(0xFF3AB3B0),
};

const String kDefaultRoutineColorKey = 'blue';

Color routineColor(String key) =>
    kRoutineColors[key] ?? kRoutineColors[kDefaultRoutineColorKey]!;
