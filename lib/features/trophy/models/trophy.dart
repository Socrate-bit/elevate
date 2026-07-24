import 'package:equatable/equatable.dart';

/// An earned trophy: a real citation from a figure or book, themed to the
/// user's recent reflections, paired with a colored hexagonal badge (a Material
/// [iconKey] over a [colorKey]). Persisted at `users/{uid}/trophies/{id}`.
class Trophy extends Equatable {
  final String id;

  /// The verbatim citation.
  final String quote;

  /// The figure or author the citation is attributed to.
  final String author;

  /// The originating book/work, or empty when it's a standalone saying.
  final String source;

  /// Key into `kTrophyIcons` (trophy_badges.dart) — the badge glyph.
  final String iconKey;

  /// Key into `kRoutineColors` (routine_palette.dart) — the badge color.
  final String colorKey;

  /// Conversation that inspired this citation, or null for a general one.
  final String? conversationId;

  final int createdAtMs;

  const Trophy({
    required this.id,
    required this.quote,
    required this.author,
    this.source = '',
    required this.iconKey,
    required this.colorKey,
    this.conversationId,
    required this.createdAtMs,
  });

  DateTime get createdAt => DateTime.fromMillisecondsSinceEpoch(createdAtMs);

  Map<String, dynamic> toMap() => {
    'quote': quote,
    'author': author,
    'source': source,
    'iconKey': iconKey,
    'colorKey': colorKey,
    'conversationId': conversationId,
    'createdAtMs': createdAtMs,
  };

  factory Trophy.fromMap(String id, Map<String, dynamic> m) => Trophy(
    id: id,
    quote: m['quote'] as String? ?? '',
    author: m['author'] as String? ?? '',
    source: m['source'] as String? ?? '',
    iconKey: m['iconKey'] as String? ?? '',
    colorKey: m['colorKey'] as String? ?? '',
    conversationId: m['conversationId'] as String?,
    createdAtMs: (m['createdAtMs'] as int?) ?? 0,
  );

  @override
  List<Object?> get props => [
    id,
    quote,
    author,
    source,
    iconKey,
    colorKey,
    conversationId,
    createdAtMs,
  ];
}
