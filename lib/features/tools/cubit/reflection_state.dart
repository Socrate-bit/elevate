import 'package:equatable/equatable.dart';

/// State for a guided reflection session.
/// [step] walks the flow: 0 = enter items, 1 = remember, 2 = affirm, 3 = done.
class ReflectionState extends Equatable {
  final int step;
  final List<String> items;
  final bool isSaving;
  final bool saved;

  const ReflectionState({
    this.step = 0,
    this.items = const ['', '', ''],
    this.isSaving = false,
    this.saved = false,
  });

  /// All three items have non-empty (trimmed) text — gates the first "Continue".
  bool get allFilled => items.every((i) => i.trim().isNotEmpty);

  ReflectionState copyWith({
    int? step,
    List<String>? items,
    bool? isSaving,
    bool? saved,
  }) =>
      ReflectionState(
        step: step ?? this.step,
        items: items ?? this.items,
        isSaving: isSaving ?? this.isSaving,
        saved: saved ?? this.saved,
      );

  @override
  List<Object?> get props => [step, items, isSaving, saved];
}
