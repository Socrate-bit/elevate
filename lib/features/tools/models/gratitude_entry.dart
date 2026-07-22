import 'package:equatable/equatable.dart';

/// A single gratitude reflection: the three things that gave the user joy,
/// captured in one guided session. Persisted at `users/{uid}/gratitude/{id}`.
class GratitudeEntry extends Equatable {
  final String id;
  final List<String> joys;
  final DateTime createdAt;

  const GratitudeEntry({
    required this.id,
    required this.joys,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'joys': joys,
        'createdAtMs': createdAt.millisecondsSinceEpoch,
      };

  static GratitudeEntry fromMap(String id, Map<String, dynamic> m) =>
      GratitudeEntry(
        id: id,
        joys: List<String>.from(m['joys'] as List? ?? const []),
        createdAt: DateTime.fromMillisecondsSinceEpoch(
          m['createdAtMs'] as int? ?? 0,
        ),
      );

  @override
  List<Object?> get props => [id, joys, createdAt];
}
