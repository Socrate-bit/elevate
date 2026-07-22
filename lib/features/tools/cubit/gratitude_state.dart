import 'package:equatable/equatable.dart';

/// State for the guided gratitude session.
/// [step] walks the flow: 0 = enter joys, 1 = remember, 2 = be grateful, 3 = done.
class GratitudeState extends Equatable {
  final int step;
  final List<String> joys;
  final bool isSaving;
  final bool saved;

  const GratitudeState({
    this.step = 0,
    this.joys = const ['', '', ''],
    this.isSaving = false,
    this.saved = false,
  });

  /// All three joys have non-empty (trimmed) text — gates the first "Continue".
  bool get allJoysFilled => joys.every((j) => j.trim().isNotEmpty);

  GratitudeState copyWith({
    int? step,
    List<String>? joys,
    bool? isSaving,
    bool? saved,
  }) =>
      GratitudeState(
        step: step ?? this.step,
        joys: joys ?? this.joys,
        isSaving: isSaving ?? this.isSaving,
        saved: saved ?? this.saved,
      );

  @override
  List<Object?> get props => [step, joys, isSaving, saved];
}
