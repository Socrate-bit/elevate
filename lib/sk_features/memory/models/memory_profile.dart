import 'package:equatable/equatable.dart';

/// Accumulating semantic facts about the user across all chat conversations.
/// Keys are free-form strings chosen by the extractor (e.g. "job", "city",
/// "purpose", "what_works"); values are short strings.
class MemoryProfile extends Equatable {
  final Map<String, String> facts;
  final DateTime updatedAt;

  const MemoryProfile({
    required this.facts,
    required this.updatedAt,
  });

  factory MemoryProfile.empty() =>
      MemoryProfile(facts: const {}, updatedAt: DateTime.fromMillisecondsSinceEpoch(0));

  MemoryProfile copyWith({
    Map<String, String>? facts,
    DateTime? updatedAt,
  }) =>
      MemoryProfile(
        facts: facts ?? this.facts,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  Map<String, dynamic> toMap() => {
        'facts': facts,
        'updatedAtMs': updatedAt.millisecondsSinceEpoch,
      };

  static MemoryProfile fromMap(Map<String, dynamic> m) {
    final rawFacts = m['facts'];
    final facts = <String, String>{};
    if (rawFacts is Map) {
      for (final e in rawFacts.entries) {
        final v = e.value;
        if (v != null) facts[e.key.toString()] = v.toString();
      }
    }
    return MemoryProfile(
      facts: facts,
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        m['updatedAtMs'] as int? ?? 0,
      ),
    );
  }

  @override
  List<Object?> get props => [facts, updatedAt];
}
