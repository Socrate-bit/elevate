import 'package:equatable/equatable.dart';

import '../models/trophy.dart';

/// Reveal lifecycle: the citation is being generated, then the earned trophy is
/// bursts into view.
enum TrophyRevealPhase { generating, revealed }

/// State for the one-shot trophy reveal flow.
class TrophyRevealState extends Equatable {
  final TrophyRevealPhase phase;

  /// The earned trophy, set once [phase] is [TrophyRevealPhase.revealed].
  final Trophy? trophy;

  const TrophyRevealState({
    this.phase = TrophyRevealPhase.generating,
    this.trophy,
  });

  TrophyRevealState copyWith({TrophyRevealPhase? phase, Trophy? trophy}) =>
      TrophyRevealState(
        phase: phase ?? this.phase,
        trophy: trophy ?? this.trophy,
      );

  @override
  List<Object?> get props => [phase, trophy];
}
