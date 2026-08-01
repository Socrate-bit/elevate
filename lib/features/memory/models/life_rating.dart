import 'package:equatable/equatable.dart';

/// The user's current life rating: a wheel-of-life score (1–5) per dimension.
/// Seeded from the page-4 onboarding assessment and updated by the memory
/// builder when the conversation reveals a meaningful shift.
class LifeRating extends Equatable {
  /// Dimension key → score in [1,5]. Keys are drawn from [dimensions]; a missing
  /// key means "not yet rated".
  final Map<String, int> ratings;

  /// True once the onboarding assessment has been copied in. Guards the one-time
  /// seed so we never overwrite live updates with stale onboarding data.
  final bool seeded;
  final DateTime updatedAt;

  const LifeRating({
    required this.ratings,
    required this.seeded,
    required this.updatedAt,
  });

  /// The eight life dimensions, matching the onboarding wheel keys.
  static const List<String> dimensions = [
    'health',
    'support',
    'safety',
    'environment',
    'selfCare',
    'enjoyment',
    'job',
    'meaning',
  ];

  factory LifeRating.empty() =>
      LifeRating(ratings: const {}, seeded: false, updatedAt: _epoch);

  static final DateTime _epoch = DateTime.fromMillisecondsSinceEpoch(0);

  LifeRating copyWith({
    Map<String, int>? ratings,
    bool? seeded,
    DateTime? updatedAt,
  }) => LifeRating(
    ratings: ratings ?? this.ratings,
    seeded: seeded ?? this.seeded,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  Map<String, dynamic> toMap() => {
    'ratings': ratings,
    'seeded': seeded,
    'updatedAtMs': updatedAt.millisecondsSinceEpoch,
  };

  static LifeRating fromMap(Map<String, dynamic> m) {
    final raw = m['ratings'];
    final ratings = <String, int>{};
    if (raw is Map) {
      for (final e in raw.entries) {
        final v = e.value;
        if (v is int) {
          ratings[e.key.toString()] = v.clamp(1, 5);
        } else if (v is num) {
          ratings[e.key.toString()] = v.toInt().clamp(1, 5);
        }
      }
    }
    return LifeRating(
      ratings: ratings,
      seeded: m['seeded'] as bool? ?? false,
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        m['updatedAtMs'] as int? ?? 0,
      ),
    );
  }

  @override
  List<Object?> get props => [ratings, seeded, updatedAt];
}
