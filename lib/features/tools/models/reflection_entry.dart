import 'package:equatable/equatable.dart';

/// A single guided reflection: the three things the user named in one session
/// (joys, qualities, sensations…). Persisted at `users/{uid}/{collection}/{id}`,
/// where the collection is chosen by the session's [ReflectionSpec].
class ReflectionEntry extends Equatable {
  final String id;
  final List<String> items;
  final DateTime createdAt;

  const ReflectionEntry({
    required this.id,
    required this.items,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'items': items,
        'createdAtMs': createdAt.millisecondsSinceEpoch,
      };

  static ReflectionEntry fromMap(String id, Map<String, dynamic> m) =>
      ReflectionEntry(
        id: id,
        items: List<String>.from(m['items'] as List? ?? const []),
        createdAt: DateTime.fromMillisecondsSinceEpoch(
          m['createdAtMs'] as int? ?? 0,
        ),
      );

  @override
  List<Object?> get props => [id, items, createdAt];
}
