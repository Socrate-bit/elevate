import 'package:equatable/equatable.dart';

import '../../routines/models/routine.dart';

enum ChatRoutineMutationKind { created, updated, deleted }

/// Confirmation card attached to a model message after Gemini invoked one of
/// the routine tools (`create_routine` / `update_routine` / `delete_routine`).
/// The mutation is already applied to Firestore by the time it's persisted on
/// the message; this is purely a chat-side receipt.
class ChatRoutineMutation extends Equatable {
  final ChatRoutineMutationKind kind;
  final RoutineType routineType;
  final String routineId;
  final String routineName;
  final String iconKey;
  final String colorKey;

  const ChatRoutineMutation({
    required this.kind,
    required this.routineType,
    required this.routineId,
    required this.routineName,
    required this.iconKey,
    required this.colorKey,
  });

  Map<String, dynamic> toMap() => {
        'kind': kind.name,
        'routineType': routineType.name,
        'routineId': routineId,
        'routineName': routineName,
        'iconKey': iconKey,
        'colorKey': colorKey,
      };

  static ChatRoutineMutation fromMap(Map<String, dynamic> m) {
    final kindStr = m['kind'] as String? ?? 'created';
    final typeStr = m['routineType'] as String? ?? 'action';
    return ChatRoutineMutation(
      kind: ChatRoutineMutationKind.values.firstWhere(
        (k) => k.name == kindStr,
        orElse: () => ChatRoutineMutationKind.created,
      ),
      routineType: typeStr == 'habit' ? RoutineType.habit : RoutineType.action,
      routineId: m['routineId'] as String? ?? '',
      routineName: m['routineName'] as String? ?? '',
      iconKey: m['iconKey'] as String? ?? 'star',
      colorKey: m['colorKey'] as String? ?? 'blue',
    );
  }

  @override
  List<Object?> get props =>
      [kind, routineType, routineId, routineName, iconKey, colorKey];
}
